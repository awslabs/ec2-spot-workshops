+++
title = "Lab 3: Building the demo app"
weight = 50
+++

In this lab you will push the changes to your origin repository and verify that the pipeline has successfully finished both in GitLab and by checking the image in Amazon ECR.

{{%expand "Click to reveal detailed instructions" %}}
1. Return to the browser tab with Cloud9 and execute the following command in the terminal. Specify `root` as the username and the same password you used in [**Lab 1: Create a GitLab repository**](lab1.html) to log in to GitLab:

```
git push -u origin main
```

2. Return to the browser tab with GitLab and in the navigation pane choose **CI/CD** > **Pipelines**.
3. Make sure that the CI/CD pipeline is successfully completed or wait until it does. If there were any issues, open the failed stage by clicking the corresponding circle and check the detailed execution log:

![GitLab Screenshot: Build pipeline completed](/images/gitlab-spot/GitLab-BuildPipeline.png)

4. Return to the browser tab with AWS Console.
5. Type `ECR` in the search box at the top and open the **Elastic Container Registry** service.
6. Open the **gitlab-spot-demo** repository and verify that it contains an image that has just been built in GitLab:

![ECR Console Screenshot: Images](/images/gitlab-spot/AWSConsole-ECRImages.png)

{{% /expand%}}

You have successfully built the image and can now proceed to [**Lab 4: Deploying Amazon EKS on Spot instances**](lab4.html).

### Challenges

If this and previous labs seemed too easy, try completing the following challenges:

**Challenge 1:** Configure shared runners for the whole GitLab CI/CD and not just the current repository. Create an additional repository and verify that your runners serve it too.

**Challenge 2:** If you used the auto-scaling group approach, trigger auto-scaling of the instances to get more runners created (tip: by default, it is done by CPU load, so you can run a CPU load tool inside your build scripts to simulate it).

**Challenge 3:** If you used the auto-scaling group approach, try modifying it to perform scaling by the number of the jobs instead of the CPU load (you will need to create a custom CloudWatch metric for this).