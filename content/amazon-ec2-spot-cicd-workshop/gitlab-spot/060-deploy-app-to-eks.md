+++
title = "Installing the demo app into Amazon EKS"
weight = 60
+++

In this section you will deploy the demo application you built earlier in the new Amazon EKS cluster deployed fully on spot instances.

1. In the Cloud9 file tree on the left open file `amazon-ec2-spot-cicd-workshop/gitlab-spot/demo-app/.gitlab-ci.yml` (if you don't see it, make sure you have enabled the hidden files in [**Workshop Preparation**](010-prep.html)).

2. Change the jobs `deploy_to_eks` and `test_on_eks` to the following ones:
```
deploy_to_eks:
  stage: deploy
  image: registry.gitlab.com/gitlab-org/cloud-deploy/aws-base:latest
  before_script:
    - aws --version
    - aws eks update-kubeconfig --region $REGION --name $K8S_CLUSTER_NAME
    - apt-get install -y gettext # To get envsubst 
    - export KUBECTL_VERSION=v1.23.7
    - curl --silent --location -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
    - chmod +x /usr/local/bin/kubectl
  script:
    - envsubst < k8s_deploy.yaml > k8s_deploy_filled.yaml
    - kubectl apply -f k8s_deploy_filled.yaml
    - kubectl rollout status deploy/spot-demo
    - kubectl get services/spot-demo -o wide
    - kubectl get ingress spot-demo -o wide
    - echo "SERVICE_ADDRESS=$(kubectl get ingress spot-demo -o jsonpath='{.status.loadBalancer.ingress[*].hostname}')" >> deploy_to_eks.env
  artifacts:
    reports:
      dotenv: deploy_to_eks.env

test_on_eks:
  stage: test
  image: registry.gitlab.com/gitlab-org/cloud-deploy/aws-base:latest
  before_script:
    - echo Verifying service on $SERVICE_ADDRESS
  script:
    - |
      echo Waiting for the service to respond with 200
      serviceup=0

      for i in {1..60}
      do
        export result=$(curl -s -o /dev/null -w "%{http_code}" http://$SERVICE_ADDRESS/info/)

        if [[ "$result" -eq 200 ]]
        then
          serviceup=1
          break
        fi

        echo Load balancer not ready yet
        sleep 10
      done

      if [[ "$serviceup" -eq 1 ]]
      then
        echo Service responded with 200
      else
        echo Service not responded within the timeout
        exit 1
      fi

      for i in {1..50}
      do
        echo -n "Test $i: "
        export result=$(curl -s http://$SERVICE_ADDRESS/info/ | egrep 'lifecycle.*spot' | wc -l)
        if [[ "$result" -eq 1 ]]
        then
          echo -e "\033[0;32mOK\033[0m"
        else
          echo -e "\033[0;31mNOT OK\033[0m"
          exit 1
        fi
      done
  dependencies:
    - deploy_to_eks
```

3. Save the file, using **Ctrl + S** or **Cmd + S** depending on your Operating System, or choosing **File** > **Save**. Then close it.

4. Create a new commit with the updated file and push it to the origin:
```
cd ~/environment/amazon-ec2-spot-cicd-workshop/gitlab-spot/demo-app/
git add .gitlab-ci.yml
git commit -m "Added deployment to EKS"
git push
```

5. Return to the browser tab with GitLab and in the navigation pane choose **CI/CD** > **Pipelines**.

6. Make sure that the CI/CD pipeline is successfully completed or wait until it does.

7. You can click on the circle to see the job output. For example, for the right-most one it would show the testing result:
![GitLab Screenshot: GitLab Testing Job output](/images/gitlab-spot/GitLab-TestingJob.png)

8. Return to the Cloud9 tab and print the information about the new service:
```
echo http://$(kubectl get ingress spot-demo -o jsonpath='{.status.loadBalancer.ingress[*].hostname}')/info/
```

9. Open the output URL in a new browser tab and refresh the page several times to make sure that the requests reach pods on different worker nodes, all on spot instances:
![Demo App Screenshot](/images/gitlab-spot/DemoApp.png)


You have deployed the demo application in Kubernetes cluster (created in Amazon EKS service) with all its worker nodes running on Amazon EC2 Spot instances. It is useful for executing tests in your CI/CD pipeline (though AWS customers run full Production clusters on spot instances too): for example, you can add new spot nodes into your cluster right from the pipeline and after finishing testing remove them.

To view the current economy from using spot instances instead of on-demand ones perform the following steps:

1. Return to the browser tab with EC2 console or open it again.
2. Choose **Spot Requests** in the **Instances** section of the navigation pane.
3. Choose **Savings summary**.

You can now clean all the resources created during the workshop using the steps in [**Workshop Cleanup**](070-cleanup.html).