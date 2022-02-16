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
sudo chmod 666 /var/run/docker.sock
echo "The version of Docker installed can be checked"
docker version
echo "Install Docker Compose on Fedora 35/34/33/32/31 from the repo"
sudo dnf -y install docker-compose
echo "Install Docker Compose on Fedora from a binary file."
sudo dnf -y install wget
echo "Download latest compose:"
curl -s https://api.github.com/repos/docker/compose/releases/latest \
  | grep browser_download_url \
  | grep docker-compose-linux-x86_64 \
  | cut -d '"' -f 4 \
  | wget -qi -
echo "Make the binary file executable."
chmod +x docker-compose-linux-x86_64
echo "Move the file to your PATH."
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
echo "Docker composer version check"
docker-compose --version
echo "Configure Compose Command-line completion"
sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
source /etc/bash_completion.d/docker-compose
echo "give the app access binding to ports 80 & 443"
sudo setcap 'cap_net_bind_service=+eip' /opt/DECK/deck
sudo sh -c "echo '/opt/DECK/' >> /etc/ld.so.conf.d/deck.conf"
sudo ldconfig
clear
echo "All set and done.";
