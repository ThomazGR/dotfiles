#!/bin/bash

install_flatpaks() {
    while read p; do
        flatpak install --user flathub $p -y
    done <flatpak.list
}
