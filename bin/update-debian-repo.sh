#!/bin/bash
set -e

mkdir -p public/deb
cp temp/*.deb public/deb/
cd public/deb
dpkg-scanpackages --multiversion . /dev/null >Packages 2>/dev/null
gzip -k -f Packages

apt-ftparchive \
  -o APT::FTPArchive::Release::Origin="afonso.dev" \
  -o APT::FTPArchive::Release::Label="afonso.dev" \
  -o APT::FTPArchive::Release::Suite="stable" \
  -o APT::FTPArchive::Release::Codename="./" \
  -o APT::FTPArchive::Release::Architectures="amd64 arm64" \
  -o APT::FTPArchive::Release::Components="main" \
  -o APT::FTPArchive::Release::Description="afonso.dev Package Repository" \
  release . >Release

gpg --batch --yes \
  --pinentry-mode loopback \
  --default-key "${GPG_KEY_ID}" \
  --passphrase "${GPG_PASSPHRASE}" \
  --clearsign \
  -o InRelease Release

gpg --batch --yes \
  --pinentry-mode loopback \
  --default-key "${GPG_KEY_ID}" \
  --passphrase "${GPG_PASSPHRASE}" \
  -abs \
  -o Release.gpg Release
