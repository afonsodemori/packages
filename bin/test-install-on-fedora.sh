#!/bin/bash
set -e
source .env

echo "--- Starting test container ---"
docker compose -f docker/compose.yml up fedora -d --force-recreate
DOCKER="docker exec -e PORT=${PORT:-8080} -it pkg-fedora"

echo
echo "--- Setting up afonso-dev repository ---"
# TODO: Sign the package correctly and change to gpgcheck=1 again
tee afonso-dev.repo <<EOF
[afonso-dev]
name=afonso.dev Package Repository
baseurl=http://host.docker.internal:${PORT}/rpm
enabled=1
gpgcheck=1
gpgkey=http://host.docker.internal:${PORT}/afonso-dev.asc
EOF
${DOCKER} sh -c "mv afonso-dev.repo /etc/yum.repos.d/afonso-dev.repo"

echo
echo "--- Installing fns-cli ---"
${DOCKER} sh -c "sudo dnf install -y fns-cli"

echo
echo "--- Verifying installation ---"
${DOCKER} sh -c "fns-cli"
${DOCKER} sh -c "fns-cli version"
