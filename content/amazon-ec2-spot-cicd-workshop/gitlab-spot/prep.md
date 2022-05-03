+++
title = "Workshop Preparation"
weight = 20
+++

You should now have the CloudFormation stack with GitLab opened. If not, refer to [**Starting the workshop**](before.html) section to see the steps to get to that page.

### Save GitLab access details

Switch to the **Outputs** tab and save all the information in the table to a text file. You will need it in the later labs.

![CloudFormation Console Screenshot: Stack outputs](/images/gitlab-spot/AWSConsole-CloudFormationStackOutput.png)

### Create an AWS Cloud9 environment

You can execute the steps of this workshop directly on your workstation, but then you will need to make sure that you have the command-line tools for Git, Terraform, kubectl and AWS CLI installed. Instead of that, to not change any local settings, we recommend to use [AWS Cloud9](https://aws.amazon.com/cloud9/): a cloud IDE where you can get access to the terminal and install all the required tools.

{{% notice warning %}}
If you are running the workshop on your own, the Cloud9 workspace should be built by an IAM user with Administrator privileges, not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}

{{% notice info %}}
If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, or any other event hosted by 
an AWS employee) follow the instructions on the region that should be used to launch resources
{{% /notice %}}

{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted.
Cloud9 requires third-party-cookies. You can whitelist the [specific domains]( https://docs.aws.amazon.com/cloud9/latest/user-guide/troubleshooting.html#troubleshooting-env-loading).
{{% /notice %}}

Launch Cloud9 in your closest region:

{{< tabs name="Region" >}}
    {{< tab name="N. Virginia" include="cloud9/us-east-1.md" />}}
    {{< tab name="Oregon" include="cloud9/us-west-2.md" />}}
    {{< tab name="Frankfurt" include="cloud9/eu-central-1.md" />}}
    {{< tab name="Ireland" include="cloud9/eu-west-1.md" />}}
    {{< tab name="Ohio" include="cloud9/us-east-2.md" />}}
    {{< tab name="Singapore" include="cloud9/ap-southeast-1.md" />}}
{{< /tabs >}}

1. Choose **Create environment**.
2. Name it `gitlab-spot-workshop` and choose **Next step**.
3. Expand **Network settings (advanced)** section and select the VPC from the Output parameters you saved above (should contain `GitLabSpotWorkshop VPC` in its name), the subnet can be any of the two:

![Cloud9 Console Screenshot: Select VPC](/images/gitlab-spot/AWSConsole-CreateCloud9SelectVPC.png)

4. Choose **Next step**.
5. Choose **Create environment**.
6. When the environment comes up, close all tabs inside it and open a new terminal by clicking **+** > **New Terminal**, you should see a screen like this:

![Cloud9 Environment Screenshot: Initial view](/images/gitlab-spot/Cloud9-Initial.png)

### Create an IAM role

By default, Cloud9 uses AWS managed temporary credentials to make calls to AWS API from the terminal. Instead, you will create an IAM role and EC2 instance profile to ensure the correct Role Based Access Control (RBAC) permissions in Kubernetes cluster later on.

1. Return to the browser tab with AWS Console (if you closed it, click the icon with the cloud and digit 9 in the top-left corner and then choose **Go To Your Dashboard**)
2. Type `IAM` in the search box at the top and open the service.
3. In the navigation pane choose **Roles** and then choose **Create role**.
4. In the **Use case** section select **EC2** and choose **Next**.
5. In the **Permissions policies** table find `AdministratorAccess` and mark the checkbox next to it, then choose **Next**

![IAM Console Screenshot: AdministratorAccess permissions](/images/gitlab-spot/AWSConsole-IAMRolePermissions.png)

6. In the **Role name** field type `gitlab-spot-workshop-admin` and choose **Create role** in the bottom of the screen.

### Attach IAM role to EC2 instance

Now, you will attach the new role to the EC2 instance used by your Cloud9 environment.

1. Type `EC2` in the search box at the top and open the service.
2. In the navigation pane choose **Instances**.
3. You should see two instances in the list. Select the one with name starting with `aws-cloud9-`, then choose **Actions** > **Security** > **Modify IAM role**:

![EC2 Console Screenshot: Modify the instance role](/images/gitlab-spot/AWSConsole-EC2Instances.png)

4. In the **IAM role** dropdown select `gitlab-spot-workshop-admin` and choose **Save**.

### Configure Cloud9 environment

You will now finalize AWS Cloud9 environment configuration by disabling the AWS managed temporary credentials and download the required workshop files.

1. Return to the browser tab with Cloud9 environment.
2. Open preferences tab by choosing the cogwheel icon at the top-right corner of the screen. Then choose **AWS Settings** in the navigation pane.
3. Disable **AWS managed temporary credentials** toggle:

![Cloud9 Screenshot: Preferences](/images/gitlab-spot/Cloud9-Preferences.png)

4. Close the **Preferences** tab and in the terminal tab, execute the following command to verify that you are using the correct role (in the output you should see `gitlab-spot-workshop-admin`):

```
aws sts get-caller-identity --query Arn
```

![Cloud9 Screenshot: Caller identity](/images/gitlab-spot/Cloud9-CallerIdentity.png)

5. Execute the following commands in the terminal to copy all workshop files:

```
git clone https://github.com/awslabs/ec2-spot-workshops.git
cp -ar ec2-spot-workshops/workshops/amazon-ec2-spot-cicd-workshop/ .
rm -rf ec2-spot-workshops/
```

6. Now you will upload the SSH key you saved in the previous section. Choose **File** > **Upload Local Files...**.
7. In the popup page choose **Select files** and select the file `ee-default-keypair.pem` that you downloaded previously.
8. Make sure the file appeared in the file tree on the left, close the popup page, and modify the file permissions by executing the following command in the terminal:

```
chmod 400 ~/environment/ee-default-keypair.pem
```

9. Finally, enable Cloud9 to show hidden files (you will need it to modify the scripts of GitLab CI/CD later). To do this choose the small cogwheel icon right above the file tree and choose **Show Hidden Files**:

![Cloud9 Screenshot: Show hidden files](/images/gitlab-spot/Cloud9-ShowHiddenFiles.png)

You are now ready to start the main labs of the workshop! Please proceed to [**Lab 1: Create a GitLab repository**](lab1.html).