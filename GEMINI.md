# Project Overview

This project is a fully automated, static package registry for `fns-cli` and other tools maintained by `@afonsodemori`. It supports Alpine Linux (`apk`), Debian/Ubuntu (`apt`), and RedHat/Fedora/AlmaLinux (`yum`/`dnf`) across `amd64` and `arm64` architectures.

The repository is served as a static site from the `public/` directory (e.g., via GitHub Pages).

## Main Technologies

- **Shell Scripting:** Automates repository indexing and signing.
- **Docker:** Provides consistent environments for distribution-specific tools (`dpkg-scanpackages`, `createrepo_c`, `apk index`).
- **Signing Tools:** `gpg`, `abuild-sign`, `openssl`.
- **Static Hosting:** Packages and metadata are served directly from the `public/` folder.

# Building and Running

## Local Environment Setup

1.  **Environment Variables:** Create a `.env` file based on `.env.example`.
    - `GPG_KEY_ID`: ID of the GPG key used for signing.
    - `GPG_PASSPHRASE`: Passphrase for the GPG key.
    - `GPG_PRIVATE_KEY`: Base64 encoded private GPG key.
    - `ALPINE_PRIVATE_KEY`: Base64 encoded private RSA key for Alpine signing.

2.  **Infrastructure:** Ensure Docker and Docker Compose are installed.

## Key Commands

- `make update-version`: Resets the `public/` repository metadata and generates it anew by running the update scripts within Docker containers.
- `make serve`: Starts a local HTTP server to preview the repository content at `http://localhost:8080`.

## Internal Automation (GitHub Actions)

The repository is updated via a GitHub Actions workflow triggered by a `repository_dispatch` event from the `afonsodemori/fns-cli` repository.

# Development Conventions

- **Repository Structure:**
  - `bin/`: Shell scripts for repository maintenance (indexing, signing, key export).
  - `docker/`: Dockerfiles for different Linux distributions.
  - `public/`: The static site root containing packages and metadata.
  - `temp/`: A temporary directory used during the package download and indexing process.

- **Package Signing:**
  - **Debian:** Uses `gpg` to create `InRelease` and `Release.gpg` files.
  - **RPM:** Uses `gpg` to sign `repodata/repomd.xml`.
  - **Alpine:** Uses `abuild-sign` with an RSA key to sign `APKINDEX.tar.gz` and individual `.apk` files.

- **Adding Support for New Distros:**
  1.  Create a `Dockerfile` in `docker/`.
  2.  Add a corresponding service to `docker/compose.yml`.
  3.  Create an update script in `bin/` using the distro-specific tools.
  4.  Update `Makefile` to include the new script in `update-version`.
