# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A package repository that distributes `fns-cli` for multiple Linux distributions (Debian/Ubuntu, RedHat/Fedora, Alpine Linux). It fetches releases from GitHub, signs them with GPG, generates repository metadata, and deploys to GitLab Pages.

## Common Commands

```bash
make serve              # Start local HTTP server at http://localhost:8080
make update-version     # Full pipeline: clear old packages, download latest, regenerate repos
```

Individual bin scripts (run directly or via `make update-version`):

```bash
bash bin/download-latest.sh       # Fetch latest fns-cli from GitHub releases
bash bin/export-gpg-public-keys.sh
bash bin/update-debian-repo.sh
bash bin/update-redhat-repo.sh
bash bin/update-alpine-repo.sh
bash bin/generate-index.sh        # Generate HTML directory indexes for public/
```

Integration tests (require Docker):

```bash
bash bin/test-install-on-debian.sh
bash bin/test-install-on-alpine.sh
bash bin/test-install-on-fedora.sh
```

## Architecture

### Data Flow

1. `bin/download-latest.sh` fetches `.deb`, `.rpm`, `.apk` packages (amd64 + arm64) from GitHub releases into `public/deb/`, `public/rpm/`, `public/apk/`
2. Repository metadata scripts generate distribution-specific index files:
   - Debian: `dpkg-scanpackages` + `apt-ftparchive` inside the Debian Docker container
   - RedHat: `createrepo_c` inside the Fedora Docker container
   - Alpine: `apk index` + RSA signing inside the Alpine Docker container
3. All repos are GPG-signed; keys are exported to `public/afonso-dev.asc` and `public/afonso-dev.gpg`
4. `bin/generate-index.sh` creates browsable HTML indexes
5. GitLab CI deploys `public/` as GitLab Pages

### Docker Containers

`docker/compose.yml` defines three containers used during `make update-version`:

- `debian` — Debian 13 + dpkg-dev, apt-utils, gnupg
- `alpine` — Alpine 3 + apk-tools, build tools
- `fedora` — Fedora 43 + createrepo_c

The devcontainer (`.devcontainer/`) is separate and used for local development.

### Environment Variables

Required for signing and CI (see `.env.example`):

- `GPG_KEY_ID`, `GPG_PASSPHRASE`, `GPG_PRIVATE_KEY` (base64) — for Debian/RPM signing
- `ALPINE_PRIVATE_KEY` (base64) — RSA key for Alpine APK signing

### CI/CD

`.gitlab-ci.yml` defines 4 stages: `prepare` → `update-package` → `commit` → `deploy`. Triggered by webhook, manual run, or schedule. `VERSION` can be overridden as a CI variable.

## Code Style

Shell scripts use 2-space indentation. Prettier is configured (single quotes, semicolons, 120-char line width) — primarily for any HTML/JS files. VS Code formats on save via shfmt for shell scripts.
