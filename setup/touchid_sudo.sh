#!/usr/bin/env zsh

set -eu

autoload -U colors && colors

unchanged="# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so"

current=$(</etc/pam.d/sudo)

if [[ "$unchanged" != "$current" ]]; then
  echo -e "${fg[red]}Error:${reset_color} unexpected contents of /etc/pam.d/sudo:

Actual:
---$current---

Expected:
+++$unchanged+++" >&2
  exit 7
fi

# Inserts `auth       sufficient     pam_tid.so` on line 2 of /etc/pam.d/sudo
sudo gsed -i "2iauth       sufficient     pam_tid.so" /etc/pam.d/sudo
