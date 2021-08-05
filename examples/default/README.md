# Kong module default example

This module shows how to use the Kong module.

# Usage

## Configure

You will need to supply some a number of configuration items.

```shell
export TF_VAR_cf_region="eu-west"
export TF_VAR_cf_org_name="your-cf-org"
export TF_VAR_cf_space_name="your-cf-space"
export TF_VAR_cf_username="your-cf-username"
export TF_VAR_cf_password="your-cf-password"
```


## Deploy

```shell
terraform init
terraform apply
```
