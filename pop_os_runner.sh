#!/bin/bash

read -p "Your email address: " myEmailAddress
read -p "Your GitHub username: " githubUserName

sudo add-apt-repository ppa:appimagelauncher-team/stable -y

# Adding VSCode repos
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# VSCode needed
sudo apt install apt-transport-https

# Update and instal some needed packages
sudo apt update && sudo apt upgrade -y

# Removes nosnap.pref if exists (usually in Linux Mint)
SNAP_PREF=/etc/apt/preferences.d/nosnap.pref
if [ -f "$SNAP_PREF" ]; then
	sudo mv /etc/apt/preferences.d/nosnap.pref $HOME/Documents/nosnap.backup
	sudo apt update
fi
# sudo apt install snapd

# Install some softwares via apt
sudo apt install git fonts-powerline wget curl lm-sensors -y
sudo apt install appimagelauncher code vlc -y

#-------------------------
# Download YoutubeMusic Appimage
#-------------------------
RELEASE_VERSION_YTM=$(wget -qO - "https://api.github.com/repos/th-ch/youtube-music/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
wget -O $HOME/Downloads/YTM.deb "https://github.com/th-ch/youtube-music/releases/download/v${RELEASE_VERSION_YTM}/youtube-music_${RELEASE_VERSION_YTM}_amd64.deb"
sudo dpkg -i $HOME/Downloads/YTM.deb

#-------------------------
# Download OnlyOffice Appimage
#-------------------------
wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb -O $HOME/Downloads/OnlyOfficeDE.deb
sudo dpkg -i $HOME/Downloads/OnlyOfficeDE.deb

#-------------------------
# Download Joplin Appimage
#-------------------------
RELEASE_VERSION_JOPLIN=$(wget -qO - "https://api.github.com/repos/laurent22/joplin/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
wget -O $HOME/Downloads/Joplin.AppImage "https://github.com/laurent22/joplin/releases/download/v${RELEASE_VERSION_JOPLIN}/Joplin-${RELEASE_VERSION_JOPLIN}.AppImage"
#wget -O $HOME/Downloads/joplin.png https://joplinapp.org/images/Icon512.png
#mkdir -p $HOME/.local/share/icons/hicolor/512x512/apps
#mv $HOME/Downloads/joplin.png $HOME/.local/share/icons/hicolor/512x512/apps/joplin.png
#rm $HOME/Downloads/joplin.png

#-------------------------
# Install auto-cpufreq
#-------------------------
# sudo snap install auto-cpufreq
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer

#-------------------------
# Settings git config
#-------------------------
printf "Setting git config global user name and email"
git config --global user.name githubUserName
git config --global user.email myEmailAddress

#-------------------------
# Installing Miniconda
#-------------------------
printf "Downloading miniconda installer and installing miniconda for Linux"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/Downloads/miniconda.sh
bash $HOME/Downloads/miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

printf "Adding conda config channels"
conda config --add channels r
conda config --add channels conda-forge
conda config --add channels defaults
conda config --add channels bioconda

printf "Adding conda packages"
conda install -c bioconda fastqc --yes
conda install -c bioconda trim-galore --yes
conda install -c bioconda kallisto --yes
conda install -c bioconda picard --yes

#-------------------------
# Pre-install for R
#-------------------------
printf "Pre-installing R adding R project repository"
sudo apt install --no-install-recommends software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Update
sudo apt update

#-------------------------
# Install R base, dev, some libs for R
#-------------------------
printf "Installing r-base, r-base-dev and libs"
sudo apt install --no-install-recommends r-base -y
sudo apt install r-base-dev libxml2-dev libcurl4-openssl-dev libssl-dev -y

#-------------------------
# Install prompter
#-------------------------
# Create the directory inside .config for the shell configs
printf "Copy prompt file to folder"
mkdir -p $HOME/.config/gr8sh/
cp ./prompt.sh $HOME/.config/gr8sh/
cp ./prompt.config $HOME/.config/gr8sh/

#-------------------------
# Update .bashrc
#-------------------------
cat tobash.conf >> $HOME/.bashrc