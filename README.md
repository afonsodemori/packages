# pkg.afonso.dev

A self-hosted Linux package repository that distributes personal CLI tools across Debian/Ubuntu, RedHat/Fedora, and Alpine Linux — without relying on any third-party package hosting.

Currently distributing: [`fns-cli`](https://github.com/afonsodemori/fns-cli) and [`afonsodev-resume-updater`](https://github.com/afonsodemori/afonsodev-resume-updater).

## Install

### Debian / Ubuntu

```bash
curl -fsSL https://pkg.afonso.dev/afonso-dev.gpg \
  | sudo tee /usr/share/keyrings/afonso-dev.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/afonso-dev.gpg] https://pkg.afonso.dev/deb ./' \
  | sudo tee /etc/apt/sources.list.d/afonso-dev.list
sudo apt update
```

### RedHat / Fedora

Create `/etc/yum.repos.d/afonso-dev.repo`:

```ini
[afonso-dev]
name=afonso.dev Package Repository
baseurl=https://pkg.afonso.dev/rpm
enabled=1
gpgcheck=1
gpgkey=https://pkg.afonso.dev/afonso-dev.asc
```

### Alpine Linux

```bash
curl -fsSL https://pkg.afonso.dev/afonso-dev.rsa.pub \
  | sudo tee /etc/apk/keys/afonso-dev.rsa.pub > /dev/null
echo 'https://pkg.afonso.dev/apk' | sudo tee -a /etc/apk/repositories
sudo apk update
```

## How It Works

Releases are fetched from GitHub, signed with GPG/RSA, and packaged into distribution-native repository formats:

| Distro family | Format           | Metadata tool                          | Signing                                |
| ------------- | ---------------- | -------------------------------------- | -------------------------------------- |
| Debian/Ubuntu | `.deb` flat repo | `dpkg-scanpackages` + `apt-ftparchive` | GPG (InRelease + Release.gpg)          |
| RedHat/Fedora | `.rpm` repo      | `createrepo_c`                         | GPG detached signature on `repomd.xml` |
| Alpine Linux  | `.apk` index     | `apk index`                            | RSA via `abuild-sign`                  |

The pipeline runs inside Docker containers to isolate the distro-specific tooling, then deploys the `public/` directory as GitLab Pages.

```
GitHub Release → download → sign → generate repo metadata → GitLab Pages
```

Each format follows its distribution's native conventions so package managers treat this as a standard repository — no custom clients or workarounds.

## CI/CD

Defined in `.gitlab-ci.yml` with 4 stages: `prepare → update-package → commit → deploy`.

- Triggered by webhook, manually, or on a schedule
- `APP` and `VERSION` are pipeline variables — omitting them defaults to the latest release of `fns-cli`
- The `commit` stage pushes updated repo metadata back to `main` via a project access token
- The `deploy` stage publishes `public/` to GitLab Pages

## Local Development

Requires Docker and a `.env` file (see `.env.example`):

```bash
make update-version   # full pipeline locally
make serve            # browse repo at http://localhost:8080
```

Integration tests spin up a fresh Docker container, configure the local server as a package source, and verify installation end-to-end:

```bash
bash bin/test-install-on-debian.sh
bash bin/test-install-on-alpine.sh
bash bin/test-install-on-fedora.sh
```

## License

[MIT](LICENSE)
