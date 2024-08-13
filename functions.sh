#!/bin/bash

invalid() {
    echo "Please enter 'y' or 'n'."
}

flathub() {
    read -r -p "Do you want to add Flathub repository to Flatpak? y/n > " response
    
    while true; do
        if [[ $response =~ ^(y|Y)$ ]]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            echo "Flathub repo is added to Flatpak successfully."  
            break              
        
        elif [[ $response =~ ^(n|N)$ ]]; then
            echo "SKIPPED - Flathub"
            break
        
        else
            invalid
        fi
    done
}

package_install() {
  dnf_packages_file="$1"
  flatpak_packages_file="$2"

  # Install dnf packages
  while IFS= read -r package; do
    sudo dnf install -y "$package"
  done < "$dnf_packages_file"

  # Install flatpak packages
  if command -v flatpak &> /dev/null; then
    while IFS= read -r package; do
      flatpak install -y "$package"
    done < "$flatpak_packages_file"
  fi
}