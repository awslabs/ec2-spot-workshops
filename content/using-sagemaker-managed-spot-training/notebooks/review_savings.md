---
title: "Understanding and Reporting on Savings"
chapter: false
weight: 50
---

### During Notebook Execution

As you were working through the example notebooks, and running your training jobs, you may have reviewed the achieved cost savings with Managed Spot Training and seen output similar to the following in your Notebook execution.


```
Training seconds: 80
Billable seconds: 25
Managed Spot Training savings: 68.8%
```

### From the Console

In addition to viewing within the context of a Notebook, you can view each training job individually to see the achieved cost savings.

1. Open the Amazon SageMaker Console.
2. Navigate to the ***Training jobs*** link located under ***Training*** in the menu bar on the left hand side of the console. ![SageMaker Training Jobs](/images/using-sagemaker-managed-spot-training/cost-1.png)
3. Click on a completed training job. ![SageMaker Training Jobs](/images/using-sagemaker-managed-spot-training/cost-2.png)
4. View the achieved cost savings over On-Demand by leveraging Managed Spot Training and running your training jobs on EC2 Spot Instances. ![SageMaker Training Jobs](/images/using-sagemaker-managed-spot-training/cost-3.png)

### Manually

You can calculate the savings from using managed spot training using the formula (1 - BillableTimeInSeconds / TrainingTimeInSeconds) * 100. 

For example, if BillableTimeInSeconds is 100 and TrainingTimeInSeconds is 500, the savings is 80%.
