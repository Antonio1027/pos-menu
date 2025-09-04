data "aws_security_group" "existing_sg" {
  name        = "django-app-security-group"
  filter {
    name   = "security-group-name"
    values = ["django-app-security-group"]
  }
}

locals {
  target_sg_id = can(data.aws_security_group.existing_sg.id) ? data.aws_security_group.existing_sg.id : aws_security_group.django_sg[0].id
}

resource "aws_security_group" "django_sg" {
  count       = can(data.aws_security_group.existing_sg.id) ? 0 : 1
  name        = "django-app-security-group"
  description = "Security group for Django application"
}

resource "aws_vpc_security_group_egress_rule" "allow_http" {
  security_group_id = locals.target_sg_id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4   = "0.0.0.0/8"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  security_group_id = locals.target_sg_id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4   = "0.0.0.0/8"
}


resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = locals.target_sg_id
  from_port         = 8000
  to_port           = 8000
  ip_protocol       = "tcp"
  cidr_ipv4   = "0.0.0.0/8"
  
}

resource "aws_instance" "django_app_instance" {
    ami           = var.ami_id
    instance_type = var.instance_type
    security_groups = [aws_security_group.django_sg.name]
    key_name      = "pos-menu" # Uncomment and replace with your key pair name

    lifecycle {
      create_before_destroy = true
    }

    user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y python3-pip python3-venv git nginx

      # Clone your Django project
      git clone --branch ${var.CODE_BRANCH} https://github.com/Antonio1027/pos-menu.git /home/ubuntu/your-django-app
      cd /home/ubuntu/your-django-app

      # Setup virtual environment and install dependencies
      python3 -m venv venv
      source venv/bin/activate
      pip install -r requirements.txt
      pip install gunicorn

      # Collect static files (if needed)
      python manage.py collectstatic --noinput

      # Start Gunicorn
      nohup gunicorn menu_engineering.wsgi:application --bind 0.0.0.0:8000 &

      # Configure Nginx
      sudo tee /etc/nginx/sites-available/django_app <<EOL
      server {
          listen 80;
          server_name _;
          location = /favicon.ico { access_log off; log_not_found off; }
          location /static/ {
              alias /home/ubuntu/your-django-app/static/;
          }
          location / {
              proxy_pass http://127.0.0.1:8000;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
          }
      }
      EOL

      sudo ln -sf /etc/nginx/sites-available/django_app /etc/nginx/sites-enabled
      sudo nginx -t
      sudo systemctl restart nginx
    EOF

    tags = {
    Name = "DjangoAppInstance"
    }
}