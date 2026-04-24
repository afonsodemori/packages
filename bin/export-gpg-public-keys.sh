#!/bin/bash
set -e

: "${GPG_KEY_ID:?}"
: "${GPG_PRIVATE_KEY:?}"

echo "${GPG_PRIVATE_KEY}" | base64 -d | gpg --batch --import
gpg --batch --yes --armor --export "${GPG_KEY_ID}" >public/afonso-dev.asc
gpg --batch --yes --export "${GPG_KEY_ID}" >public/afonso-dev.gpg
