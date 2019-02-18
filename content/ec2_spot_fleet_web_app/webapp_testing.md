+++
title = "Testing the web app"
chapter = false
weight = 60
+++


### Test the web app

Now that everything is deployed, we can test the simple web application by browsing to the public URL of the Application Load Balancer.

1\. Choose **Load Balancers** in the EC2 console navigation pane. This page shows a list of load balancer types to choose from.

2\. Select your load balancer.

3\. In the **Description** tab below, find the **DNS name** in the **Basic Configuration**, and copy/paste it into a web browser.

4\. The web app should return a simple message such as:

```
hello from i-0bc7e523b09c177cc
```

5\. Refresh the web browser a few times and you should see the message bouncing between the EC2 Spot Instances behind the load balancer.

If you were to put enough stress on the web app, the automatic scaling policy you configured in the previous step would automatically scale up (and back down) the number of Spot Instances in the Spot Fleet to handle the load.