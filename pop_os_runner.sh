#!/bin/bash

CDY="$(echo $PWD)"

echo "# # # # # # # # #"
echo "# Github setup  #"
echo "# # # # # # # # #"
read -p "Email address: " myEmailAddress
read -p "Github username: " githubUserName
read -sp "Github token: " ghToken

sudo apt update && sudo apt upgrade -y

# Adding VSCode repos
# wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
# sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
# sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
# rm -f packages.microsoft.gpg


# Check if flatpak is installed, if not install
if ! [ -x "$(command -v flatpak)" ]; then
	echo 'ERROR: Flatpak is not installed.' >&2
	echo 'Installing Flatpak...'
	sudo apt install flatpak
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	echo 'Flatpak is installed!'
else
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	echo 'Flatpak is installed!' >&2
fi

# Install some softwares via apt
sudo apt install apt-transport-https ca-certificates gnupg lsb-release fonts-powerline lm-sensors
sudo apt install gnome-tweaks firefox git wget curl -y # code

# Install GH CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y

#-------------------------
# Download YoutubeMusic
#-------------------------
RELEASE_VERSION_YTM=$(wget -qO - "https://api.github.com/repos/th-ch/youtube-music/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
wget -O /home/$SUDO_USER/Downloads/YTM.deb "https://github.com/th-ch/youtube-music/releases/download/v${RELEASE_VERSION_YTM}/youtube-music_${RELEASE_VERSION_YTM}_amd64.deb"
sudo dpkg -i /home/$SUDO_USER/Downloads/YTM.deb

#-------------------------
# Download Micro editor
#-------------------------
cd /usr/bin
curl https://getmic.ro/r | sudo sh
cd

#-------------------------
# Install Docker + Docker compose
#-------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $SUDO_USER

#-------------------------
# Install OnlyOffice
#-------------------------
flatpak install flathub org.onlyoffice.desktopeditors -y

#-------------------------
# Install Joplin
#-------------------------
flatpak install flathub net.cozic.joplin_desktop -y

#-------------------------
# Install Bitwarden
#-------------------------
flatpak install flathub com.bitwarden.desktop -y

#-------------------------
# Install Ext Manager
#-------------------------
flatpak install flathub com.mattjakeman.ExtensionManager -y

#-------------------------
# Install GH Desktop
#-------------------------
flatpak install flathub io.github.shiftey.Desktop -y

#-------------------------
# Install Thunderbird
#-------------------------
flatpak install flathub org.mozilla.Thunderbird -y

#-------------------------
# Install Jitsi Meet
#-------------------------
flatpak install flathub org.jitsi.jitsi-meet -y

#-------------------------
# Install VLC
#-------------------------
flatpak install flathub org.videolan.VLC -y

#-------------------------
# Install GIMP
#-------------------------
flatpak install flathub org.gimp.GIMP -y

#-------------------------
# Install Session Desktop
#-------------------------
flatpak install flathub network.loki.Session -y

#-------------------------
# Install MEGASync
#-------------------------
flatpak install flathub nz.mega.MEGAsync -y

#-------------------------
# Install VSCodium
#-------------------------
# flatpak install flathub com.vscodium.codium -y

#-------------------------
# Install Tutanota Desktop
#-------------------------
flatpak install flathub com.tutanota.Tutanota -y

#-------------------------
# Install Gnome Auth
#-------------------------
flatpak install flathub com.belmoussaoui.Authenticator -y

#-------------------------
# Install auto-cpufreq
#-------------------------
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
cd ..

sudo cp $CDY/auto-cpufreq.conf /etc/auto-cpufreq.conf

#-------------------------
# Settings git config
#-------------------------
printf "Setting git config global user name and email"
git config --global user.name githubUserName
git config --global user.email myEmailAddress

if ! [ -z "$ghToken" ]; then
	{
	 echo $ghToken >> /home/$SUDO_USER/.token.txt
	 gh auth login --with-token < /home/$SUDO_USER/.token.txt
	 rm -rf /home/$SUDO_USER/.token.txt
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
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/$SUDO_USER/Downloads/miniconda.sh
bash /home/$SUDO_USER/Downloads/miniconda.sh -b -p /home/$SUDO_USER/miniconda

if ! [ -x "$(command -v conda)" ]; then
	export PATH="$HOME/miniconda/bin:$PATH"
	/home/$SUDO_USER/miniconda/bin/conda init
else
	/home/$SUDO_USER/miniconda/bin/conda init
fi

#-------------------------
# Install prompter
#-------------------------
# Create the directory inside .config for the shell configs
printf "Copy prompt file to folder"
mkdir -p /home/$SUDO_USER/.config/gr8sh/
sudo cp $CDY/config/gr8sh/prompt.sh /home/$SUDO_USER/.config/gr8sh/
sudo cp $CDY/config/gr8sh/prompt.config /home/$SUDO_USER/.config/gr8sh/

#-------------------------
# Copy micro configs
#-------------------------
printf "Copy micro config to folder"
sudo cp $CDY/config/micro/settings.json /home/$SUDO_USER/.config/micro/
sudo cp $CDY/config/micro/bindings.json /home/$SUDO_USER/.config/micro/

micro --plugin install lsp
micro --plugin install filemanager

pip install python-lsp-server[all]
pip install pylsp-mypy

#-------------------------
# Update .bashrc
#-------------------------
cat tobash.conf >> /home/$SUDO_USER/.bashrc

#-------------------------
# Customize Gnome
#-------------------------
git clone https://github.com/jmattheis/gruvbox-dark-icons-gtk /home/$SUDO_USER/.icons/gruvbox-dark-icons-gtk
gsettings set org.gnome.desktop.interface icon-theme 'gruvbox-dark-icons-gtk'

#sudo cp ./gnome-shell.css /usr/share/themes/Pop-dark/gnome-shell/gnome-shell.css

echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "Install the Nordic theme from here: https://github.com/EliverLara/Nordic"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
