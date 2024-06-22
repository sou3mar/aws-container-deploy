# AWS Container Deploy

An IaC (Infrastructure as Code) in [Terraform](https://www.terraform.io/use-cases/infrastructure-as-code), aimed to easily deploy Docker containers on ECS container cluster as tasks and run them on auto-scaling EC2 instances on AWS platform.

This IaC will provision these items end-to-end:

-   Networking (VPC, Subnets, Security Groups, NAT, Internet Gateway, Route Tables and associations)
-   Cluster (ECS Service, Task Definition, Container Instance, Launch Template)
-   EC2 (Auto-scaling Instances)
-   Database (RDS MySQL Instance, Elasticache Redis Instance)
-   Permission (IAM Roles and Policies)

## Multi Workspace/Environment

Using [Terragrunt](https://terragrunt.gruntwork.io/) which is a wrapper on top of Terraform, we can achieve a rubost hassle-free multi-env deployment on the same AWS account.

You may create a new workspace using: `terragrunt workspace new <WORKSPACE_NAME>`

Make sure to switch into the fresh workspace using: `terragrunt workspace select <WORKSPACE_NAME>`

## Networking

There are two subnets for the app layer (container): [`app_subnet1`, `app_subnet2`] and two available for the database layer: [`db_subnet1`, `db_subnet2`]

`app_subnet1` is a PUBLIC subnet and is routed to the Internet Gateway, providing public internet access to EC2 instance(s). Public IPv4 will be automatically assigned through the deployment process. Container networking is set to `host`, thus, it follows the networking of the instance it's running on.

Other subnets are PRIVATE and are routed to a NAT.

### Security Groups

There are Security Groups defined for each demanding resource:

-   ECS Instance: Accepts inbounding `TCP` connections on ports: `80`, `443` & `22` and allows any outbounding traffic.
-   RDS: Accepts inbounding `TCP` connections on port: `3306` and allows any outbounding traffic.
-   Elastichache (Redis): Accepts inbounding `TCP` connections on port: `6379` and allows any outbounding traffic.

You may edit these rules based on your requirements in `network.tf` file.

## Prerequisites

1.  Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) & [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

2.  `export AWS_PROFILE=<PROFILE>` // "default" profile will be used unless specified on each new terminal session

3.  Copy `dev.sample.tfvars` to `dev.tfvars` and fill in the required variables based on what you require.

4.  Provide required resources by Terraform to handle the state (Backend):

    -   Create a _DynamoDB table_. e.g. `terraform-deployments`. This is where the track record of the state files are stored.
    -   Create a _S3 Bucket_. e.g. `terraform-deployments`. This is where the state files (`terraform.tfstate`) are stored.

    These resources can be configured inside the `terragrunt.hcl` file located in each environment directory. e.g. `dev/terragrunt.hcl`. Modify the `region` if needed.

```
generate "backend" {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
    terraform {
        backend "s3" {
            bucket = "terraform-deployments"
            key = "terraform.tfstate"
            region = "ap-southeast-2"
            dynamodb_table = "terraform-deployments"
            encrypt = true
        }
    }
EOF
}
```

5.  Run `terragrunt init` to download and init the required provider (AWS).

6.  Create a new workspace if it's not already available, using: `terragrunt workspace new dev`

7.  Select wokspace using: `terragrunt workspace select dev`

8.  (Optional) Check if environment is correctly selected: `terragrunt workspace show // result should be "dev"`

9.  (Optional) Run `terragrunt plan` to see what changes will be made.

10. Run `terragrunt apply` to apply the changes on your account.
