---
title: "Increasing resilience"
date: 2018-08-07T08:30:11-07:00
weight: 60
---


#### Challenge

As oppose to the stateless web application that we deployed previously in the workshop, Jenkins jobs are not fault-tolerant, meaning that an EC2 Spot interruption on an instance that is running a job, will cause the job to fail. 
Is there anything we can do to decrease the chances of having Spot interruptions, when EC2 needs the capacity back?\
Hint: read or skim through the following [article] (https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/)

{{%expand "Click here for the answer" %}}

Previously, we used the lowest-price Spot allocation strategy, by selecting a large number of `spotInstancePools` in our nodegroups configuration, in order to deploy our applications on a diversified set of the cheapest EC2 Spot instance types. We did this for the purpose of decreasing the blast radius in case Spot Interruptions occur - which will only terminate a small portion of our instances, due to the diversification. However, since Jenkins job oriented workloads are not fault-tolerant and an EC2 Spot interruption would cause the build job to fail, we can choose the capacity-optimized allocation strategy which will provision Spot Instances for us from the capacity pools that have the lowest chances of being interrupted. This way, we increase the chances of successfully completing our Jenkins jobs when running on Spot Instances.

{{% /expand %}}

\
\

#### How to configure the capacity-optimized allocation strategy when using eksctl
You might be wondering why we still have `spotInstancePools` in the nodegroup configuration yml from the last step, and no indication of the capacity-optimized allocation strategy configuration. The reason is that currently, eksctl still does not support the creation of nodegroups that have the capacity-optimized allocation strategy configured. Since we do want our nodegroup to use this allocation strategy in order to minimize chances of Spot interruptions and increase the jobs' resilience, we can make this change manually.


{{% notice note %}}
Of course, in a real-world scenario we will not make manual changes to our production environments. However, in this educational setting we can bypass the eksctl limitation with a manual modification. This will also give you a chance to get acquainted with the different options that exist in the Management Console for EC2 Auto Scaling groups.\
Rest assured, once eksctl supports this configuration, the workshop will be modified to indicate it.\
If you are using CloudFormation or Terraform for your production EKS clusters (outside of this workshop), then this should not be a concern.
{{% /notice %}}

#### Modifying the EC2 Auto Scaling group's Spot allocation strategy
1\. Browse to the EC2 Management Console -> **Auto Scaling Groups** and find the new Jenkins nodegroup by using the filter field\
2\. With the Jenkins ASG checked, click **Actions** -> **Edit**\
3\. Scroll down, and under **Spot Allocation Strategy** Modify the selection to **Launch Spot Instances optimally based on the available Spot capacity per Availability Zone**, click **Save**

**Note**: There's already one instance type running in the ASG, let's terminate it and let the ASG provision a new instance using the new allocation strategy.
\

4\. Still in the ASG console, in the bottom page, click the **Instances** tab -> click the Instance ID.\
5\. In the EC2 console, with the Instance selected, click **Actions** -> **Instance State** -> **Terminate**.\
6\. Within 1-2 minutes, ASG will run a new instance to meet the desired capacity of 1.\

**Question**: Is the new instance type in the ASG different than the one that existed before? if so, it means that the previous instance type was selected as the cheapest option, while the new instance type was selected from the capacity pool which is least likely to be interrupted.


#### Increasing resilience: Automatic Jenkins job retries
We can configure Jenkins to automatically retry running jobs in case of failures. One possible failure would be when a Jenkins agent is running a job on an EC2 Spot Instance that is going to be terminated due to an EC2 Spot Interruption, when EC2 needs the capacity back. To configure automatic retries for jobs, follow these steps:

1. In the Jenkins dashboard, browse to **Manage Jenkins** -> **Manage Plugins** -> **Available** tab
2. In the filter field, enter **Naginator**. [Click here] (https://wiki.jenkins.io/display/JENKINS/Naginator+Plugin) to learn more about this plugin in the Jenkins website.
3. Check the box next to the Naginator result and click **Install without restart**
4. In the next page, check the box next to **Restart Jenkins when installation is complete and no jobs are running box**


{{% notice note %}}
The Naginator plugin, and automatic retries in general, might not be a good fit for your Jenkins jobs or for the way that your organization does CI/CD. It is included in this workshop for educational purposes and for demonstrating increased resilience to handle Spot Instance interruptions. For more complex retries in Jenkins pipelines, look into the [Jenkins Job DSL] (https://github.com/jenkinsci/job-dsl-plugin/wiki/Tutorial---Using-the-Jenkins-Job-DSL)
{{% /notice %}}

Wait for Jenkins to finish restarting, login to the dashboard again, and continue to the next step in the workshop.