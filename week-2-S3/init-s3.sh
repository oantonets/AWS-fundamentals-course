#!/bin/sh

if [[ "$1" != "" ]]; then
    BUCKET_NAME="$1"
else
    BUCKET_NAME=lohika-oantonets-2022
fi

# output results of cal command to cal.txt file
cal > cal.txt
date >> cal.txt
aws s3api create-bucket --acl private --bucket $BUCKET_NAME --region us-east-1
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
aws s3api put-object --bucket $BUCKET_NAME --key cal.txt --body ./cal.txt --acl bucket-owner-full-control


# aws s3 rm s3://$BUCKET_NAME --recursive
# --------- bucket cen be deleted only after deleting all versions("empty" bucket)
# aws s3api delete-bucket --bucket $BUCKET_NAME