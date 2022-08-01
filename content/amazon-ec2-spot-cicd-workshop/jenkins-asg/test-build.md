+++
title = "Configure a Build Job to use Spot"
weight = 120
+++
As alluded to in the previous section, you'll need to configure your build jobs so that they are executed on the build agents running in your Spot instances. In addition, you could configure jobs to execute concurrent builds if necessary - this will help you in testing the scale-out of your fleet.

1. Go back to the Jenkins home screen and **repeat the following for each of the five Apache build projects** that are configured in your Jenkins instance:
    1. Click on the title of the build job and then click on the **Configure** link toward the left side of the screen;
    2. In the General section, click on the **Execute concurrent builds if necessary** checkbox and the **Restrict where this project can be run** checkbox. Next, enter **spot-agents** as the Label Expression (Note: if you select the auto-complete option instead of typing out the full label, Jenkins will add a space to the end of the label - be sure to remove any trailing spaces from the label before proceeding);
    3. Click on the **Save** button towards the bottom of the screen.

## Test Spot Builds and Scale-out
Now it’s time to test out how Jenkins handles pushing builds to spot instances running build agents at scale. There are two things that you'll want to verify here; that your builds run successfully on the Spot instances, and that your ASG scales out when there are build jobs queued for more than a few minutes.

1. Go Back to the Jenkins home page, click on the **Schedule a Build** icon (which looks like a play symbol) for each of the five Apache projects, starting from the **Apache PDFBox** project and working upward. This will queue up five build jobs, the first of which will be immediately assigned to the Spot instance to be worked on;
2. When any of the build jobs have been completed, click on the **Schedule a Build** icon corresponding to that job to re-add it back to the build queue - the intent here is to keep the build queue populated with a backlog of build jobs until your Spot Fleet has scaled out and build jobs are executing on both Spot instances;
3. After a couple of minutes (typically during the first **Apache Helix** build - around four minutes after you initiate the first build), the EC2 Fleet Status reported to the left of the screen will increment the **target** count to 2, indicating that the plugin has requested a scale-out action from the plugin. After a few moments, a second build instance will appear in the **Build Executor Status**, though this build agent will initially appear to be offline. Once the instance has had the chance to complete the launch and bootstrapping processes (which takes around two minutes), your Jenkins Master will deploy the build agent to it via SSH, and it will come online and process the next build job in the queue. Once you have concurrent builds being executed on two Spot instances, you can stop adding build jobs to the build queue;
4. After a period of around a five minutes after your builds have completed, one of the Spot instances should be terminated by the plugin - there's no need to wait for this to happen (take our word for it, but you can verify this later).