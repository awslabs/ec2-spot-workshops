import sys, getopt, math, boto3, argparse, json


INPUT_URI = ''          # S3 URI where the blender file is located
OUTPUT_URI = ''         # S3 URI where to upload the rendered file
F_PER_JOB = 0           # Number of frames that each job has to render
JOB_NAME = ''           # Name of the job that will be submitted to Batch
JOB_QUEUE = ''          # Queue to which the job is submitted
JOB_DEFINITION = ''     # Job definition used by the submitted job
FILE_NAME = ''          # Name of the blender file


def read_blend_rend_chunk(path):
    """Extract from Blender's script library included in scripts/modules.
    Reads the header of a blend file and returns scenes' information.

    Keyword arguments:
    path -- path where the blend file is located
    """

    import struct

    blendfile = open(path, "rb")

    head = blendfile.read(7)

    if head[0:2] == b'\x1f\x8b':  # gzip magic
        import gzip
        blendfile.seek(0)
        blendfile = gzip.open(blendfile, "rb")
        head = blendfile.read(7)

    if head != b'BLENDER':
        print("not a blend file:", path)
        blendfile.close()
        return []

    is_64_bit = (blendfile.read(1) == b'-')

    # true for PPC, false for X86
    is_big_endian = (blendfile.read(1) == b'V')

    # Now read the bhead chunk!!!
    blendfile.read(3)  # skip the version

    scenes = []

    sizeof_bhead = 24 if is_64_bit else 20

    while blendfile.read(4) == b'REND':
        sizeof_bhead_left = sizeof_bhead - 4

        struct.unpack('>i' if is_big_endian else '<i', blendfile.read(4))[0]
        sizeof_bhead_left -= 4

        # We don't care about the rest of the bhead struct
        blendfile.read(sizeof_bhead_left)

        # Now we want the scene name, start and end frame. this is 32bites long
        start_frame, end_frame = struct.unpack('>2i' if is_big_endian else '<2i', blendfile.read(8))

        scene_name = blendfile.read(64)

        scene_name = scene_name[:scene_name.index(b'\0')]

        try:
            scene_name = str(scene_name, "utf8")
        except TypeError:
            pass

        scenes.append((start_frame, end_frame, scene_name))

    blendfile.close()

    return scenes

def parse_arguments():
    """Parses the command line arguments and stores the values in global variables.
    """

    parser = argparse.ArgumentParser(description='Submit an AWS Batch job that will render a Blender file in a distributed fashion.')
    parser.add_argument('-i', dest='input_uri', type=str, required=True, help='S3 URI where the blender file is located')
    parser.add_argument('-o', dest='output_uri', type=str, required=True, help='S3 URI where to upload the rendered file')
    parser.add_argument('-f', dest='f_per_job', type=int, required=True, help='Number of frames that each job has to render')
    parser.add_argument('-n', dest='job_name', type=str, required=True, help='Name of the job that will be submitted to Batch')
    parser.add_argument('-q', dest='job_queue', type=str, required=True, help='Queue to which the job is submitted')
    parser.add_argument('-d', dest='job_definition', type=str, required=True, help='Job definition used by the submitted job')
    args = parser.parse_args()

    if args.f_per_job < 1:
        print('F_PER_JOB must be a positive integer')
        sys.exit(2)

    global INPUT_URI
    INPUT_URI = args.input_uri
    global OUTPUT_URI
    OUTPUT_URI = args.output_uri
    global F_PER_JOB
    F_PER_JOB = args.f_per_job
    global JOB_NAME
    JOB_NAME = args.job_name
    global JOB_QUEUE
    JOB_QUEUE = args.job_queue
    global JOB_DEFINITION
    JOB_DEFINITION = args.job_definition
    global FILE_NAME
    FILE_NAME = INPUT_URI.split('/')[-1]

def download_blender_file_from_s3():
    """Downloads the blend file from S3 and stores it locally.
    """

    bucket = INPUT_URI.split('s3://')[1].split('/')[0]

    s3 = boto3.resource('s3')
    s3.meta.client.download_file(bucket, FILE_NAME, './{}'.format(FILE_NAME))

def get_number_of_frames(path):
    """Reads the header of the blend file and calculates
    the number of frames it has.

    Keyword arguments:
    path -- path where the blend file is located
    """

    try:
        frame_start, frame_end, scene = read_blend_rend_chunk(path)[0]
    except FileNotFoundError as e:
        print(e.args[1])
        sys.exit(2)
    else:
        return int(frame_end - frame_start + 1)

def calculate_array_job_size():
    """Calculates the size of the job array
    based on the number of frames of the blender file
    and the number of frames that each job has to render
    """

    # Get the scene's number of frames by reading the header of the blend file
    n_frames = get_number_of_frames('./{}'.format(FILE_NAME))

    # Adjust the number of frames per job, if that value is greater than the number of frames in the scene
    global F_PER_JOB
    F_PER_JOB = min(F_PER_JOB, n_frames)

    # Calculate how many jobs need to be submitted
    return math.ceil(n_frames / F_PER_JOB)

def submit_job(array_size):
    """Submits a Batch job.
    Depending on the value of <array_size>, it will submit either
    a single job or an array job

    Keyword arguments:
    array_size -- size of the array job
    """

    client = boto3.client('batch')

    kwargs = {
        'jobName': JOB_NAME,
        'jobQueue': JOB_QUEUE,
        'jobDefinition': JOB_DEFINITION,
        'containerOverrides': {
            'command': ['render -i {} -o {} -f {}'.format(INPUT_URI, OUTPUT_URI, F_PER_JOB)]
        },
        'retryStrategy': {
            'attempts': 1
        }
    }

    # If this is not a single job, submit it as an array job
    if array_size > 1:
        kwargs['arrayProperties'] = {
            'size': array_size
        }

    try:
        print(json.dumps(client.submit_job(**kwargs)))
    except Exception as e:
        print(e.args[0])
        sys.exit(2)

if __name__ == "__main__":
    # Gather command line arguments
    parse_arguments()

    # Download the blend file from s3 and save it locally to work with it
    download_blender_file_from_s3()

    # Calculate the size of the array job
    array_size = calculate_array_job_size()

    # Submit the job
    submit_job(array_size)
