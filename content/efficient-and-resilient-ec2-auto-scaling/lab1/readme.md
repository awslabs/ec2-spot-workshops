To do:
* update wording in setup with cfn page, update cfn template link before **final PR**




sudo -H -u ec2-user bash -c "cd /home/ec2-user/environment && git clone https://github.com/awslabs/ec2-spot-workshops.git"

aws cloudwatch put-metric-data --namespace "Usage Metrics" --metric-data file://metric.json