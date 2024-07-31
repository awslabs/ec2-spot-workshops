---
title: "...at an AWS event"
chapter: false
weight: 10
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}


### Running the workshop at an AWS Event

{{% notice warning %}}
Only complete this section if you are at an AWS hosted event such as re:Invent, public workshop, Immersion Day, or any other event hosted by an AWS employee. If you are running the workshop on your own, then go to [Start the workshop on your own](/running_spark_apps_with_emr_on_spot_instances/self_paced.html) directly.
{{% /notice %}}

### Login to the AWS Workshop Portal

If you are at an AWS event, an AWS account was created for you to use throughout the workshop. You will need the **Participant Hash** provided to you by the event's organizers.

1. Connect to the portal by browsing to [https://dashboard.eventengine.run/](https://dashboard.eventengine.run/).
2. Enter the Hash in the text box, and click **Proceed** 
3. In the User Dashboard screen, click **AWS Console** 
4. In the popup page, click **Open Console** 

You are now logged in to the AWS console in an account that was created for you, and will be available only throughout the workshop run time.

{{% notice info %}}
 The workshop requires an [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace and a S3 buckets as the prerequisites. To save time these pre-requisites and dependencies have been already deployed using this CloudFormation Template (**[emr-spark-spot-workshop-quickstarter-cnf.yml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/running_spark_apps_with_emr_on_spot_instances/emr-spark-spot-workshop-quickstarter-cnf.yaml)**).
{{% /notice %}}

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

