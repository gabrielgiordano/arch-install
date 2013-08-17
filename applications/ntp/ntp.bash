#!/usr/bin/env bash

ntpd -q
hwclock -w
systemctl enable ntpd