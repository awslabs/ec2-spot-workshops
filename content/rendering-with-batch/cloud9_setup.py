#!/usr/bin/env python3

import boto3, time, json, os


def create_cloud9_env(name, instance_type):
    """Creates a Cloud9 environment given a name and
    and instance type.

    Keyword arguments:
    name -- Name of the new environment
    instance_type: instance type to use in the environment
    """

    print('\tCreating Cloud9 environment...')

    client = boto3.client('cloud9')

    return client.create_environment_ec2(
        name=name,
        instanceType=instance_type,
        automaticStopTimeMinutes=30
    )['environmentId']


def retrieve_cloud9_instance(env_id):
    """Retrieves the EC2 instance associated to
    a Cloud9 environment.

    Keyword arguments:
    env_id -- Identifier of the Cloud9 environment
    """

    print("\tRetrieving environment's instance...")

    client = boto3.client('ec2')

    return client.describe_instances(
        Filters=[
            {
                'Name': 'tag:aws:cloud9:environment',
                'Values': [
                    env_id,
                ]
            },
        ]
    )['Reservations'][0]['Instances'][0]


def resize_volume(volume_id, new_size):
    """Resizes an EBS volume.

    Keyword arguments:
    volume_id -- Identifier of the volume to resize
    new_size: size in GB to which the volume should be resized
    """

    print('\tResizing EBS volume...')

    client = boto3.client('ec2')

    client.modify_volume(
        VolumeId=volume_id,
        Size=new_size
    )


def retrieve_volume_modifications(volume_id):
    """Retrieves the modification status of an
    EBS volume.

    Keyword arguments:
    volume_id -- Identifier of the volume of which to retrieve the modifications
    """

    client = boto3.client('ec2')

    return client.describe_volumes_modifications(
        VolumeIds=[
            volume_id,
        ]
    )['VolumesModifications'][0]


def expand_file_system(instance_id, volume_id):
    """Reboots an EC2 instance so that its file system
    is expanded to match the new size of the EBS volume.

    Keyword arguments:
    instance_id -- Identifier of the instance to reboot
    volume_id: identifier of the volume that has been resized
    """

    print('\tWaiting to expand the file system...')

    client = boto3.client('ec2')
    mdification = retrieve_volume_modifications(volume_id)

    # Wait until the EBS volume enters the optimizing state
    while mdification['ModificationState'] != 'optimizing':
        time.sleep(5)
        mdification = retrieve_volume_modifications(volume_id)

    print('\tRebooting instance to expand the file system...')

    client.reboot_instances(
        InstanceIds=[
            instance_id,
        ]
    )

    print('\tInstance rebooted. It can take a couple of minutes for it to become responsive again.')


if __name__ == "__main__":
    # Create the Cloud9 environment
    c9_env_id = create_cloud9_env('RenderingWithBatch', 't2.micro')
    os.environ['C9_ENV_ID'] = c9_env_id

    # Retrieve the environment's instance
    instance_data = retrieve_cloud9_instance(c9_env_id)

    # Resize the ebs volume
    volume_id = instance_data['BlockDeviceMappings'][0]['Ebs']['VolumeId']
    resize_volume(volume_id, 40)

    # Expand the file system to the new volume size
    instance_id = instance_data['InstanceId']
    expand_file_system(instance_id, volume_id)
