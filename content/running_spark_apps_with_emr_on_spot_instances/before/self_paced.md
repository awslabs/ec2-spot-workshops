---
title: "...on your own"
chapter: false
weight: 20
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}


## Running the workshop on your own

{{% notice warning %}}
Only complete this section if you are running the workshop **on your own**. If you are at an AWS hosted event such as re:Invent, Kubecon, Immersion Day, etc, then go to [Start the workshop at an AWS event]({{< ref "/running_spark_apps_with_emr_on_spot_instances/before/aws_event.md" >}}).
{{% /notice %}}

To run this workshop you need an AWS account with Administrator or similar privileged access. If you don't already have an AWS account with Administrator access, then you can create a new AWS account by following steps provided in this [getting started guide](https://aws.amazon.com/getting-started/).

### Deploying AWS CloudFormation template

The workshop requires an [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace and a S3 buckets as the prerequisites. To save time you install these prerequisites using a cloudformation template. 

1. Download locally this cloudformation stack into a file (**[emr-spark-spot-workshop-quickstarter-cnf.yml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/running_spark_apps_with_emr_on_spot_instances/emr-spark-spot-workshop-quickstarter-cnf.yaml)**).
2. Go to the [CloudFormation console](https://us-east-1.console.aws.amazon.com/cloudformation/home) and select **With new resources(standard)** option in **Create stack** drop down. 
3. In the **Create stack** stack form in **Prerequisite - Prepare template** section select **Template is ready**.
4. In **Specify template** section select **Upload a template file** and click on **Choose file** button to upload the CloudFormation template you downloaded in step 1. 
5. Enter **Stack Name** `emrspot-workshop` in the **Stack Name**  and leave all the settings in the parameters section with the default parameters and click **Next**
6. In the Configure Stack options just scroll to the bottom of the page and click **Next**
7. Finally in the **Review emrspot-workshop** go to the bottom of the page and tick the **Capabilities section *I acknowledge that AWS CloudFormation might create IAM resources.* then click **Create stack**

{{% notice note %}}
The deployment of this stack may take up to 10 minutes. You should wait until all the resources in the cloudformation stack have been completed before you start the rest of the workshop.  
{{% /notice %}}

### Checking the completion of the stack deployment

One way to check your stack has been fully deployed is to check that all the cloudformation dependencies are green and succeeded in the cloudformation dashboard; This should look similar to the state below.

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

