#!/bin/bash
set -e
source .env

echo "--- Starting test container ---"
docker compose -f docker/compose.yml up alpine -d --force-recreate
DOCKER="docker exec -e PORT=${PORT:-8080} -it pkg-alpine"

echo
echo "--- Setting up afonso-dev repository ---"
${DOCKER} sh -c "wget -O /etc/apk/keys/afonso-dev.rsa.pub http://host.docker.internal:${PORT}/afonso-dev.rsa.pub"
${DOCKER} sh -c "echo 'http://host.docker.internal:${PORT}/apk' | tee -a /etc/apk/repositories"

echo
echo "--- Installing fns-cli ---"
${DOCKER} sh -c "apk update"
${DOCKER} sh -c "apk add --no-cache fns-cli"

echo
echo "--- Verifying installation ---"
${DOCKER} sh -c "fns-cli"
${DOCKER} sh -c "fns-cli version"
