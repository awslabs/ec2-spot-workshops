from flask import Flask, render_template
from flask.ext.cors import CORS, cross_origin
import os
import requests
import json
import signal
import time
import socket
import sys
import boto3
 

def checkSpotTermination():
    URL = "http://169.254.169.254/latest/meta-data/spot/termination-time"
    response = requests.get(URL)
    return (response.status_code == 200)


class Ec2SpotInterruptionHandler:
  def __init__(self):
    signal.signal(signal.SIGINT, self.exit_gracefully)
    signal.signal(signal.SIGTERM, self.exit_gracefully)

  def exit_gracefully(self, signum, frame):
    print("\nReceived {} signal".format(self.signals[signum]))
    if self.signals[signum] == 'SIGTERM':
      print("SIGTERM Signal Received. Let's wrap up..")
    if checkSpotTermination():
      print("The instance got a Spot Notification for termination, this may have")
    

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

 
@app.route('/')
@cross_origin()
def index():
    response = ""
    response +="<head> <title>ECS Spot Workshop</title> </head>"
    response += "<h2>I am a Simple Containerized Web App Running with below Attributes </h2> <hr/>"

    try:
      if checkSpotTermination():
        response += "<h1>This Spot Instance got a Spot notification for interruption </h1> <hr/>"
    
      URL = "http://169.254.169.254/latest/dynamic/instance-identity/document"
      InstanceData = requests.get(URL).json()
      
      instanceId = InstanceData['instanceId']
      response += "<li>My instance_id = {}</li>".format(instanceId)
      lifecycle = getInstanceLifecycle(instanceId, InstanceData['region'])      
      response += "<li>My Instance lifecycle = {}</li>".format(lifecycle)      
      response += "<li>My instance_type = {}</li>".format(InstanceData['instanceType'])      
      response += "<li>My Intance private_ipv4 = {}</li>".format(InstanceData['privateIp'])
      response += "<li>My availability_zone = {}</li>".format(InstanceData['availabilityZone'])      
      response += "<li>My Region = {}</li>".format(InstanceData['region'])  
      
      publicIp = requests.get("http://169.254.169.254/latest/meta-data/public-ipv4")
      response += "<li>My instance_type public_ipv4 = {}</li>".format(publicIp.text)   
      AMIIndexId = requests.get("http://169.254.169.254/latest/meta-data/ami-launch-index")
      response += "<li>My ami_launch_index = {}</li>".format(AMIIndexId.text)
      
      AMIId = requests.get("http://169.254.169.254/latest/meta-data/ami-id")      
      response += "<li>My ami_launch_index = {}</li>".format(AMIId.text)       
      
      MacId = requests.get("http://169.254.169.254/latest/meta-data/mac")
      Mac = MacId.text
      
      URL = "http://169.254.169.254/latest/meta-data/network/interfaces/macs/" + str(MacId.text) + "/subnet-id"
      SubnetId = requests.get(URL)      
      response += "<li>My subnet_id = {}</li>".format(SubnetId.text) 

      URL = "http://169.254.169.254/latest/meta-data/network/interfaces/macs/" + str(MacId.text) + "/vpc-id"
      VPCId = requests.get(URL)      
      response += "<li>My vpc_id = {}</li>".format(VPCId.text) 

      ECS_METADATA_URI = os.getenv('ECS_CONTAINER_METADATA_URI_V4')
      container = requests.get(ECS_METADATA_URI).json()
      
      response += "<li>My  DockerId  = {}</li>".format(container['DockerId'])
      response += "<li>My  Name  = {}</li>".format(container['Name'])  
      response += "<li>My  DockerName  = {}</li>".format(container['DockerName'])
      response += "<li>My  Network Mode  = {}</li>".format(container['Networks'][0]['NetworkMode'])        
      response += "<li>My  IPs  = {}</li>".format(container['Networks'][0]['IPv4Addresses'])        

      ECS_METADATA_TASK_URI =  ECS_METADATA_URI + "/task"
      task = requests.get(ECS_METADATA_TASK_URI).json()
      
      response += "<li>My ECS Cluster Name = {}</li>".format(task['Cluster']) 
      response += "<li>My Task Arn = {}</li>".format(task['TaskARN'])
      response += "<li>My Task Family:Version = {}:{}</li>".format(task['Family'], task['Revision'])

    except Exception as inst:
      response += "<li>Oops !!! Failed to access my instance  metadata with error = {}</li>".format(inst)

    return response

def getInstanceLifecycle(instanceId, region):
  ec2client = boto3.client('ec2', region_name=region)
  describeInstance = ec2client.describe_instances(InstanceIds=[instanceId])
  instanceData=describeInstance['Reservations'][0]['Instances'][0]
  if 'InstanceLifecycle' in instanceData.keys():
    return instanceData['InstanceLifecycle']
  else:
    return "Ondemand"


if __name__ == '__main__':
    handler = Ec2SpotInterruptionHandler()
    print("Starting A Simple Web Service ...")
    app.run(port=80,host='0.0.0.0')
