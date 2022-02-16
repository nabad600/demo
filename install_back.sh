#!/bin/sh
#Set up the required package
pkgs='deck'
if ! rpm -qa | grep -i $pkgs >/dev/null 2>&1; then
  wget https://github.com/nabad600/demo/releases/download/v1.0.0/deck-3.0.0-2.x86_64.rpm
  sudo dnf -y localinstall deck-3.0.0-2.x86_64.rpm
fi
echo "Add the Docker CE repository to Fedora 35/34/33/32/31/30"
sudo dnf -y install dnf-plugins-core
source /etc/os-release
sudo tee /etc/yum.repos.d/docker-ce.repo<<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/${VERSION_ID}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF

echo "Install Docker CE on Fedora"
sudo dnf -y makecache
sudo dnf -y install docker-ce docker-ce-cli containerd.io

echo "Docker will be installed but not started. To start the docker service, run:"
sudo systemctl enable --now docker
echo "Add your user to this group to run docker commands without sudo"
sudo usermod -aG docker $(whoami)
newgrp docker
