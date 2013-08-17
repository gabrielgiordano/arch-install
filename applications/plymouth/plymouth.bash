#!/usr/bin/env bash

plymouth-set-default-theme arch-logo
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux