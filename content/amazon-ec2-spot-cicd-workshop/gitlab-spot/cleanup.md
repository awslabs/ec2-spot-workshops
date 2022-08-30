+++
title = "Workshop Cleanup"
weight = 60
+++

You will now remove the resources created during the workshop.

1. Return to the browser tab with Cloud9 and perform the following commands in the terminal to remove the Kubernetes ingress, service, and deployment:

```
kubectl delete ingress/spot-demo
kubectl delete service/spot-demo
kubectl delete deployment/spot-demo
```

2. Perform the following commands to remove the Amazon EKS cluster (when asked, use the same parameter values as when you were creating it: Kubernetes version and the VPC ID):

```
cd ~/environment/amazon-ec2-spot-cicd-workshop/gitlab-spot/eks-cluster
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
export TF_VAR_aws_region=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
export TF_VAR_alb_policy=$(aws iam get-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --output text --query Account):policy/AWSLoadBalancerControllerIAMPolicy --query Policy.Arn --output text)
terraform destroy
```

3. When asked if you want to destroy all resources, type `yes` and press Enter. Wait until the process is finished and close your Cloud9 environment.
4. In CloudFormation console delete the stack `linux-docker-scaling-spotonly`.
5. In the IAM console remove the role `GitLabRunner` and the policies `GitLabRunnerPolicy` and `AWSLoadBalancerControllerIAMPolicy`, unless you had it before the workshop.
6. In the ECR console open the repository and remove all images inside it (you do not need to remove the repository itself: it will be done automatically when removing the GitLab stack).
7. In the S3 console find a bucket with `gitlabworkshopc9outputbucket` in its name and remove all objects inside it.
8. If you created the GitLab stack in CloudFormation yourself, remove it too (if you used the one created automatically, you will not be able to delete it, so you can leave it as is).

### Thank you
At this point, we would like to thank you for attending this workshop.