+++
title = "Lab 2: Configure GitLab runners on Spot instances"
chapter = false
weight = 40
+++

In this lab you will configure GitLab CI/CD runners using **GitLab HA Scaling Runner Vending Machine for AWS** solution. You can find more about its features at https://gitlab.com/guided-explorations/aws/gitlab-runner-autoscaling-aws-asg/-/blob/main/FEATURES.md. It is built using Infrastructure as Code (IaC) with AWS CloudFormation, but you can implement similar logic using any IaC solution of your choice.

If you want to use the previous way of manually configuring runners using Docker Machine (which does not use Auto-Scaling Groups and thus has some drawbacks compared to the current approach), see the steps in the [**Configuring GitLab runners using Docker Machine (optional)**](lab2/docker-machine.html) section instead.

There are also other ways to create GitLab runners on spot instances that we are not reviewing in this workshop: runners inside containers in a Kubernetes cluster with the worker nodes on spot instances (we will deploy such cluster for application testing, but not for executing the runners) or in Amazon ECS with Fargate Spot.

### Deploy the CloudFormation stack

You will now get the runner configuration information from GitLab and then start the AWS CloudFormation stack deployment.

1. Return to the browser tab with GitLab.
2. In the **GitLab Spot Workshop** repository choose **Settings** > **CI/CD** in the navigation pane.
3. Expand the **Runners** section and save into a text file both GitLab URL and the registration token that are displayed on the screen:

![GitLab Screenshot: Runners configuration](/images/gitlab-spot/GitLab-RunnersRegistration.png)

4. Use one of the links at https://gitlab.com/guided-explorations/aws/gitlab-runner-autoscaling-aws-asg#easy-buttons-provided to deploy the stack (make sure to change the link to the correct region). We will be using the **Amazon Linux 2 Docker Simple Scaling Spot Instances**, you can use one of the below links to deploy it depending on the region where you are running the workshop:

{{< tabs name="Region" >}}
    {{< tab name="N. Virginia" include="gitlab-easybutton/us-east-1.md" />}}
    {{< tab name="Oregon" include="gitlab-easybutton/us-west-2.md" />}}
    {{< tab name="Frankfurt" include="gitlab-easybutton/eu-central-1.md" />}}
    {{< tab name="Ireland" include="gitlab-easybutton/eu-west-1.md" />}}
    {{< tab name="Ohio" include="gitlab-easybutton/us-east-2.md" />}}
    {{< tab name="Singapore" include="gitlab-easybutton/ap-southeast-1.md" />}}
{{< /tabs >}}

Investigate the parameters presented and try deploying the stack yourself. Expand the section below to see step-by-step instructions.

{{%expand "Click to reveal detailed instructions" %}}
5. In the **GitLab Instance URL** field enter GitLab URL you saved previously (in the format `https://xxx.cloudfront.net`).
6. In the **One or more runner Registration tokens from the target instance.** field enter the token you saved previously.
7. In the **The VPC in the account and region should be used.** enter the VPC ID you saved from CloudFormation Output values in [**Workshop Preparation**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/prep.html) (in the format `vpc-...`).
8. Leave the rest parameters with their default values, in the bottom of the screen mark the checkboxes **I acknowledge that AWS CloudFormation might create IAM resources with custom names.** and **I acknowledge that AWS CloudFormation might require the following capability: CAPABILITY_AUTO_EXPAND**, and choose **Create stack**:

![CloudFormation Console Screenshot: Create GitLab Runners stack](/images/gitlab-spot/AWSConsole-CloudFormationGitLabRunnersStack.png)
9. Wait until the stack is in `CREATE_COMPLETE` status, which should take approximately 5-10 minutes.
{{% /expand%}}

### Enable access to AWS services for GitLab Runners

You will now create a new IAM role that has access to Amazon EKS, Amazon S3, AWS Systems Manager, Amazon EC2 Auto Scaling, and Amazon ECR, which the GitLab Runners will need to build and deploy the demo app, and then update the CloudFormation stack to use it.

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

8. In the navigation pane choose **Roles**
9. Choose **Create role**.
10. In the **Use case** section select **EC2** and choose **Next**.
11. In the **Permissions policies** table find the following policies one-by-one and select each of them:
    - `EKS-ReadAll`
    - `AmazonS3FullAccess`
    - `AmazonEC2RoleforSSM`
    - `CloudWatchAgentServerPolicy`
    - `AmazonSSMAutomationRole`
    - `AmazonSSMMaintenanceWindowRole`
    - `AmazonEC2ContainerRegistryFullAccess`
    - A policy created by CloudFormation stack containing `EC2SelfAccessPolicy` in its name
    - A policy created by CloudFormation stack containing `ASGSelfAccessPolicy` in its name

{{% notice warning %}}
Note that here you are assigning quite broad permission policies to the IAM role to avoid creating specific custom policies, but in a real Production environment you should follow the least privilege principle. You can find the best practices in [AWS Blogs](https://aws.amazon.com/blogs/security/techniques-for-writing-least-privilege-iam-policies/).
{{% /notice %}}

12. Make sure you have 9 policies selected and choose **Next**.
13. In the **Role name** field type **GitLabRunner** and choose **Create role**.
14. Return to CloudFormation stacks and open the stack starting with `linux-docker-scaling-spotonly-` and marked as **NESTED**:

![CloudFormation Console Screenshot: GitLab nested stack](/images/gitlab-spot/AWSConsole-CloudFormationNestedStack.png)

15. Select **Update**.
16. In the popup page select **Update nested stack** and then choose **Update stack**.
17. Choose **Next** (leave the default option of **Use current template** unchanged).
18. In the **Override automatic IAM Instance Profile for a precreated one** field type `GitLabRunner`.
19. In the **4ASGUpdateMinInstancesInService** field type `0`, this would allow to update the group faster by leaving no active runners in place. It should not be used in a real environment if you have CI/CD jobs constantly coming in, as there might be no runners to take them.
20. Choose **Next** and then again **Next**.
21. On the final screen select the **I acknowledge that AWS CloudFormation might create IAM resources with custom names.** checkbox and choose **Update stack**.
22. Wait until the stack is in the `UPDATE_COMPLETE` status which should take approximately 5 minutes.

After that you can open the EC2 console and verify that your runner(s) are using spot instances: open the corresponding EC2 instance (its name starts with `linux-docker-scaling-spotonly-`) and check the **Lifecycle** field:

![EC2 Console Screenshot: Runner lifecycle](/images/gitlab-spot/AWSConsole-EC2RunnerLifecycle.png)

23. Return to the browser tab with GitLab, refresh the CI/CD settings page and make sure that your runner(s) have appeared in the **Runners** section:

![GitLab Screenshot: Runner available](/images/gitlab-spot/GitLab-RunnerAvailable.png)

{{% notice tip %}}
You had to do an extra step to update the IAM role of the runners, because this parameter is not available in the easy buttons templates. However, you could instead use the full template right away and provide all the required parameters directly. You can find more information at https://gitlab.com/guided-explorations/aws/gitlab-runner-autoscaling-aws-asg.
{{% /notice %}}

You can now proceed to build your application in [**Lab 3: Building the demo app**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/lab3.html).