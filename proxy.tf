resource "random_id" "id" {
  byte_length = 8
}


data "archive_file" "fixture" {
  type        = "zip"
  source_dir  = "${path.module}/nginx-reverse-proxy"
  output_path = "${path.module}/nginx-reverse-proxy.zip"
  depends_on  = [local_file.nginx_conf, local_file.nginx_htpasswd]
}

resource "cloudfoundry_app" "kong_api_proxy" {
  count            = var.enable_protected_admin_api ? 1 : 0
  name             = "kong-api-proxy"
  space            = data.cloudfoundry_space.space.id
  memory           = 128
  disk_quota       = 512
  path             = "${path.module}/nginx-reverse-proxy.zip"
  buildpack        = "https://github.com/cloudfoundry/nginx-buildpack.git"
  source_code_hash = data.archive_file.fixture.output_base64sha256

  routes {
    route = cloudfoundry_route.kong_api_route[0].id
  }

  depends_on = [data.archive_file.fixture]
}

resource "cloudfoundry_route" "kong_api_route" {
  count    = var.enable_protected_admin_api ? 1 : 0
  domain   = data.cloudfoundry_domain.domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = "kong-api-${random_id.id.hex}"
}

resource "cloudfoundry_network_policy" "kong_api_proxy" {
  count = var.enable_protected_admin_api ? 1 : 0

  policy {
    source_app      = cloudfoundry_app.kong_api_proxy[0].id
    destination_app = cloudfoundry_app.kong.id
    protocol        = "tcp"
    port            = "8001"
  }
}

resource "random_password" "password" {
  length = 30
}

data "htpasswd_password" "hash" {
  password = random_password.password.result
  salt     = substr(sha512(random_password.password.result), 0, 8)
}

resource "local_file" "nginx_htpasswd" {
  filename = "${path.module}/nginx-reverse-proxy/.htpasswd"
  content  = <<EOF
${random_id.id.hex}:${data.htpasswd_password.hash.apr1}
EOF
}

resource "local_file" "nginx_conf" {
  filename = "${path.module}/nginx-reverse-proxy/nginx.conf"
  content  = <<EOF
worker_processes 1;
daemon off;
error_log stderr;
events { worker_connections 1024; }
pid /tmp/nginx.pid;
http {
  charset utf-8;
  log_format cloudfoundry 'NginxLog "$request" $status $body_bytes_sent';
  access_log /dev/stdout cloudfoundry;
  default_type application/octet-stream;
  include mime.types;
  sendfile on;
  tcp_nopush on;
  keepalive_timeout 30;
  port_in_redirect off; # Ensure that redirects don't include the internal container PORT - 8080
  resolver 169.254.0.2;

  upstream kong_api {
    server "${cloudfoundry_route.kong_internal.endpoint}:8001";
  }

  server {
      listen {{port}}; # This will be replaced by CF magic. Just leave it here.
      index index.html index.htm Default.htm;

      location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_http_version 1.1;
        proxy_read_timeout 1800;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        client_max_body_size 10M;

        proxy_pass http://kong_api;

        auth_basic           "Kong API";
        auth_basic_user_file ".htpasswd";

        break;
      }
  }
}
EOF

}
