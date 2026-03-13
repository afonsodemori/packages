# afonso.dev Package Repository

This repository hosts the personal package repository for `fns-cli` and other custom tools maintained by [@afonsodemori](https://github.com/afonsodemori).

It is a fully automated, static package registry served directly from the `docs/` folder (likely via GitHub Pages at `https://pkg.afonso.dev`), supporting Debian, RedHat, and Alpine Linux distributions across `amd64` and `arm64` architectures.

## 📦 Supported Platforms & Installation

The repository provides signed packages for multiple package managers. Follow the instructions below to add the repository and install `fns-cli` on your system.

### Debian / Ubuntu (`apt`)

```bash
# Import the GPG key
curl -fsSL https://pkg.afonso.dev/afonso-dev.gpg | sudo tee /usr/share/keyrings/afonso-dev.gpg > /dev/null

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/afonso-dev.gpg] https://pkg.afonso.dev/deb ./" | sudo tee /etc/apt/sources.list.d/afonso-dev.list

# Install packages
sudo apt update && sudo apt install fns-cli

```

### RedHat / Fedora / AlmaLinux (`yum` / `dnf`)

Create a new repository file at `/etc/yum.repos.d/afonso-dev.repo` with the following content:

```ini
[afonso-dev]
name=afonso.dev Package Repository
baseurl=https://pkg.afonso.dev/rpm
enabled=1
gpgcheck=1
gpgkey=https://pkg.afonso.dev/afonso-dev.asc

```

### Alpine Linux (`apk`)

```bash
# 1. Download the repository public key
sudo wget -O /etc/apk/keys/afonso-dev.rsa.pub https://pkg.afonso.dev/afonso-dev.rsa.pub

# 2. Add the repository to your system
echo "https://pkg.afonso.dev/apk" | sudo tee -a /etc/apk/repositories

# 3. Update and install
sudo apk update

```

---

## ⚙️ How It Works (Automation)

This repository is maintained completely hands-off via a GitHub Actions workflow (`Update Package Repository`).

1. **Trigger:** The workflow listens for a `repository_dispatch` event of type `new-release`. This is typically triggered remotely by the `afonsodemori/fns-cli` repository whenever a new version is tagged.
2. **Artifact Fetching:** It downloads the compiled `.deb`, `.rpm`, and `.apk` assets for the specified version using the GitHub CLI (`gh`).
3. **Key Management:** Private GPG and RSA keys are imported from GitHub Secrets to sign the repositories, while the public equivalents (`.asc`, `.gpg`) are exported to the static site.
4. **Repository Generation:**
   - **DEB:** Uses `dpkg-scanpackages` and `apt-ftparchive` to generate `Packages.gz`, `Release`, and `InRelease` files.
   - **RPM:** Uses `createrepo_c` to build the `repodata/` XML and SQLite metadata.
   - **APK:** Spins up a lightweight Alpine Docker container to run `apk index` and `abuild-sign` to generate the `APKINDEX.tar.gz`.

5. **Deployment:** The updated indices and new packages are committed directly to the `docs/` directory, updating the static site automatically.

---

## 📂 Repository Structure

- `docs/`: The root of the static site (served via GitHub Pages).
- `index.html`: The landing page with installation instructions.
- `apk/`: Alpine Linux package directory and signed `APKINDEX`.
- `deb/`: Debian/Ubuntu package directory and `apt` metadata.
- `rpm/`: RedHat/Fedora package directory and `repodata` metadata.
- `*.gpg`, `*.asc`, `*.rsa.pub`: Public keys for package verification.
