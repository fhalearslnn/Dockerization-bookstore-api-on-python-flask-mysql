 #!/bin/bash
dnf update -y
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
newgrp docker
curl -SL https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir -p /home/ec2-user/docker-project
TOKEN=${user-data-git-token}
USER=${user-data-git-name}
FOLDER="https://$TOKEN@raw.githubusercontent.com/$USER/Dockerization-bookstore-api-on-python-flask-mysql/main/"
curl -s --create-dirs -o "/home/ec2-user/docker-project/app.py" -L "$FOLDER"bookstore-api.py
curl -s --create-dirs -o "/home/ec2-user/docker-project/requirements.txt" -L "$FOLDER"requirements.txt
curl -s --create-dirs -o "/home/ec2-user/docker-project/Dockerfile" -L "$FOLDER"Dockerfile
curl -s --create-dirs -o "/home/ec2-user/docker-project/docker-compose.yml" -L "$FOLDER"docker-compose.yaml
cd /home/ec2-user/docker-project
docker build -t bookstore-api:latest .
docker-compose up -d