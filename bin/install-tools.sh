#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y gpg createrepo-c dpkg-dev apt-utils
