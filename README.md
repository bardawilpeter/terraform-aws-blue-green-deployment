# Blue/Green Deployment on AWS ECS with Terraform

Welcome to the Blue/Green Deployment project for AWS Elastic Container Service (ECS) using Terraform. This repository provides Terraform scripts to set up a blue/green deployment pipeline on AWS ECS, allowing you to seamlessly transition between application versions with minimal downtime.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following prerequisites in place:
- An AWS account with the necessary permissions.
- Terraform installed on your local machine.
- AWS CLI configured with your credentials.

### Running the Terraform Code

1. Initialize your Terraform project by navigating to the Terraform directory and running:

```bash
terraform init
```

2. Apply the Terraform configuration to create the necessary AWS resources:

```bash
terraform apply
```

## Testing Your Deployment

After applying your Terraform configurations:

1. Retrieve the ALB DNS name from the Terraform output.
2. Open a web browser and enter the ALB DNS name.
3. You should see the NGINX welcome page or your application's specific content.
4. This validates the successful deployment of your ECS service and proper configuration of your ALB.

## Validating Blue/Green Deployment with a New Task Definition

To test the blue/green deployment process, we'll introduce a new task definition using the `httpd` image, and then deploy it using AWS CodeDeploy. This step is crucial to confirm that our setup properly handles the transition between two different application versions.

**Creating a New Task Definition with httpd Image**
We'll create a new task definition, this time using the `httpd` image. This represents a new version of your application. Here's the JSON for the new task definition:

```
{
    "family": "my-ecs-task",
    "networkMode": "awsvpc",
    "containerDefinitions": [
        {
            "name": "my-container",
            "image": "httpd:latest",
            "cpu": 10,
            "memory": 512,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ]
        }
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "256",
    "memory": "512"
}
```

**Registering the Task Definition with AWS ECS**
Once you have defined your new task, you need to register it with ECS. Use the AWS CLI to register the task definition:

```
aws ecs register-task-definition --cli-input-json file://path-to-your-task-definition.json
```
**Deploying with AWS CodeDeploy**
Next, initiate a deployment using AWS CodeDeploy. We'll specify the new task definition in the `appspec.yaml` file.

Example appspec.yaml:

```
applicationName: 'my-codedeploy-app'
deploymentGroupName: 'my-codedeploy-group'
revision:
  revisionType: AppSpecContent
  appSpecContent:
    content: |
      version: 0.0
      Resources:
        - TargetService:
            Type: AWS::ECS::Service
            Properties:
              TaskDefinition: "[LATEST_TASK_DEFINITION_ARN]" # Replace with your new task definition ARN
              LoadBalancerInfo:
                ContainerName: "my-container"
                ContainerPort: 80

```
Be sure to replace the task definition ARN with the one for your new httpd based task.

**Running the Deployment**
Deploy using the AWS CLI:

```
aws deploy create-deployment --cli-input-yaml file://appspec.yaml
```

**Verifying the Deployment**
Monitor the deployment in the AWS CodeDeploy console. Once it completes, visit the ALB DNS link again. You should now see the httpd welcome page, confirming the successful blue/green deployment with the new version of your application.

For a detailed walkthrough of this project, please refer to the [article on dev.to](https://dev.to/bardawilpeter/zero-downtime-deployments-with-aws-and-terraform-182f).
