terraform {
  source = "../"

  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()

    optional_var_files = [
      "dev.tfvars"
    ]
  }
}


generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform-deployments"
    key            = "terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-deployments"
    encrypt        = true
  }
}
EOF
}

inputs = {
  aws_region = "ap-southeast-2"
}