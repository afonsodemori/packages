#!/bin/bash
set -e

mkdir -p public/apk
cp temp/*.apk public/apk/

echo "${ALPINE_PRIVATE_KEY}" | base64 -d >private.rsa
trap 'rm -f private.rsa' EXIT
openssl rsa -in private.rsa -pubout -out public.rsa.pub

apk add --no-cache abuild openssl

cp public.rsa.pub /etc/apk/keys/afonso-dev.rsa.pub

mkdir -p public/apk/x86_64 public/apk/aarch64

mv public/apk/*amd64*.apk public/apk/x86_64/ 2>/dev/null
mv public/apk/*arm64*.apk public/apk/aarch64/ 2>/dev/null

apk index --allow-untrusted --rewrite-arch x86_64 -o public/apk/x86_64/APKINDEX.tar.gz public/apk/x86_64/*.apk
apk index --allow-untrusted --rewrite-arch aarch64 -o public/apk/aarch64/APKINDEX.tar.gz public/apk/aarch64/*.apk

abuild-sign -k /builds/afonsodemori/packages/private.rsa public/apk/x86_64/APKINDEX.tar.gz
abuild-sign -k /builds/afonsodemori/packages/private.rsa public/apk/aarch64/APKINDEX.tar.gz

APP="${APP:-fns-cli}"
for pkg in public/apk/x86_64/*_linux_amd64*.apk public/apk/aarch64/*_linux_arm64*.apk; do
  [ -f "$pkg" ] || continue
  abuild-sign -k /builds/afonsodemori/packages/private.rsa "$pkg"
  new_name=${pkg/${APP}_/${APP}-}
  new_name=${new_name/_linux_amd64/}
  new_name=${new_name/_linux_arm64/}
  mv -v "$pkg" "$new_name"
done

mv public.rsa.pub public/afonso-dev.rsa.pub
