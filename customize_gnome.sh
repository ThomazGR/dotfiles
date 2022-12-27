#!/bin/bash

#-------------------------
# Customize Gnome
#-------------------------
mkdir /home/$CURRENT_USER/.icons
mkdir /home/$CURRENT_USER/.themes

sudo nala install unzip -y

# Download gruvbox dark icon pack
git clone https://github.com/jmattheis/gruvbox-dark-icons-gtk /home/$CURRENT_USER/.icons/gruvbox-dark-icons-gtk
gsettings set org.gnome.desktop.interface icon-theme 'gruvbox-dark-icons-gtk'

# Add Dracula icon pack
curl https://github.com/dracula/gtk/files/5214870/Dracula.zip > /home/$CURRENT_USER/.icons/Dracula.zip
unzip /home/$CURRENT_USER/.icons/Dracula.zip
gsettings set org.gnome.desktop.interface icon-theme "Dracula"

# Add Dracula theme
git clone https://github.com/dracula/gtk /home/$CURRENT_USER/.themes/Dracula
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
gsettings set org.gnome.desktop.wm.preferences theme "Dracula"

# Add Doid Sans Mono Nerd Font
mkdir -p /home/$CURRENT_USER/.local/share/fonts && \
cd /home/$CURRENT_USER/.local/share/fonts && \
curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" \
https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
