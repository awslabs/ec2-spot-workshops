+++
title = "Configuring GitLab runners using Docker Machine (optional)"
weight = 10
+++

{{% notice info %}}
Only complete this lab if you want to test the legacy way of deploying spot instances in GitLab using Docker Machine and if you have not performed the lab with runners in an auto-scaling group. Otherwise, skip it and proceed to [**Lab 3: Building the demo app**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/lab3.html).
{{% /notice %}}

### Create an IAM role for GitLab Runners

You will now create a new IAM role that has access to Amazon EKS, Amazon S3, Amazon EC2, and Amazon ECR, which the GitLab Runners will need to build and deploy the demo app.

1. Return to the browser tab with IAM console or open it again using the search box at the top.
2. Choose **Policies** in the navigation pane.
3. Choose **Create Policy**.
4. Switch to **JSON** tab and paste the below policy into the editor window:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:AccessKubernetesApi",
                "ssm:GetParameter",
                "eks:ListUpdates",
                "eks:ListFargateProfiles"
            ],
            "Resource": "*"
        }
    ]
}
```

5. Choose **Next: Tags**.
6. Choose **Next: Review**.
7. In the **Name** field type `EKS-ReadAll` and choose **Create policy**:

![IAM Console Screenshot: Create EKS-ReadAll policy](/images/gitlab-spot/AWSConsole-IAMCreatePolicy.png)

8. Repeat the same steps to create another policy with the following JSON and the name `IAM-PassRole`:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:iam::*:role/GitLabRunner*"
        }
    ]
}
```

9. In the navigation pane choose **Roles**
10. Choose **Create role**.
11. In the **Use case** section select **EC2** and choose **Next**.
12. In the **Permissions policies** table find the following policies one-by-one and select each of them:
    - `EKS-ReadAll`
    - `IAM-PassRole`
    - `AmazonS3FullAccess`
    - `AmazonEC2FullAccess`
    - `AmazonEC2ContainerRegistryFullAccess`

