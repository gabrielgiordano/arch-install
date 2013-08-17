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

createPartition()
{
    devicesList=(`lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd'`);
    option="N"
    while [[ "$option" != "Y" ]]; do
        echo "Create a partition for the root using the defaults values"
        echo "Remember to create an extra BIOS Boot Partition of size 1007 KiB and EF02 type code."
        echo -e "Select device:\n"
        select device in "${devicesList[@]}"; do
            if cgdisk "$device" ; then
                break
            fi
        done
        echo "Are you done?(Y\N)"
        read option
    done
}

selectFilesystem()
{
    filesystem=("ext4" "ext3" "ext2" "btrfs" "nilfs2" "ntfs" "vfat" "f2fs" "jfs" "xfs");
    echo -e "Select filesystem:\n"
    select type in "${filesystem[@]}"; do
        if containsElement "$type" "${filesystem[@]}"; then
            break
        else
            echo "Try again"
        fi
    done
}

createFilesystems()
{
    lsblk
    partitions=(`cat /proc/partitions | awk 'length($3)>1' | awk '{print "/dev/" $4}' | awk 'length($0)>8' | grep 'sd\|hd'`)
    
    echo -e "\nDo you want a swap partition?(Y/N)"
    read option
    if [[ "$option" == "Y" ]] ; then
        echo -e "\nSelect one to be a swap:\n"
        select partition in "${partitions[@]}"; do
            if containsElement "$partition" "${partitions[@]}" ; then
                echo mkswap "$partition"
                echo swapon "$partition"
                break;
            else
                echo "Try again"
            fi
        done

        i=0
        for item in "${partitions[@]}"; do
            if [[ "$item" == "$partition" ]] ; then
                unset partitions["$i"]
            fi
            i=$((i+1))
        done
    fi

    for partition in "${partitions[@]}"; do
        echo "$partition"
        echo "Do you want give this partition a filesystem?(Y\N)"
        read option
        if [[ "$option" == "Y" ]]; then
            echo "For this partition: ${partition}, please select a filesystem"
            selectFilesystem
            umount "$partition"
            mkfs."${type}" "$partition"
            echo "Where do you want mount $partition?"
            echo "For root you need to mount on /mnt!!! And for home you could mount on /mnt/home"
            read partitionPath
            mkdir -p "$partitionPath"
            mount "$partition" "$partitionPath"
        fi
    done

    echo "Do you want start this again?(Y/N)"
    read option
    if [[ "$option" == "Y" ]]; then
        createFilesystems
    fi
}

installBaseSystem()
{
    pacstrap -i /mnt base    
}

makeFstab()
{
    genfstab -U -p /mnt >> /mnt/etc/fstab
    echo "Please check your fstab"
    pauseFunction
    nano /mnt/etc/fstab    
}


loadkeys "$keyboadLayout"
setfont "$font"
pacman -Syu
createPartition
createFilesystems
installBaseSystem
makeFstab
arch-chroot /mnt