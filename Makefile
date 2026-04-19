include .env

PORT ?= 8080

serve:
	@echo "Starting local repository server at http://localhost:$(PORT)"
	@npx http-server public -p $(PORT) -c-1

update-version:
	rm -rf public/apk public/deb public/rpm temp
	docker compose -f docker/compose.yml up -d --force-recreate
	docker exec -it pkg-debian bin/install-tools.sh
	docker exec -it pkg-debian bin/download-latest.sh
	docker exec -it pkg-debian bin/export-gpg-public-keys.sh
	docker exec -it pkg-debian bin/update-debian-repo.sh
	docker exec -it pkg-debian bin/update-redhat-repo.sh
	docker exec -it pkg-alpine bin/update-alpine-repo.sh
	docker exec -it pkg-debian bin/generate-index.sh
