# redmine_terraform
Terraform scripts for redmine architecture

To update the ECR docker container, use the deploy.sh script in the parent folder

Use `terraform workspace select production` to deploy to production

You will need to manually create the state bucket and dynamoDB table in the AWS web UI. See backend.tf file for information about those resources. After that you'll need to import those resources like:

```
terraform import aws_dynamodb_table.terraform_locks redmine-terraform-locks;
terraform import aws_s3_bucket.terraform_state bcodmo-redmine-terraform-state;
```

You will need to import the https certificate. For example:

```
terraform import aws_acm_certificate.cert arn:aws:acm:us-east-1:504672911985:certificate/7d76e817-d2dc-44e6-902c-d9cb8898e6f2
```

