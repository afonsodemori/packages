#!/bin/bash
set -e
source .env

echo "--- Starting test container ---"
docker compose -f docker/compose.yml up debian -d --force-recreate
DOCKER="docker exec -e PORT=${PORT:-8080} -it pkg-debian"

echo
echo "--- Setting up afonso-dev repository ---"
${DOCKER} sh -c "curl -fsSL http://host.docker.internal:${PORT}/afonso-dev.gpg | tee /usr/share/keyrings/afonso-dev.gpg > /dev/null"
${DOCKER} sh -c "echo 'deb [signed-by=/usr/share/keyrings/afonso-dev.gpg] http://host.docker.internal:${PORT}/deb ./' | tee /etc/apt/sources.list.d/afonso-dev.list"

echo
echo "--- Installing fns-cli ---"
${DOCKER} sh -c "apt-get update"
${DOCKER} sh -c "apt-get install -y fns-cli"

echo
echo "--- Verifying installation ---"
${DOCKER} sh -c "fns-cli"
${DOCKER} sh -c "fns-cli version"
