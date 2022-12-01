# AWS-fundamentals-course
Lohika AWS course

# week-0:
commands to create EC2 instanse from .yml config:
- with default params:
```
aws cloudformation create-stack --stack-name week0-test --template-body file:///Users/oantonets/Documents/learn/AWS/AWS-fundamentals-course/week-0-EC2-template.yml 
```
- with custom InstanceType param:
```
aws cloudformation create-stack --stack-name week0-test --template-body file:///Users/oantonets/Documents/learn/AWS/AWS-fundamentals-course/week-0-EC2-template.yml --parameters ParameterKey=InstanceType,ParameterValue=t2.micro
```

- to delete stack:
```
aws cloudformation delete-stack --stack-name=week0-test
```

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

# week-1:
commands to create stack with resources:
- with default params 
```
aws cloudformation create-stack --stack-name week-1-test  --template-body file:///Users/oantonets/Documents/learn/AWS/AWS-fundamentals-course/week-1-ASG-template.yml
```
- to list all stacks and query for public ip and instance id
```
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[PublicIpAddress, InstanceId]"
```

- to terminate one of the instances:
```
aws ec2 terminate-instances --instance-ids <instance-id>
```

- to connect to instance use public ip
```
ssh -i <key> ec2-user@ec2-<public-ip>.compute-1.amazonaws.com
```

- to delete stack:
```
aws cloudformation delete-stack --stack-name=week-1-test
```

# week-2:
to create file and bucket
- run init-s3.h "backet-name"
pass backed-name as argument or bucket will be created with default name(lohika-oantonets-2022)
- run one of terraform config files to create infracture, connect to instance using ip in the output section.
Check file on instance.

##### You'll need to remove s3 by hand