<img src="https://cdn.rawgit.com/hashicorp/terraform-website/master/content/source/assets/images/logo-hashicorp.svg" width="500px">

# terraform-cloudfoundry-kong
Deploys a Kong API gateway to Cloud foundry

# Terraform module registry
The module is [published here](https://registry.terraform.io/modules/philips-labs/kong/cloudfoundry/latest)

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.4 |
| <a name="requirement_cloudfoundry"></a> [cloudfoundry](#requirement\_cloudfoundry) | >= 0.14.1 |
| <a name="requirement_htpasswd"></a> [htpasswd](#requirement\_htpasswd) | >= 0.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_cloudfoundry"></a> [cloudfoundry](#provider\_cloudfoundry) | >= 0.14.1 |
| <a name="provider_hsdp"></a> [hsdp](#provider\_hsdp) | n/a |
| <a name="provider_htpasswd"></a> [htpasswd](#provider\_htpasswd) | >= 0.5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgres"></a> [postgres](#module\_postgres) | philips-labs/postgres-service/hsdp | 0.0.3 |

## Resources

| Name | Type |
|------|------|
| [cloudfoundry_app.kong](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/app) | resource |
| [cloudfoundry_app.kong_api_proxy](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/app) | resource |
| [cloudfoundry_network_policy.kong](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/network_policy) | resource |
| [cloudfoundry_network_policy.kong_api_proxy](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/network_policy) | resource |
| [cloudfoundry_route.kong](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/route) | resource |
| [cloudfoundry_route.kong_api_route](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/route) | resource |
| [cloudfoundry_route.kong_internal](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/route) | resource |
| [htpasswd_password.hash](https://registry.terraform.io/providers/loafoe/htpasswd/latest/docs/resources/password) | resource |
| [local_file.nginx_conf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.nginx_htpasswd](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.deploy](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [archive_file.fixture](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [cloudfoundry_domain.domain](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/domain) | data source |
| [cloudfoundry_domain.internal_domain](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/domain) | data source |
| [cloudfoundry_org.org](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/org) | data source |
| [cloudfoundry_space.space](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/space) | data source |
| [hsdp_config.cf](https://registry.terraform.io/providers/philips-software/hsdp/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_domain_name"></a> [cf\_domain\_name](#input\_cf\_domain\_name) | The CF domain to use for Kong | `string` | `""` | no |
| <a name="input_cf_org_name"></a> [cf\_org\_name](#input\_cf\_org\_name) | The CF Org to deploy under | `string` | n/a | yes |
| <a name="input_cf_space_name"></a> [cf\_space\_name](#input\_cf\_space\_name) | The CF Space to deploy in | `string` | n/a | yes |
| <a name="input_db_json_params"></a> [db\_json\_params](#input\_db\_json\_params) | Optional DB JSON params | `string` | `"{}"` | no |
| <a name="input_db_plan"></a> [db\_plan](#input\_db\_plan) | The Database plan to use | `string` | `"postgres-micro-dev"` | no |
| <a name="input_disk"></a> [disk](#input\_disk) | The amount of Disk space to allocate for Kong (MB) | `number` | `1024` | no |
| <a name="input_docker_password"></a> [docker\_password](#input\_docker\_password) | Docker registry password | `string` | `""` | no |
| <a name="input_docker_username"></a> [docker\_username](#input\_docker\_username) | Docker registry username | `string` | `""` | no |
| <a name="input_enable_postgres"></a> [enable\_postgres](#input\_enable\_postgres) | Enable or disables postgres persistence | `bool` | `false` | no |
| <a name="input_enable_protected_admin_api"></a> [enable\_protected\_admin\_api](#input\_enable\_protected\_admin\_api) | Enables the ADMIN API for use by e.g. Kong provider | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment variables for Kong app | `map(any)` | `{}` | no |
| <a name="input_hostnames"></a> [hostnames](#input\_hostnames) | The list of hostnames to use for the gateway | `list(string)` | `[]` | no |
| <a name="input_kong_declarative_config_string"></a> [kong\_declarative\_config\_string](#input\_kong\_declarative\_config\_string) | Declarative configuration json for Kong. To be provided while running in db less declarative mode | `string` | `"{\"_format_version\":\"1.1\", \"services\":[{\"host\":\"go-hello-world.eu-west.philips-healthsuite.com\",\"port\":443,\"protocol\":\"https\", \"routes\":[{\"paths\":[\"/\"]}]}],\"plugins\":[{\"name\":\"prometheus\"}]}"` | no |
| <a name="input_kong_image"></a> [kong\_image](#input\_kong\_image) | Kong Docker image to use | `string` | `"kong/kong:2.6.0"` | no |
| <a name="input_kong_nginx_worker_processes"></a> [kong\_nginx\_worker\_processes](#input\_kong\_nginx\_worker\_processes) | Number of worker processes to use. When increase this, also increase memory allocation | `number` | `4` | no |
| <a name="input_kong_plugins"></a> [kong\_plugins](#input\_kong\_plugins) | List of plugins to load | `list(string)` | <pre>[<br>  "bundled"<br>]</pre> | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of RAM to allocate for Kong (MB) | `number` | `1024` | no |
| <a name="input_name_postfix"></a> [name\_postfix](#input\_name\_postfix) | The postfix string to append to the hostname, prevents namespace clashes | `string` | `""` | no |
| <a name="input_network_policies"></a> [network\_policies](#input\_network\_policies) | The container-to-container network policies to create with Kong as the source app | <pre>list(object({<br>    destination_app = string<br>    protocol        = string<br>    port            = string<br>  }))</pre> | `[]` | no |
| <a name="input_strategy"></a> [strategy](#input\_strategy) | Deployment strategy, 'none' or 'blue-green', default is 'none' | `string` | `"none"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kong_api_endpoint"></a> [kong\_api\_endpoint](#output\_kong\_api\_endpoint) | The API endpoint where Kong admin API reachable on |
| <a name="output_kong_api_password"></a> [kong\_api\_password](#output\_kong\_api\_password) | The API password |
| <a name="output_kong_api_username"></a> [kong\_api\_username](#output\_kong\_api\_username) | The API username |
| <a name="output_kong_app_id"></a> [kong\_app\_id](#output\_kong\_app\_id) | The Kong app id |
| <a name="output_kong_endpoints"></a> [kong\_endpoints](#output\_kong\_endpoints) | The endpoint where Kong is reachable on |

<!--- END_TF_DOCS --->

# Contact / Getting help
Please post your questions on the HSDP Slack `#terraform` channel, or start a [discussion](https://github.com/philips-labs/terraform-cloudfoundry-kong/discussions)

# License
License is MIT
