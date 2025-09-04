    resource "aws_security_group" "django_sg" {
      name        = "django-app-security-group"
      description = "Security group for Django application"

      ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
        from_port   = 8000 # Or 80/443 if using Nginx
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    resource "aws_instance" "django_app_instance" {
      ami           = var.ami_id
      instance_type = var.instance_type
      security_groups = [aws_security_group.django_sg.name]
      key_name      = "pos-menu" # Uncomment and replace with your key pair name

      user_data = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y python3-pip python3-venv git
        # Install Docker if needed for containerized deployment
        # sudo apt install -y docker.io
        # sudo systemctl start docker
        # sudo systemctl enable docker

        # Clone your Django project
        git clone https://github.com/Antonio1027/pos-menu.git /home/ubuntu/your-django-app
        cd /home/ubuntu/your-django-app

        # Setup virtual environment and install dependencies
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt

        # Run Django (consider Gunicorn/Nginx for production)
        # python3 manage.py runserver 0.0.0.0:8000
      EOF

      tags = {
        Name = "DjangoAppInstance"
      }
    }