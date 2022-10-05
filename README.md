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
        "cloudformation:CreateStack",
        "iam:PassRole",
        "iam:GetAccountAuthorizationDetails"
    ],
    "Resource": "*"
}
```