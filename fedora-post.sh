#!/bin/bash

source functions.sh

echo "##################"
echo "Package Management"
echo -e "##################\n"

echo "DNF Flags"
echo -e "#########\n"

while true; do
    read -r -p "Do you want to update DNF Flags for best experience? y/n > " response
    
    if [[ $response =~ ^(y|Y)$ ]]; then
        read -r -p "Parallel Install Count > " count
        # Check if the expressions are already in the dnf.conf with if statement.
        if ! grep -q '^fastestmirror=' /etc/dnf/dnf.conf; then
            echo "fastestmirror=1" | sudo tee -a /etc/dnf/dnf.conf
        fi

        if ! grep -q '^max_parallel_downloads=' /etc/dnf/dnf.conf; then
            echo "max_parallel_downloads=$count" | sudo tee -a /etc/dnf/dnf.conf
        fi

        if ! grep -q '^deltarpm=' /etc/dnf/dnf.conf; then
            echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
        fi
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - DNF Flags"
        break
    
    else
        invalid
    fi
done

echo "RPM Fusion"
echo -e "##########\n"

while true; do
    read -r -p "Do you want to add RPM Fusion repositories? y/n > " response

    if [[ $response =~ ^(y|Y)$ ]]; then
        sudo dnf install -y  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf upgrade --refresh
        sudo dnf groupupdate core
        sudo dnf install -y rpmfusion-free-release-tainted
        sudo dnf install -y dnf-plugins-core
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - RPM Fusion"
        break
    
    else
        invalid
    fi
done

echo "Flatpak / Flathub"
echo -e "#################\n"

while true; do
    if command -v flatpak &> /dev/null; then
        echo "Flatpak is installed"
        flathub
    
    else
        echo "Flatpak is not installed"
        while true; do
            if [[ $response =~ ^(y|Y)$ ]]; then
                sudo dnf install -y flatpak
                echo "Flatpak installed successfully."
                flathub
                break

            elif [[ $response =~ ^(n|N)$ ]]; then
                echo "SKIPPED - Flatpak / Flathub"
                break

            else
                invalid
            fi
        done
    fi
done

echo "######################################"
echo "Essential Components and Modifications"
echo -e "######################################\n"

echo "Hostname"
echo -e "########\n"

while true; do
    read -r -p "Do you want to change hostname? y/n > " response
    
    if [[ $response =~ ^(y|Y)$ ]]; then
        read -r -p "New Hostname > " hostname
        hostnamectl set-hostname $hostname
        echo "Hostname changed successfully."
        break

    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Hostname"
        break

    else
        invalid
    fi
done

echo "Codecs"
echo -e "######\n"

while true; do
    read -r -p "Do you want to install essential codecs? y/n > " response
    
    if [[ $response =~ ^(y|Y)$ ]]; then
        sudo dnf groupupdate sound-and-video
        sudo dnf install -y libdvdcss
        sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg 
        sudo dnf install -y lame\* --exclude=lame-devel
        sudo dnf group upgrade --with-optional Multimedia
        echo "Essential codecs installed successfully."
        break

    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Codecs"
        break

    else
        invalid
    fi
done

echo "NVIDIA"
echo -e "######\n"

while true; do
    read -r -q "Do you want to install NVIDIA Drivers? y/n > " response
    if [[ $response =~ ^(y|Y)$ ]]; then
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs vdpauinfo libva-vdpau-driver libva-utils vulkan
        echo "NVIDIA drivers installed successfully."
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - NVIDIA"
        break
    else 
        invalid
    
    fi
done

echo "Wine"
echo -e "####\n"

while true; do
    read -r -q "Do you want to install Wine? y/n > " response

    if [[ $response =~ ^(y|Y)$ ]]; then
        sudo dnf groupinstall -y "C Development Tools and Libraries"
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y wine
        echo "Wine installed successfully."
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Wine"
        break
    
    else
        invalid
    
    fi
done

echo "Fonts"
echo -e "#####\n"

while true; do
    read -r -q "Do you want to install font (including Microsoft Fonts) ? y/n > " response

    if [[ $response =~ ^(y|Y)$ ]]; then
        sudo dnf install -y fira-code-fonts 'mozilla-fira*' 'google-roboto*'
        sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
        sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
        echo "Fonts installed successfully."
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Fonts"
        break
    
    else
        invalid
    
    fi
done

echo "##########################"
echo "Auto Package Installations"
echo -e "##########################\n"

echo "Essential Packages"
echo -e "##################\n"

while true; do
    read -r -q "Do you want to install essential packages? y/n > " response

    if [[ $response =~ ^(y|Y)$ ]]; then
        package_install ./dnf/essential.txt ./flatpak/essential.txt
        echo "Essential packages installed successfully."
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Essential Packages"
        break
    
    else
        invalid
    fi    
done

echo "Development Packages"
echo -e "####################\n"

while true; do
    read -r -q "Do you want to install development packages? y/n > " response

    if [[ $response =~ ^(y|Y)$ ]]; then
        package_install ./dnf/dev.txt ./flatpak/dev.txt
        echo "Development packages installed successfully."
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Development Packages"
        break
    
    else
        invalid
    fi    
done

echo "Gaming Packages"
echo -e "###############\n"

while true; do
    read -r -q "Do you want to install gaming packages? y/n > " response

    if [[ $response =~ ^(y|Y)$ ]]; then
        package_install ./dnf/gaming.txt ./flatpak/gaming.txt
        echo "Gaming packages installed successfully."
        break
    
    elif [[ $response =~ ^(n|N)$ ]]; then
        echo "SKIPPED - Gaming Packages"
        break
    
    else
        invalid
    fi    
done