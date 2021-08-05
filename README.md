<img src="https://cdn.rawgit.com/hashicorp/terraform-website/master/content/source/assets/images/logo-hashicorp.svg" width="500px">

# terraform-cloudfoundry-kong
Deploys a Kong API gateway to Cloud foundry

# example usage

```hcl
module "kong" {
  source = "github.com/philips-labs/terraform-cloudfoundry-kong"

  cf_org       = "hsdp-demo-org"
  cf_space     = "test"
  cf_domain    = "us-east.philips-healthsuite.com"
  name_postfix = "test"

  environment = {
    "KONG_PROXY_ACCESS_LOG" = "/dev/stdout" 
    "KONG_ADMIN_ACCESS_LOG" = "/dev/stdout"
    "KONG_PROXY_ERROR_LOG" = "/dev/stderr" 
    "KONG_ADMIN_ERROR_LOG" = "/dev/stderr" 
  }
}
```

Accessing the `kong` API endpoint can then be done by SSH forward:

```
cf ssh -L 8001:localhost:8001 kong
```

# Terraform module registry
The module is [published here](https://registry.terraform.io/modules/philips-labs/kong/cloudfoundry/latest)

<!--- BEGIN_TF_DOCS --->
<!--- END_TF_DOCS --->

# Contact / Getting help
Please post your questions on the HSDP Slack `#terraform` channel, or start a [discussion](https://github.com/philips-labs/terraform-cloudfoundry-kong/discussions)

# License
License is MIT
