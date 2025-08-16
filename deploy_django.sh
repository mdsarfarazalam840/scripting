#!/bin/bash
set -e

code_clone(){
    echo "Cloning the django app..."
    if [ -d "django-notes-app" ]; then
        echo "The directory already exists"
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git
    fi
}

install_requirements(){
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y docker.io nginx
}

requires_restart(){
    echo "Starting and enabling services..."
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo systemctl enable nginx
    sudo systemctl start nginx

    # Give current user Docker access
    sudo chown "$USER" /var/run/docker.sock
}

deploy(){
    echo "Building Docker image..."
    docker build -t notes-app .

    echo "Stopping old container (if exists)..."
    docker rm -f notes-app-container || true

    echo "Starting new container..."
    docker run -d --name notes-app-container -p 8000:8000 notes-app:latest
}

echo "*** DEPLOYMENT STARTED ***"
code_clone
cd django-notes-app || { echo "Error: project folder not found"; exit 1; }
install_requirements
requires_restart
deploy
echo "*** DEPLOYMENT COMPLETED ***"