{{% notice warning %}}
Note that here you are assigning quite broad permission policies to the IAM role to avoid creating specific custom policies, but in a real Production environment you should follow the least privilege principle. You can find the best practices in [AWS Blogs](https://aws.amazon.com/blogs/security/techniques-for-writing-least-privilege-iam-policies/).
{{% /notice %}}

13. Make sure you have 5 policies selected and choose **Next**.
14. In the **Role name** field type **GitLabRunner** and choose **Create role**.

### Deploy GitLab Runner Manager

You will now configure a new GitLab Runner that will serve as a Runner Manager and using Docker Machine will create new EC2 Spot instances: the actual CI/CD jobs will be executed on them. You can use x86_64 architecture, but to additionally optimize the costs, we suggest that you run the instance on [AWS Graviton](https://aws.amazon.com/ec2/graviton/) processor (as there are no CI/CD jobs running on it, the architecture is not important).

1. In the browser tab with AWS Console, type `EC2` in the search box at the top and open the service.
2. Choose **Instances** in the navigation pane.
3. Choose **Launch instances**.
4. In the field **Name** type `GitLabRunnerManager`.
5. In the **Architecture** dropdown of the **Application and OS Images (Amazon Machine Image)** pane select `64-bit (Arm)`. Leave the Operating System as **Amazon Linux**.
6. In the **Instance type** dropdown select `t4g.nano`.
7. In the **Key pair name** dropdown select `ee-default-keypair` or any other key you created previously if you run this lab in your own account.
8. In the **Network settings** pane choose **Edit** and then:
    - In the **VPC** field select the VPC ID you saved from CloudFormation Output values in [**Workshop Preparation**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/prep.html), it contains `GitLabSpotWorkshop VPC` in its name.
    - In the **Security group name** field type `GitLabRunnerManager`
9. Expand the **Advanced details** and in the **IAM instance profile** dropdown select `GitLabRunner`.

{{% notice warning %}}
In Production configuration it is better to separate the IAM role for the Runner Manager and the actual Runner to follow the least privilege principle.
{{% /notice %}}

10. Leave the rest settings as default and choose **Launch instance**.

![EC2 Console Screenshot: Launch an instnace](/images/gitlab-spot/AWSConsole-EC2LaunchInstance.png)

### Configure GitLab Runner and Docker Machine
You will now configure the instance to serve as a Runner Manager by installing all the necessary tools into it.

1. Connect to the instance by SSH: you can select it in the EC2 console and then choose **Connect**, select the **EC2 Instance Connect** tab and choose **Connect**. Alternatively, you can return to the browser tab with Cloud9 environment and connect to it using the command below, substituting the `<IP-address>` to the private IP address of the instance:

```
ssh -i ~/environment/ee-default-keypair.pem ec2-user@<IP-address>
```

2. After connecting, install the GitLab Runner using the following commands:

```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
export GITLAB_RUNNER_DISABLE_SKEL=true; sudo -E yum install gitlab-runner -y
```

3. Install Docker:

```
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
```

4. Terminate the SSH session and then connect again. Verify that Docker is working by running:

```
docker info
```

5. Install Docker Machine:

```
base=https://github.com/docker/machine/releases/download/v0.16.2 \
&& curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine \
&& sudo mv /tmp/docker-machine /usr/local/bin/docker-machine \
&& chmod +x /usr/local/bin/docker-machine
docker-machine version
```

### Configure security group for runners
You will now create a new security group that would allow the communication from the Runner Manager on ports 22 and 2376 (used by Docker Machine).

{{%expand "Click to reveal detailed instructions" %}}
1. Return to the browser tab with EC2 console or open it again.
2. Choose **Security Groups** in the **Network & Security** section of the navigation pane.
3. Choose **Create security group**.
4. In the **Security group name** field type `GitLabRunner`.
5. In the **Description** field type `GitLab Runner Security Group`.
6. In the **VPC** field select the VPC ID you saved from CloudFormation Output values in [**Workshop Preparation**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/prep.html), it contains `GitLabSpotWorkshop VPC` in its name.
6. Create two inbound rules by choosing **Add rule** in the **Inbound rules** pane:
    - **Type** = `SSH`, **Source** = `Custom`, select the `GitLabRunnerManager` security group
    - **Type** = `Custom TCP`, **Port range** = `2376`, **Source** = `Custom`, select the `GitLabRunnerManager` security group
7. Choose **Create security group**.
{{% /expand%}}

### Configure runner
Finally, you will configure the runner and register it in GitLab.

1. Return to the browser tab with GitLab.
2. In the **GitLab Spot Workshop** repository choose **Settings** > **CI/CD** in the navigation pane.
3. Expand the **Runners** section and save into a text file both GitLab URL and the registration token that are displayed on the screen:

![GitLab Screenshot: Runners configuration](/images/gitlab-spot/GitLab-RunnersRegistration.png)

3. Return to the browser tab with Cloud9. If you are connected via SSH to the Runner Manager in the terminal, create another terminal and run the following commands in it to get the AMI (Amazon Machine Image) ID to use for the runners, copy and save it:

```
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
aws ssm get-parameters --names /aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id --region $REGION --query "Parameters[0].Value" --output text
```

4. Return to the browser tab with SSH session with the Runner Manager (reconnect if it has been disconnected by timeout) and run the below command, substituting the values in the angle brackets with the required parameters (without angle brackets):

```
sudo gitlab-runner register \
  --non-interactive \
  --url "<GitLab URL that you copied above>" \
  --registration-token "<Token that you copied above>" \
  --executor "docker+machine" \
  --description "GitLab Spot Workshop Runner" \
  --docker-privileged \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --docker-image "docker:latest" \
  --docker-disable-cache="false" \
  --cache-type "s3" \
  --cache-path "/" \
  --cache-shared="true" \
  --cache-s3-server-address "s3.amazonaws.com" \
  --cache-s3-bucket-name "<The value of GitLabCacheBucket from CloudFormation stack outputs>" \
  --cache-s3-bucket-location "<Region where you are running this workshop>" \
  --machine-idle-time 600 \
  --machine-machine-driver "amazonec2" \
  --machine-machine-name "gitlab-spot-workshop-%s" \
  --machine-machine-options "amazonec2-iam-instance-profile=GitLabRunner" \
  --machine-machine-options "amazonec2-region=<Region where you are running this workshop>" \
  --machine-machine-options "amazonec2-vpc-id=<The value of VPC from CloudFormation stack outputs>" \
  --machine-machine-options "amazonec2-subnet-id=<The value of Subnet1 from CloudFormation stack outputs>" \
  --machine-machine-options "amazonec2-zone=<The last letter of the value of Subnet1Zone from CloudFormation stack outputs, for example, a>" \
  --machine-machine-options "amazonec2-use-private-address=true" \
  --machine-machine-options "amazonec2-tags=runner-manager-name,aws-runner,gitlab,true,gitlab-runner-autoscale,true" \
  --machine-machine-options "amazonec2-security-group=GitLabRunner" \
  --machine-machine-options "amazonec2-request-spot-instance=true" \
  --machine-machine-options "amazonec2-instance-type=m5.xlarge" \
  --machine-machine-options "amazonec2-ami=<AMI ID you copied above>"
```

Example:

![GitLab Runner Screenshot: Runner manager registration](/images/gitlab-spot/GitLab-RunnerManagerRegistration.png)

5. After successful registration, change the global `concurrent` parameter and restart the runner:

```
sudo sed -i 's/concurrent\s*=\s*1/concurrent = 10/' /etc/gitlab-runner/config.toml
sudo gitlab-runner restart
sudo gitlab-runner status
```

6. You can now exit the SSH session.
7. Return to the browser tab with GitLab and refresh the **CI/CD** page to make sure that your runner is now present in the **Runners** section:

![GitLab Screenshot: Docker Machine runner available](/images/gitlab-spot/GitLab-DockerMachineRunnerAvailable.png)

{{% notice tip %}}
One of the drawbacks of Docker Machine approach is that you can only specify one instance type and one subnet per Runner Manager. As such, it might happen that there is no spot capacity for it available and your CI/CD pipeline hangs running with the latest output in the job execution log staying at `Preparing the "docker+machine" executor`. If this happens, return to the EC2 console and choose **Spot Requests** in the navigation pane. Check if your requests are indeed not getting fulfilled, and if so, on the Runner Manager instance try changing the instance type or the subnet and availability zone in the `/etc/gitlab-runner/config.toml` file and restart the `gitlab-runner`. For a more permanent solution, please use auto-scaling groups as discussed in [**Lab 2: Configure GitLab runners on Spot instances**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/lab2.html).
{{% /notice %}}

You can now proceed to build your application in [**Lab 3: Building the demo app**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/lab3.html).