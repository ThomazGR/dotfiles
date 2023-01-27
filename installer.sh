#!/bin/bash

# Import functions from other shell files
source flatpaks.sh
source customize_gnome.sh

CDY="$(echo $PWD)"
CURRENT_USER="$(echo $USER)"

echo "Current directory: $CDY"
echo "Current user: $CURRENT_USER"

echo "# # # # # # # # #"
echo "# Github setup  #"
echo "# # # # # # # # #"
read -p "Email address: " myEmailAddress
read -p "Github username: " githubUserName
read -sp "Github token: " ghToken

echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
echo "deb-src http://deb.volian.org/volian/ scar main" | sudo tee -a /etc/apt/sources.list.d/volian-archive-scar-unstable.list

sudo apt update && sudo apt install nala -y

sudo nala upgrade -y

# Install VSCodium
# wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    # | gpg --dearmor \
    # | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

# echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
    # | sudo tee /etc/apt/sources.list.d/vscodium.list

# sudo nala update && sudo nala install codium -y

# Copy Codium config file
# sudo mkdir /home/$CURRENT_USER/.config/VSCodium
# sudo mkdir /home/$CURRENT_USER/.config/VSCodium/User
# sudo cp $CDY/VSCodium/product.json /home/$CURRENT_USER/.config/VSCodium/
# sudo cp $CDY/VSCodium/User/* /home/$CURRENT_USER/.config/VSCodium/User/

# Check if flatpak is installed, if not install
if ! [ -x "$(command -v flatpak)" ]; then
	echo 'ERROR: Flatpak is not installed.' >&2
	echo 'Installing Flatpak...'
	sudo nala install flatpak
	flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
	echo 'Flatpak is installed!'
else
	flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
	echo 'Flatpak is installed!' >&2
fi

# Install some softwares via apt
sudo nala install apt-transport-https ca-certificates gnupg lsb-release fonts-powerline lm-sensors -y
sudo nala install xdotool xclip gnome-tweaks firefox git wget curl -y
sudo nala install texlive latexmk chktex -y

# Install GH CLI
RELEASE_VERSION_GHCLI=$(wget -qO - "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
wget -O /home/$CURRENT_USER/Downloads/GH_CLI.deb "https://github.com/cli/cli/releases/download/v${RELEASE_VERSION_GHCLI}/gh_${RELEASE_VERSION_GHCLI}_linux_amd64.deb"
sudo nala install /home/$CURRENT_USER/Downloads/GH_CLI.deb

#-------------------------
# Download YoutubeMusic
#-------------------------
# RELEASE_VERSION_YTM=$(wget -qO - "https://api.github.com/repos/th-ch/youtube-music/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
# wget -O /home/$CURRENT_USER/Downloads/YTM.deb "https://github.com/th-ch/youtube-music/releases/download/v${RELEASE_VERSION_YTM}/youtube-music_${RELEASE_VERSION_YTM}_amd64.deb"
# sudo nala install /home/$CURRENT_USER/Downloads/YTM.deb

#-------------------------
# Download Micro editor
#-------------------------
cd /usr/bin
curl https://getmic.ro/r | sudo sh
cd $CDY

#-------------------------
# Install Docker + Docker compose
#-------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
sudo nala update
sudo nala install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo usermod -aG docker $CURRENT_USER

#-------------------------
# Install auto-cpufreq
#-------------------------
git clone https://github.com/AdnanHodzic/auto-cpufreq.git /home/$CURRENT_USER/auto-cpufreq
cd /home/$CURRENT_USER/auto-cpufreq && sudo ./auto-cpufreq-installer

sudo cp $CDY/auto-cpufreq.conf /etc/auto-cpufreq.conf

#-------------------------
# Settings git config
#-------------------------
printf "Setting git config global user name and email"
git config --global user.name githubUserName
git config --global user.email myEmailAddress

if ! [ -z "$ghToken" ]; then
	{
	 sudo touch /home/$CURRENT_USER/.token.txt
	 echo $ghToken >> sudo /home/$CURRENT_USER/.token.txt
	 gh auth login --with-token < sudo /home/$CURRENT_USER/.token.txt
	 sudo rm -rf /home/$CURRENT_USER/.token.txt
	 echo "Github logged in."
	} || {
	 echo "Github NOT logged in. Check if everything is good or retry."
	}
else
	echo "No GH Token has been passed."
fi

#-------------------------
# Installing Miniconda
#-------------------------
printf "Downloading miniconda installer and installing miniconda for Linux"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/$CURRENT_USER/Downloads/miniconda.sh
bash /home/$CURRENT_USER/Downloads/miniconda.sh -b -p /home/$CURRENT_USER/miniconda

if ! [ -x "$(command -v conda)" ]; then
	export PATH="$HOME/miniconda/bin:$PATH"
	/home/$CURRENT_USER/miniconda/bin/conda init
else
	/home/$CURRENT_USER/miniconda/bin/conda init
fi

#-------------------------
# Install prompter
#-------------------------
# Create the directory inside .config for the shell configs
printf "Copy prompt file to folder"
mkdir -p /home/$CURRENT_USER/.config/gr8sh/
sudo cp $CDY/gr8sh/prompt.sh /home/$CURRENT_USER/.config/gr8sh/
sudo cp $CDY/gr8sh/prompt.config /home/$CURRENT_USER/.config/gr8sh/

#-------------------------
# Copy micro configs
#-------------------------
printf "Copy micro config to folder"
sudo cp $CDY/micro/settings.json /home/$CURRENT_USER/.config/micro/
sudo cp $CDY/micro/bindings.json /home/$CURRENT_USER/.config/micro/

# micro --plugin install lsp
# micro --plugin install filemanager

# pip install python-lsp-server[all]
# pip install pylsp-mypy

#-------------------------
# Update .bashrc
#-------------------------
cat $CDY/tobash.conf >> sudo /home/$CURRENT_USER/.bashrc

# Install lite-xl
RELEASE_VERSION_LITEXL=$(wget -qO - "https://api.github.com/repos/lite-xl/lite-xl/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
wget -O /home/$CURRENT_USER/Downloads/lite-xl.tar.gz "https://github.com/lite-xl/lite-xl/releases/download/v${RELEASE_VERSION_LITEXL}/lite-xl-${RELEASE_VERSION_LITEXL}-addons-linux-x86_64-portable.tar.gz"
tar -xzf /home/$CURRENT_USER/Downloads/lite-xl.tar.gz
cp /home/$CURRENT_USER/Downloads/lite-xl/lite-xl /home/$CURRENT_USER/.local/bin
cp -r /home/$CURRENT_USER/Downloads/lite-xl/data/ /home/$CURRENT_USER/.local/share/lite-xl
cp $CDY/Lite-xl.desktop /home/$CURRENT_USER/.local/share/applications/

# Run functions
install_flatpaks()

customize_gnome()


