#!/bin/bash

if [ ! -d ~/.dotfiles ]; then
   mkdir ~/.dotfiles
fi

cp -r . ~/.dotfiles

ZSRCDOT=~/.dotfiles/zsh/zshrc.cfg

PACKAGES="nodejs npm yarn
   docker.io docker-compose packer
   ansible neovim silversearcher-ag
   apt-transport-https curl whois
   terminator zsh containerd ruby-full
   gnupg2 virtualbox keepassx network-manager-openconnect-gnome
   default-jre python3-pip python python-dev evince
   jq dconf-editor tmux fonts-firacode
   tree atop nmap"

sudo apt-get -y update

echo "Remove nano"
sudo apt -y purge nano

sudo apt -y install --no-install-recommends software-properties-common

echo "Adding additional repositories"
sudo add-apt-repository -y universe

echo "Install apt-fast"
sudo add-apt-repository -y ppa:apt-fast/stable
sudo apt-get -y update
echo -e "1\n5\nno\n" | sudo apt-get -y install apt-fast

echo "Installing packages"
sudo apt update && sudo apt -y install $PACKAGES


if [[ ! -n "$(command -v snap)" ]]; then
   echo "Installing snapd on system"
   sudo apt -y install snapd
fi

# Install helm with snap
sudo snap install helm --classic

# Install kustomize with snap
sudo snap install kustomize

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

ZSH=$(which zsh)

# awscli version 1
# pip3 install awscli

# Install awscli version2
echo "Install awscli version 2"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -f awscliv2.zip

# Install fzf
echo "Install fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
echo -e "y\n" | ~/.fzf/install

echo "Install ohmyzsh"
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install.sh
echo -e "Y\n" | sh install.sh
rm -f install.sh

echo "Install vagrant"
curl -O https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_x86_64.deb

sudo apt -y install ./vagrant_2.2.6_x86_64.deb
rm -f vagrant_2.2.6_x86_64.deb

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt -y install kubectl

echo "Install minikube"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt -y install ./minikube_latest_amd64.deb
rm -f minikube_latest_amd64.deb

sudo usermod -s $ZSH $(whoami)
GROUP=$(grep docker /etc/group)
if [ ${GROUP} ]; then
   sudo usermod -aG docker $(whoami)
fi

git clone https://github.com/pyenv/pyenv.git ~/.pyenv

git clone https://github.com/syndbg/goenv.git ~/.goenv

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

mkdir ~/bin
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
ln -s ~/.tfenv/bin/* $HOME/bin

mkdir -p ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo "Installing zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

if [ -f ~/.zshrc ]; then
   echo "Configuring zshrc"

   TMPDOFILE=$(grep zshrc.cfg ~/.zshrc)
   if [ "$TMPDOFILE" ]; then
      echo "zshrc.dotfiles will be adjusted"
      sed "s%${TMPDOFILE}%source\ ${ZSRCDOT}%g" -i ~/.zshrc
   else
      echo "zshrc.dotfiles will be configured"
      echo "source ${ZSRCDOT}" >> ~/.zshrc
   fi

   echo "Configuring zsh plugins"
   sed '/^source\ \$ZSH\/oh-my-zsh.sh/i source\ \$HOME\/.dotfiles\/zsh\/plugins.sh' -i ~/.zshrc
fi

source ${ZSRCDOT}

tfenv install 0.12.20
tfenv use 0.12.20

goenv install 1.15.3
goenv global 1.15.3

echo "Configuring vim"
~/.dotfiles/vim/vim.install.sh

git config --global push.default current
git config --global pull.default current

echo "Done."
