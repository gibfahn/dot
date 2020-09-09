#!/usr/bin/env bash

set -eu

fixed="# sudo: auth account password session
auth       sufficient     pam_tid.so
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so"

current=$(</etc/pam.d/sudo)

# Skip if we already fixed it.

echo -e "Contents of /etc/pam.d/sudo:

Actual:
---$current---

Expected (if fixed already):
+++$fixed+++" >&2

# Skip (0 exit code) if /etc/pam.d/sudo is already the fixed version.
[[ "$current" == "$fixed" ]]
