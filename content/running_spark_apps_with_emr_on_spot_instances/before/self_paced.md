---
title: "...on your own"
chapter: false
weight: 20
---

{{% notice warning %}}
Only complete this section if you are running the workshop on your own. If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, etc), go to [Start the workshop at an AWS event]({{< ref "/running_spark_apps_with_emr_on_spot_instances/before/aws_event.md" >}}).
{{% /notice %}}

## Running the workshop on your own

### Creating an account to run the workshop

{{% notice warning %}}
Your account must have the ability to create new IAM roles and scope other IAM permissions.
{{% /notice %}}

1. If you don't already have an AWS account with Administrator access: [create
one now by clicking here](https://aws.amazon.com/getting-started/)

1. Once you have an AWS account, ensure you are following the remaining workshop steps
as an IAM user with administrator access to the AWS account:
[Create a new IAM user to use for the workshop](https://console.aws.amazon.com/iam/home?#/users$new)

1. Enter the user details:
![Create User](/images/running-emr-spark-apps-on-spot/prerequisites/iam-1-create-user.png)

1. Attach the AdministratorAccess IAM Policy:
![Attach Policy](/images/running-emr-spark-apps-on-spot/prerequisites/iam-2-attach-policy.png)

1. Click to create the new user:
![Confirm User](/images/running-emr-spark-apps-on-spot/prerequisites/iam-3-create-user.png)

1. Take note of the login URL and save:
![Login URL](/images/running-emr-spark-apps-on-spot/prerequisites/iam-4-save-url.png)

### Deploying CloudFormation 

In the interest of time and to focus just on the EMR with Spot, we will install everything required to run this workshop using cloudformation. 

1. Download locally this cloudformation stack into a file (**[emr-spark-spot-workshop-quickstarter-cnf.yml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/running_spark_apps_with_emr_on_spot_instances/emr-spark-spot-workshop-quickstarter-cnf.yml)**).

1. Go into the CloudFormation console and select the creation of a new stack. Select **Template is ready**, and then **Upload a template file**, then select the file that you downloaded to your computer and click on **Next**

1. Fill in the **Stack Name** using `emrspot-workshop`, Leave all the settings in the parameters section with the default prarameters and click **Next**

1. In the Configure Stack options just scroll to the bottom of the page and click **Next**

1. Finally in the **Review emrspot-workshop** go to the bottom of the page and tick the `Capabilities` section *I acknowledge that AWS CloudFormation might create IAM resources.* then click **Create stack**

{{% notice warning %}}
The deployment of this stack may take up to 10minutes. You should wait until all the resources in the cloudformation stack have been completed before you start the rest of the workshop. The template deploys resourcess such as (a) An [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace with all the dependencies and IAM privileges to run the workshop (b) All the S3 buckets needed to complete the workshop. 
{{% /notice %}}

### Checking the completion of the stack deployment

One way to check your stack has been fully deployed is to check that all the cloudformation dependencies are green and succedded in the cloudformation dashboard; This should look similar to the state below.

![cnf_output](/images/running-emr-spark-apps-on-spot/prerequisites/cfn_stak_completion.png)

#### Getting access to Cloud9  

In this workshop, you'll need to reference the resources created by the CloudFormation stack.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack name that starts with **mod-** in the list.

2. In the stack details pane, click the **Outputs** tab.

![cnf_output](/images/running-emr-spark-apps-on-spot/cnf_output.png)

It is recommended that you keep this tab / window open so you can easily refer to the outputs and resources throughout the workshop.

{{% notice info %}}
You will notice an additional Cloudformation stack was also deployed to deploy the Cloud9 Workspace, which is the result of the stack that starts with **mod-**.
{{% /notice %}}

#### Launch your Cloud9 workspace

{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted.
Cloud9 requires third-party-cookies. You can whitelist the [specific domains]( https://docs.aws.amazon.com/cloud9/latest/user-guide/troubleshooting.html#troubleshooting-env-loading).
{{% /notice %}}

- Click on the url against `Cloud9IDE` from the outputs
- When it comes up, customize the environment by closing the **welcome tab** and **lower work area**, and opening a new **terminal** tab in the main work area:
![c9before](/images/running-emr-spark-apps-on-spot/c9before.png)

- Your workspace should now look like this:
![c9after](/images/running-emr-spark-apps-on-spot/c9after.png)

- If you like this theme, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark**
in the Cloud9 workspace menu.

You are now ready to **[EMR Instance Fleets](/running_spark_apps_with_emr_on_spot_instances/emr_instance_fleets.html)**

