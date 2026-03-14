serve:
	@echo "Starting local repository server at http://localhost:8080"
	@npx http-server docs -p 8080 -c-1

debian-container:
	docker build --file docker/Dockerfile.debian --tag afonsodemori/packages/debian .
	docker run --rm -it --name=packages_debian -w /work afonsodemori/packages/debian

alpine-container:
	docker build --file docker/Dockerfile.alpine --tag afonsodemori/packages/alpine .
	docker run --rm -it --name=packages_alpine -w /work afonsodemori/packages/alpine
