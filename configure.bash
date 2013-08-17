#!/usr/bin/env bash

# This is a script for making the install of Arch Linux
# Many of the following procedures are based on the Beginners Guide in the Arch Wiki.

keyboadLayout="br-abnt2"
font="Lat2-Terminus16"

pauseFunction()
{
    echo "Press any key to continue..."
    read
}

containsElement()
{
    #check if an element exist in a string
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

setLocale()
{
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    export LANG=en_US.UTF-8
}

configureKeymap()
{
    loadkeys "$keyboadLayout"
    setfont "$font"
    echo "KEYMAP=$keyboadLayout" >> /etc/vconsole.conf
    echo "FONT=Lat2-Terminus16" >> /etc/vconsole.conf
}

setTimeZone()
{
    echo "Please select you Zone"
    pauseFunction
    zones=(/usr/share/zoneinfo/*)
    select zone in "${zones[@]}" ; do
        if containsElement "$zone" "${zones[@]}" ; then
            zone="${zone##*/}"
            break
        else
            echo "Try again"
        fi
    done

    subZones=(/usr/share/zoneinfo/"${zone}"/*)
    echo "Please select you SubZone"
    pauseFunction
    select subZone in "${subZones[@]}" ; do
        if containsElement "$subZone" "${subZones[@]}" ; then
            break
        else
            echo "Try again"
        fi
    done
    if [[ -e /etc/localtime ]]; then
        echo "/etc/localtime already exist, do you want remove it?(Y/N)"
        if [[ "$options" == "Y" ]]; then
            rm /etc/localtime
            ln -s "${subZone}" /etc/localtime
        fi
    fi
}

setClock()
{
    hwclock --systohc --utc
}

setHostname()
{
    echo "Please give a hostname"
    read myHostname
    echo "$myHostname" > /etc/hostname
}

setInternet()
{
    echo "Can I set the dhcpd service to you?(Y/N)"
    read option
    if [[ "$option" = "Y" ]] ; then
        ip link
        echo "Please give me the name of the device"
        read device
        systemctl enable "dhcpcd@${device}.service"
    else
        echo "I will give you a time to configure by yourself then =D"
    fi
    pauseFunction
}

setRootPassword()
{
    echo "Please enter the root password"
    passwd
}

installGrub()
{
    pacman -S grub
    lsblk
    echo "Please enter the driver you installed the Arch (Example /dev/sda)"
    read driver
    grub-install --recheck "$driver"
    grub-mkconfig -o /boot/grub/grub.cfg
}

createUser()
{
    echo "Please enter a name for your new user"
    read userName
    useradd -m -g users -G wheel -s /bin/bash "$userName"
    echo "Please enter a password"
    passwd "$userName"
}

getVGA()
{
    echo "Please select your VGA"
    lspci | grep VGA
    drivers=("xf86-video-ati" "catalyst-dkms" "xf86-video-intel" "xf86-video-nouveau" "nvidia" "xf86-video-openchrome" "mesa")
    select videoDriver in "${drivers[@]}"; do
        if containsElement "$videoDriver" "${drivers[@]}"; then
            break;
        else
            echo "Try again"
        fi
    done
}

installOfficialPackages()
{
    IFS=$'\r\n' officialPackagesList=($(cat OfficialPackages))
    pacman -S "$videoDriver" "${officialPackagesList[@]}"
}

installYaourt()
{
    wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
    tar -xzf package-query.tar.gz
    cd package-query
    makepkg -s
    pacman -U *.tar.xz
    cd ..

    wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
    tar -xzf yaourt.tar.gz
    cd yaourt    
    makepkg -s
    pacman -U *.tar.xz
    cd ..
    rm package-query.tar.gz yaourt.tar.gz
    rm -R package-query yaourt
}

installAURPackages()
{
    IFS=$'\r\n' aurPackagesList=($(cat AURPackages))
    yaourt -S "${aurPackagesList[@]}"
}

configurePackages()
{
    for folder in applications/* ; do
        script="${folder##*/}"
        ./"${folder}"/"${script}".bash "$userName"
    done
}

setLocale
configureKeymap
setTimeZone
setClock
setHostname
setInternet
setRootPassword
installGrub
createUser
getVGA
installOfficialPackages
installYaourt
installAURPackages
cp -R backup/* /
configurePackages