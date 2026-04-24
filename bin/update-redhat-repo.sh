#!/bin/bash
set -e

echo "${GPG_PRIVATE_KEY}" | base64 -d | gpg --batch --import

mkdir -p public/rpm
cp temp/*.rpm public/rpm/

PASSPHRASE_FILE=$(mktemp)
chmod 600 "${PASSPHRASE_FILE}"
echo "${GPG_PASSPHRASE}" >"${PASSPHRASE_FILE}"
trap 'rm -f "${PASSPHRASE_FILE}"' EXIT

for rpm_file in temp/*.rpm; do
  rpmsign \
    --addsign \
    --define "_gpg_name ${GPG_KEY_ID}" \
    --define "_gpg_sign_cmd_extra_args --batch --passphrase-file ${PASSPHRASE_FILE} --pinentry-mode loopback" \
    "public/rpm/$(basename "$rpm_file")"
done

createrepo_c public/rpm/

gpg --batch --yes \
  --pinentry-mode loopback \
  --default-key "${GPG_KEY_ID}" \
  --passphrase "${GPG_PASSPHRASE}" \
  --detach-sign --armor public/rpm/repodata/repomd.xml
