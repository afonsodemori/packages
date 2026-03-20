#!/bin/bash

mkdir -p public/rpm
cp temp/*.rpm public/rpm/
createrepo_c public/rpm/

gpg --batch --yes \
  --pinentry-mode loopback \
  --default-key "${GPG_KEY_ID}" \
  --passphrase "${GPG_PASSPHRASE}" \
  --detach-sign --armor public/rpm/repodata/repomd.xml
