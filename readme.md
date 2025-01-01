## What we are doing now
- create an s3 buckets that will be used as remote backend for the terraform project state <br>
`aws s3 mb s3://kafka-infrastructure-state --region us-east-1` 
- Enable Versioning on the S3 Bucket: aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled
- create a dynamodb table  <br>
```
aws dynamodb create-table \
--table-name tfremotestate-infrastructure \
--attribute-definitions AttributeName=LockID,AttributeType=S \
--key-schema AttributeName=LockID,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```
- create a terraform project and configure the backend
- create docker compose file
- create ecs task definition based off of the previous docker compose file
- retrieve the json content of the container definition, set it in the terraform script
- apply the terraform script