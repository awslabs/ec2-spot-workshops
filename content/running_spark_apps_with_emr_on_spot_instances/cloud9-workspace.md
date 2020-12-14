---
title: "Create a Workspace"
chapter: false
weight: 15
---

{{% notice warning %}}
If you are running the workshop on your own, the Cloud9 workspace should be built by an IAM user with Administrator privileges, not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}

{{% notice info %}}
If you are at an AWS hosted event, follow the instructions on the region that should be used to launch resources
{{% /notice %}}

{{% notice tip %}}
Ad blockers, javascript disablers, and tracking blockers should be disabled for
the cloud9 domain, or connecting to the workspace might be impacted.
Cloud9 requires third-party-cookies. You can whitelist the [specific domains]( https://docs.aws.amazon.com/cloud9/latest/user-guide/troubleshooting.html#troubleshooting-env-loading).
{{% /notice %}}

### Launch Cloud9:

- Go to [Cloud9 Console](https://console.aws.amazon.com/cloud9/home)
- Select **Create environment**
- Name it **emrworkshop**, and take all other defaults
- When it comes up, customize the environment by closing the **welcome tab**
and **lower work area**, and opening a new **terminal** tab in the main work area:
![c9before](/images/running-emr-spark-apps-on-spot/c9before.png)

- Your workspace should now look like this:
![c9after](/images/running-emr-spark-apps-on-spot/c9after.png)

- If you like this theme, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark**
in the Cloud9 workspace menu.
