#!/bin/bash
set -e

BUCKET=skehlet-terraformstate

aws s3 mb --region us-west-2 s3://$BUCKET

aws s3api put-bucket-encryption \
    --bucket $BUCKET \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

aws s3api put-bucket-versioning \
    --bucket $BUCKET \
    --versioning-configuration Status=Enabled
