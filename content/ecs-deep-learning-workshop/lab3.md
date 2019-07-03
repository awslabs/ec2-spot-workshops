+++
title = "Lab-3 Deploy the MXNet Container with ECS"
weight = 130
+++

Now that you have an MXNet image ready to go, the next step is to create a task definition. A task defintion specifies parameters and requirements used by ECS to run your container, e.g. the Docker image, cpu/memory resource requirements, host:container port mappings. You'll notice that the parameters in the task definition closely match options passed to a Docker run command. Task definitions are very flexible and can be used to deploy multiple containers that are linked together- for example, an application server and database. In this workshop, we will focus on deploying a single container.

\
1. Open the EC2 Container Service dashboard, click on **Task Definitions** in the left menu, and click **Create new Task Definition**. Then select **EC2** as launch type compatibility.

*Note: You'll notice there's a task definition already there in the list. Ignore this until you reach lab 5.*

\
2. First, name your task definition, e.g. "mxnet". If you happen to create a task definition that is a duplicate of an existing task definition, ECS will create a new revision, incrementing the version number automatically.

\
3. Next, click on Add container and complete the fields in the Add container window; for this lab, you will only need to complete the Standard fields.

Provide a name for your container, e.g. "mxnet". Note: This name is functionally equivalent to the "--name" option of the Docker run command and can also be used for container linking.

The image field is the container image that you will be deploying. The format is equivalent to the registry/repository:tag format used in lab 2, step 6, i.e. **AWS_ACCOUNT_ID**.dkr.ecr.**AWS_REGION**.amazonaws.com/**ECR_REPOSITORY**:latest.

Finallly, set the Memory Limits to be a Soft Limit of "2048" and map the host port 80 to the container port 8888. Port 8888 is the listening port for the Jupter notebook configuration, and we map it to port 80 to reduce running into issues with proxies or firewalls blocking port 8888 during the workshop. You can leave all other fields as default. Click **Add** to save this configuration and add it to the task defintion. Click **Create** to complete the task definition creation step.

![](/images/ecs-deep-learning-workshop/task-def.png)

\
4. Now that you have a task definition created, you can have ECS deploy an MXNet container to your EC2 cluster using the Run Task option. In the **Actions** dropdown menu, select **Run Task**.

Choose your ECS Cluster from the dropdown menu. If you have multiple ECS Clusters in the list, you can find your workshop cluster by referring to the **ecsClusterName** value from the CloudFormation stack Outputs tab. You can leave all other fields as default. Keep number of tasks set to 1 and click **Run Task**.

ECS is now running your MXNet container on an ECS cluster instance with available resources. If you run multiple tasks, ECS will balance out the tasks across the cluster, so one cluster instance doesn't have a disproportionate number of tasks.

\
5. On the Cluster detail page, you'll see a Tasks tab towards the bottom of the page. Notice your new task starts in the Pending state. Click on the refresh button after about 30 seconds to refresh the contents of that tab, repeating the refresh until it is in the Running state. Once the task is in the Running state, you can test accessing the Jupyter notebook. In addition to the displaying the state of the task, this tab also identifies which container instance the task is running on. Click on the Container Instance and you'll see the Public DNS of the EC2 instance on the next page.

![](/images/ecs-deep-learning-workshop/task-run.png)

\
6. Open a new web browser tab and load the public DNS name to test Jupyter loads properly - http://**EC2_PUBLIC_DNS_NAME**.

\
7. You should be prompted for the password you passed in earlier as a build-arg. Enter the password and you should be able to log in.

![](/images/ecs-deep-learning-workshop/jupyter-login.png)
