#!/bin/bash
set -e

REPO="afonsodemori/fns-cli"
if [ -z "${VERSION}" ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" |
    grep '"tag_name"' |
    cut -d '"' -f4)
fi

# Strip 'v' prefix for filename
V_STRIPPED=$(echo "${VERSION}" | sed 's/^v//')

[[ -d ./temp ]] && rm -rf ./temp/* || mkdir ./temp
ARCHS=(amd64 arm64)
EXTS=(apk deb rpm)
for ARCH in "${ARCHS[@]}"; do
  for EXT in "${EXTS[@]}"; do
    URL="https://github.com/${REPO}/releases/download/${VERSION}/fns-cli_${V_STRIPPED}_linux_${ARCH}.${EXT}"
    echo "${URL}"
    wget -q "${URL}" -P ./temp
  done
done
