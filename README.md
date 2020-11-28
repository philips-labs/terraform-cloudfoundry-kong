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
cf ssh -L8001:localhost:8001 kong
```

# Contact / Getting help
andy.lo-a-foe@philips.com

# License
License is MIT

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.4 |
| cloudfoundry | >= 0.1206.0 |

## Providers

| Name | Version |
|------|---------|
| cloudfoundry | >= 0.1206.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cf\_domain | The CF domain to use for Kong | `string` | n/a | yes |
| cf\_org | The CF Org to deploy under | `string` | n/a | yes |
| cf\_space | The CF Space to deploy in | `string` | n/a | yes |
| db\_broker | The Database broker to use for requesting a PostgreSQL database | `string` | `"hsdp-rds"` | no |
| db\_json\_params | Optional DB JSON params | `string` | `"{}"` | no |
| db\_plan | The Database plan to use | `string` | `"postgres-micro-dev"` | no |
| disk | The amount of Disk space to allocate for Kong (MB) | `number` | `1024` | no |
| enable\_konga | Enable or disables Konga dashboard | `bool` | `true` | no |
| enable\_postgres | Enable or disables postgres persistence | `bool` | `true` | no |
| environment | Environment variables for Kong app | `map` | `{}` | no |
| kong\_image | Kong Docker image to use | `string` | `"kong"` | no |
| konga\_environment | Environment variables for Kong app | `map` | `{}` | no |
| konga\_image | Konga dashboard image to use | `string` | `"pantsel/konga"` | no |
| memory | The amount of RAM to allocate for Kong (MB) | `number` | `512` | no |
| name\_postfix | The postfix string to append to the hostname, prevents namespace clashes | `string` | `""` | no |
| network\_policies | The container-to-container network policies to create with Kong as the source app | <pre>list(object({<br>    destination_app = string<br>    protocol        = string<br>    port            = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| kong\_endpoint | The endpoint where Kong is reachable on |
