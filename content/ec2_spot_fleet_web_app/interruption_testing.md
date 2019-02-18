+++
title = "Spot Interruption Testing"
chapter = false
weight = 80
+++

### Test the Spot Instance interruption notice handler

In order to test, you can take advantage of the fact that any interruption action that Spot Fleet takes on a Spot Instance results in a Spot Instance interruption notice being provided. Therefore, you can simply decrease the target size of your Spot Fleet from 2 to 1. The instance that is interrupted receives the Spot Instance interruption notice.

1\. Head to **Spot Requests** in the EC2 console navigation pane.

2\. Select your **Spot Fleet request**. 

3\. At the top in the **Actions** dropdown, select **Modify target capacity**.

4\. Set the **New target capacity** to *1*, and click **Submit**. This will now reduce the size of the Spot Fleet request target capacity from *2* to *1*.

5\. Let's watch the Lambda function in action. Click on **Target Groups** in the EC2 console navigation pane.

6\. Select your **Target group**.

7\. Click on the **Targets** tab below.

8\. In a few moments, you should see one of the Registered targets change status to **Draining** (you may have to refresh a few times). This is the Spot Instance that is being artificially interrupted by reducing the Spot Fleet target capacity. It will stay in **Draining** state for *120 seconds* based on the configuration set earlier to match the Spot Instance 2 minute interruption notice.