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

In order to migrate mysql database files from bcodmo1-internal, you need to:

1. Update the RDS instance to be publicly accesible
2. Log onto bcodmo1-internal, and go to  `/data/projects/redmine/backups/mysql`
3. Run the command:
```
 # replace hostname if relevant
 gunzip -c <latest_backup>.gz | mysql -u admin --password=<rds_password> --port=3306 -h redmine.cbv8y0by9pmj.us-east-1.rds.amazonaws.com redmine

```

To migrate the files from redmine to S3:

1. Log into bcodmo-internal and go to /data/projects/redmine/redmine/files/
2. Run `aws s3 cp /data/projects/redmine/redmine s3://bcodmo-redmine –recursive
