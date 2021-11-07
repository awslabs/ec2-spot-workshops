import boto3
import sys


def get_jobs_in_array(array_id):
    """Returns the identifiers of the jobs inside an array job

    Keyword arguments:
    array_id -- identifier of the array job
    """

    client = boto3.client('batch')
    kwargs = {'arrayJobId': array_id, 'jobStatus': 'SUCCEEDED'}
    job_ids = []

    while True:
        response = client.list_jobs(**kwargs)
        job_ids += [job['jobId'] for job in response['jobSummaryList']]

        if 'nextToken' in response:
            kwargs['nextToken'] = response['nextToken']
        else:
            return job_ids

def show_execution_attempts(job_ids):
    """Shows the number of atemmps of the specified jobs,
    if the attempt number is bigger than 1.

    Keyword arguments:
    job_ids -- Identifiers of the target jobs
    """

    client = boto3.client('batch')
    page = 0
    items_per_page = 100

    while page * items_per_page < len(job_ids):
        start_index = page * items_per_page
        end_index = start_index + items_per_page
        page += 1

        response = client.describe_jobs(
            jobs=job_ids[start_index:end_index]
        )

        for job in response['jobs']:
            if len(job['attempts']) > 1:
                print('Frame\t{}\twas attempted to render {} times'.format(job['arrayProperties']['index'], len(job['attempts'])))


if __name__ == "__main__":
    array_id = sys.argv[1]

    # Get the identifiers of the jobs in the array job
    job_ids = get_jobs_in_array(array_id)

    # Show the number of attempts per job
    show_execution_attempts(job_ids)
