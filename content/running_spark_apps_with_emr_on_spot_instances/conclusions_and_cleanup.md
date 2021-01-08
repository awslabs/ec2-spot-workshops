---
title: "Conclusions and cleanup"
weight: 150
---

**Congratulations!** you have reached the end of the workshop. In this workshop, you learned about the need to be flexible with EC2 instance types when using Spot Instances, and how to size your Spark executors to allow for this flexibility. You ran a Spark application solely on Spot Instances using EMR Instance Fleets, you verified the results of the application, and saw the cost savings that you achieved by running the application on Spot Instances.


#### Cleanup

Select the correct tab, depending on where you are running the workshop:
{{< tabs name="EventorOwnAccount" >}}
    {{< tab name="In your own account" include="cleanup_ownaccount" />}}
    {{< tab name="In an AWS event" include="cleanup_event.md" />}}
{{< /tabs >}}


#### Thank you

We hope you found this workshop educational, and that it will help you adopt Spot Instances into your Spark applications running on Amazon EMR, in order to optimize your costs.  
If you have any feedback or questions, click the "**Feedback / Questions?**" link in the left pane to reach out to the authors of the workshop.

#### Other Resources:
Visit the [**Amazon EMR on EC2 Spot Instances**] (https://aws.amazon.com/ec2/spot/use-case/emr/) page for more information, customer case studies and videos.  
Read the blog post: [**Best practices for running Apache Spark applications using Amazon EC2 Spot Instances with Amazon EMR**] (https://aws.amazon.com/blogs/big-data/best-practices-for-running-apache-spark-applications-using-amazon-ec2-spot-instances-with-amazon-emr/)  
Watch the AWS Online Tech-Talk: [**Best Practices for Running Spark Applications Using Spot Instances on EMR - AWS Online Tech Talks**] (https://www.youtube.com/watch?v=u5dFozl1fW8)
