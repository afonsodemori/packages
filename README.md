# packages

Personal Linux package repository for [fns-cli](https://github.com/afonsodemori/fns-cli), distributed for Debian/Ubuntu, RedHat/Fedora, and Alpine Linux. Packages are GPG-signed, and the repository is deployed via GitLab Pages at **https://pkg.afonso.dev**.

## Supported Distributions

| Distribution    | Format | Architectures       |
| --------------- | ------ | ------------------- |
| Debian / Ubuntu | `.deb` | `amd64`, `arm64`    |
| RedHat / Fedora | `.rpm` | `amd64`, `arm64`    |
| Alpine Linux    | `.apk` | `x86_64`, `aarch64` |

## Installing fns-cli

### Debian / Ubuntu

```sh
# Import the GPG key
curl -fsSL https://pkg.afonso.dev/afonso-dev.gpg \
  | sudo tee /usr/share/keyrings/afonso-dev.gpg > /dev/null

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/afonso-dev.gpg] https://pkg.afonso.dev/deb ./" \
  | sudo tee /etc/apt/sources.list.d/afonso-dev.list

sudo apt update && sudo apt install fns-cli
```

### RedHat / Fedora / AlmaLinux

Create `/etc/yum.repos.d/afonso-dev.repo`:

```ini
[afonso-dev]
name=afonso.dev Package Repository
baseurl=https://pkg.afonso.dev/rpm
enabled=1
gpgcheck=1
gpgkey=https://pkg.afonso.dev/afonso-dev.asc
```

Then install:

```sh
sudo dnf install fns-cli
```

### Alpine Linux

```sh
# Download the public key
sudo wget -O /etc/apk/keys/afonso-dev.rsa.pub https://pkg.afonso.dev/afonso-dev.rsa.pub

# Add the repository
echo "https://pkg.afonso.dev/apk" | sudo tee -a /etc/apk/repositories

sudo apk update && sudo apk add fns-cli
```

## Development

### Prerequisites

- Docker (with Compose)
- A `.env` file with the required signing keys (see `.env.example`)

```sh
cp .env.example .env
# Fill in GPG_KEY_ID, GPG_PASSPHRASE, GPG_PRIVATE_KEY, ALPINE_PRIVATE_KEY
```

### Common Commands

```sh
make update-version   # Full pipeline: clear old packages, download latest, regenerate repos
make serve            # Start local HTTP server at http://localhost:8080
```

### Pipeline Steps

`make update-version` runs the following inside Docker containers:

1. **`bin/download-latest.sh`** — fetches the latest `.deb`, `.rpm`, and `.apk` packages (amd64 + arm64) from GitHub releases into `temp/`
2. **`bin/export-gpg-public-keys.sh`** — exports the GPG public key to `public/`
3. **`bin/update-debian-repo.sh`** — generates `Packages`, `Release`, `InRelease`, and `Release.gpg` inside `public/deb/`
4. **`bin/update-redhat-repo.sh`** — runs `createrepo_c` and signs `repomd.xml` inside `public/rpm/`
5. **`bin/update-alpine-repo.sh`** — generates and RSA-signs `APKINDEX.tar.gz` for each arch inside `public/apk/`
6. **`bin/generate-index.sh`** — creates browsable HTML indexes for `public/`

### Docker Containers

Defined in `docker/compose.yml`:

| Container    | Base Image | Purpose                                      |
| ------------ | ---------- | -------------------------------------------- |
| `pkg-debian` | Debian 13  | dpkg-dev, apt-utils, gnupg — Debian/RPM work |
| `pkg-alpine` | Alpine 3   | apk-tools, abuild — Alpine APK signing       |
| `pkg-fedora` | Fedora 43  | createrepo_c — RPM metadata generation       |

### Integration Tests

Requires Docker:

```sh
bash bin/test-install-on-debian.sh
bash bin/test-install-on-alpine.sh
bash bin/test-install-on-fedora.sh
```

## CI/CD

Managed by `.gitlab-ci.yml` with four stages: `prepare` → `update-package` → `commit` → `deploy`. The pipeline can be triggered by webhook, manually, or on a schedule. Set `VERSION` as a CI variable to pin a specific release instead of using the latest.

## GPG Key

**Fingerprint:** `E48A 5D44 3314 1C78 652A 8047 847D 92F2 2892 60A7`

Key files available at:

- https://pkg.afonso.dev/afonso-dev.asc
- https://pkg.afonso.dev/afonso-dev.gpg

## License

[MIT](LICENSE)
