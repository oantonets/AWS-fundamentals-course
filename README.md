# AWS-fundamentals-course
Lohika AWS course

# week-0:
commands to create EC2 instanse from .yml config:
- with default params:
```
aws cloudformation create-stack --stack-name week0-test --template-body file:///Users/oantonets/Documents/learn/AWS/AWS-fundamentals-course/week-0-EC2-template.yml 
```
- with custom InstanceType param:
aws cloudformation create-stack --stack-name week0-test --template-body file:///Users/oantonets/Documents/learn/AWS/AWS-fundamentals-course/week-0-EC2-template.yml --parameters ParameterKey=InstanceType,ParameterValue=t2.micro

to delete stack:
aws cloudformation delete-stack --stack-name=week0-test

###### note that you'll need these permissions to make it work:
```
{
    "Effect": "Allow",
    "Action": [
        "cloudformation:DeleteStackInstances",
        "cloudformation:DeleteResource",
        "cloudformation:UpdateResource",
        "cloudformation:GetResourceRequestStatus",
        "cloudformation:ListResourceRequests",
        "cloudformation:DeleteStackSet",
        "cloudformation:ListResources",
        "cloudformation:CancelResourceRequest",
        "cloudformation:GetResource",
        "cloudformation:CreateStack",
        "cloudformation:DeleteStack",
        "cloudformation:CreateResource",
        "iam:GetAccountAuthorizationDetails",
        "iam:PassRole",
        "ec2:RunInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:TerminateInstances",
        "ssm:GetParameters"
    ],
    "Resource": "*"
}
```
