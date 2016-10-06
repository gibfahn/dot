#!/bin/bash -x
git config --global push.default simple
git config --global user.name "Gibson Fahnestock"
git config --global user.email "gib@uk.ibm.com"
git config --global --add core.whitespace fix
git config --global credential.helper cache
git config credential.helper 'cache --timeout=86400'
git config --global core.excludesfile ~/.gitignore
