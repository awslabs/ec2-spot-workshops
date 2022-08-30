+++
title = "Workshop Preparation"
weight = 20
+++

You should now have the CloudFormation stack with GitLab opened. If not, refer to [**Starting the workshop**](before.html) section to see the steps to get to that page.

### Save GitLab access details

Switch to the **Outputs** tab and save all the information in the table to a text file. You will need it in the later steps of this workshop.

![CloudFormation Console Screenshot: Stack outputs](/images/gitlab-spot/AWSConsole-CloudFormationStackOutput.png)

### Log in to AWS Cloud9 environment

You can execute the steps of this workshop directly on your workstation, but then you will need to make sure that you have the command-line tools for Git, Terraform, kubectl and AWS CLI installed. Instead of that, to not change any local settings, we recommend to use [AWS Cloud9](https://aws.amazon.com/cloud9/): a cloud IDE where you can get access to the terminal and install all the required tools.

A Cloud9 environment has already been provisioned for you in the CloudFormation template (created in the [**Starting the workshop**](before.html) section). You will now log in to it and do the final configuration steps: disable the AWS managed temporary credentials and download the required workshop files.

1. In the AWS Console enter **Cloud9** in the search box at the top of the screen and open the service.
2. On the **Your environments** page find the environment called like `GitLabWorkshopC9Instance-...` and click the **Open IDE** button for it:

![AWS Console Screenshot: Cloud9 Environment](/images/gitlab-spot/AWSConsole-Cloud9Environment.png)

3. When the environment comes up, close all tabs inside it and open a new terminal by clicking **+** > **New Terminal**, you should see a screen like this:

![Cloud9 Environment Screenshot: Initial view](/images/gitlab-spot/Cloud9-Initial.png)

4. Open preferences tab by choosing the cogwheel icon at the top-right corner of the screen. Then choose **AWS Settings** in the navigation pane.
5. Disable **AWS managed temporary credentials** toggle:

![Cloud9 Screenshot: Preferences](/images/gitlab-spot/Cloud9-Preferences.png)

6. Close the **Preferences** tab and in the terminal tab, execute the following command to verify that you are using the correct role (in the output you should see `GitLabWorkshopC9Role` and green `OK`):

```
aws sts get-caller-identity --query Arn | grep GitLabWorkshopC9Role && echo -e "\033[0;32mOK\033[0m" || echo -e "\033[0;31mNOT OK\033[0m"
```

![Cloud9 Screenshot: Caller identity](/images/gitlab-spot/Cloud9-CallerIdentity.png)

7. Now you will upload the SSH key you saved in the previous section. Choose **File** > **Upload Local Files...**.
8. In the popup page choose **Select files** and select the file `ee-default-keypair.pem` that you downloaded previously.
9. Make sure the file appeared in the file tree on the left, close the popup page, and modify the file permissions by executing the following command in the terminal:

```
chmod 400 ~/environment/ee-default-keypair.pem
```

10. Finally, enable Cloud9 to show hidden files (you will need it to modify the scripts of GitLab CI/CD later). To do this choose the small cogwheel icon right above the file tree and choose **Show Hidden Files** if it has not been enabled yet (if there is a tick to the left of it, do not click again, as it will disable the display of hidden files):

![Cloud9 Screenshot: Show hidden files](/images/gitlab-spot/Cloud9-ShowHiddenFiles.png)

You are now ready to start the main sections of the workshop! Please proceed to [**Create a GitLab repository**](lab1.html).