+++
title = "Building the demo app"
weight = 40
+++

In this lab you will push the changes to your origin repository and verify that the pipeline has successfully finished both in GitLab and by checking the image in Amazon ECR.

1. Return to the browser tab with Cloud9 and execute the following command in the terminal. Specify `root` as the username and the same password you used in [**Create a GitLab repository**](020-create-gitlab-repo.html) to log in to GitLab:

```
git push -u origin main
```

2. Return to the browser tab with GitLab and in the navigation pane choose **CI/CD** > **Pipelines**.
3. Make sure that the CI/CD pipeline is successfully completed or wait until it does. If there were any issues, open the failed stage by clicking the corresponding circle and check the detailed execution log:

![GitLab Screenshot: Build pipeline completed](/images/gitlab-spot/GitLab-BuildPipeline.png)

4. Return to the browser tab with AWS Console.
5. Type `ECR` in the search box at the top and open the **Elastic Container Registry** service.
6. Open the repository with **gitlab-spot-demo** in its name and verify that it contains an image that has just been built in GitLab:

![ECR Console Screenshot: Images](/images/gitlab-spot/AWSConsole-ECRImages.png)

You have successfully built the image and can now proceed to [**Deploying Amazon EKS on Spot instances**](050-deploying-eks-on-spot.html).

### Challenges

If this and previous sections of the workshop seemed too easy, try completing the following challenges:

**Challenge 1:** Configure shared runners for the whole GitLab CI/CD and not just the current repository. Create an additional repository and verify that your runners serve it too.

{{%expand "Click to reveal a hint" %}}
Open the Admin Area of GitLab interface and in the Runners section get the registration code. Use it instead of the one from the project.
{{% /expand%}}

**Challenge 2:** Trigger auto-scaling of the instances to get more runners created.

{{%expand "Click to reveal a hint" %}}
By default, auto-scaling is done by CPU load, so you can run a CPU load generator inside your build scripts to simulate it, for example, you can use `stress` or `stress-ng` tools for this.
{{% /expand%}}

**Challenge 3:** Modify the auto-scaling group to perform scaling by the number of the jobs instead of the CPU load.

{{%expand "Click to reveal a hint" %}}
Create a Lambda function that gets the number of jobs from [GitLab API](https://docs.gitlab.com/ee/api/jobs.html#list-project-jobs) and publishes it as a custom CloudWatch metric. Use this metric to scale the group.
{{% /expand%}}