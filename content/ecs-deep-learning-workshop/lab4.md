+++
title = "Lab-4 Image Classification with MXNet"
weight = 140
+++

Now that you have an MXNet container built and deployed with ECS, you can try out an image classification example provided by MXNet to make sure the framework is working properly. There are two examples you can run through, one for training a model and one for generating a prediction.

**Training:**
\
The first step is to train a model that you can then generate predictions off of later. In this lab, you will use the MNIST database. The MNIST database is a database consisting of handwritten digits very commonly used for training various image processing systems. In the MXNet example for training an MNIST model, there is a python file that runs the training. You will SSH into the same host that already has Jupyter running that you found in step 5 of lab 3, connect to a specific container, and finally run the training command.

First, SSH into the instance:

	$ ssh -i PRIVATE_KEY.PEM ec2-user@EC2_PUBLIC_DNS_NAME

Once logged in, find the container to connect to by running:

	$ docker ps

On the left hand side, you'll find two containers that are running. One for our mxnet container, and one for the amazon-ecs-agent. Note down the CONTAINER_ID of the mxnet image so we can open a bash shell like this:

	$ docker exec -it CONTAINER_ID /bin/bash

Now that you're in the container, you can feel free to navigate around. It should look very similar compared to what you saw in lab 2. Once you're ready, navigate to /root/ecs-deep-learning-workshop/mxnet/example/image-classification/ and run train_mnist.py

	$ cd /root/ecs-deep-learning-workshop/mxnet/example/image-classification/
	
	$ python3 train_mnist.py --lr-factor 1

You will start to see output right away. It will something look like:

	INFO:root:Start training with [cpu(0)]
	INFO:root:Epoch[0] Batch [100]	Speed: 13736.09 samples/sec	Train-accuracy=0.782969
	INFO:root:Epoch[0] Batch [200]	Speed: 12799.08 samples/sec	Train-accuracy=0.910000
	INFO:root:Epoch[0] Batch [300]	Speed: 13594.84 samples/sec	Train-accuracy=0.926094
	INFO:root:Epoch[0] Batch [400]	Speed: 13775.83 samples/sec	Train-accuracy=0.933594
	INFO:root:Epoch[0] Batch [500]	Speed: 13732.46 samples/sec	Train-accuracy=0.937656
	INFO:root:Epoch[0] Batch [600]	Speed: 13788.14 samples/sec	Train-accuracy=0.941719
	INFO:root:Epoch[0] Batch [700]	Speed: 13735.79 samples/sec	Train-accuracy=0.937813
	INFO:root:Epoch[0] Batch [800]	Speed: 13789.07 samples/sec	Train-accuracy=0.944531
	INFO:root:Epoch[0] Batch [900]	Speed: 13754.83 samples/sec	Train-accuracy=0.953750

As you should be able to tell, logging into a machine, then dropping into a shell onto a container isn't the best process to do all of this, and it's very manual. In the prediction section, we will show you a more interactive method of running commands.


### Prediction
\
Since training a model can be resource intensive and a lengthy process, you will run through an example that uses a pre-trained model built from the full [ImageNet](http://image-net.org/) dataset, which is a collection of over 10 million images with thousands of classes for those images. This example is available [here](https://github.com/apache/incubator-mxnet/blob/master/docs/tutorials/python/predict_image.md) and we will create a new Jupyter notebook to go through it.

If you're new to Jupyter, it is essentially a web application that allows you to interactively step through blocks of written code. The code can be edited by the user as needed or desired, and there is a play button that lets you step through the cells. Cells that do not code have no effect, so you can hit play to pass through the cell.

\
1. Open a web browser and visit this URL to access the Jupyter notebook for the demo:

http://__EC2_PUBLIC_DNS_NAME__/tree/mxnet/docs/tutorials/python

\
2. Click on the **New** drop-down button on the right side, and then Python 3 to create a new notebook. 

![Jupyter Notebook - Create](images/ecs-deep-learning-workshop/new-jupyter-notebook.png)

\
3. Then, on the notebook copy and paste the code blocks on the [example](https://github.com/apache/incubator-mxnet/blob/master/docs/tutorials/python/predict_image.md) and click Run to execute each block as you paste it into the cell. The code loads and prepares the pre-trained model as well as provide methods to load images into the model to predict its classification. If you've never used Jupyter before, you're probably wonder how you know something is happening.  Cells with code are denoted on the left with "In [n]" where n is simply a cell number.  When you play a cell that requires processing time, the number will show an asterisk.  

See the following screenshot which illustrates the notebook and the play button which lets you run code on the cells as you paste it. 

![](/images/ecs-deep-learning-workshop/jupyter-notebook-predict.png)

**IMPORTANT**: In the second code block, you will see we are setting the context to cpu, as for this workshop we're using cpu resources. When using an instance type with gpu, it is possible to switch the context to GPU.  Being able to switch between using cpu and gpu is a great feature of this library.  While deep learning performance is better on gpu, you can make use of cpu resources in dev/test environments to keep costs down.  

\
4. Once you've stepped through the two examples at the end of the notebook, try feeding arbitrary images to see how well the model performs. Remember that Jupyter notebooks let you input your own code in a cell and run it, so feel free to experiment.



