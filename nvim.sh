#!/bin/bash

# Exit immediately if anything returns a non-zero exit status
set -e

REPO="neovim/neovim"
INSTALL_DIR="/usr/local"
PKG_NAME="neovim"
ARCH="amd64"
TAR_FILE="nvim-linux-x86_64.tar.gz"
CHECKSUM_FILE="shasum.txt"

# Get latest release tag from GitHub
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/tags/nightly" | jq -r .body | sed -n '2{s/^[^v]*v\(.*\)/\1/p}')

# Get installed version
INSTALLED_VERSION=$($INSTALL_DIR/bin/nvim --version | head -n1 | awk '{print $2}' | sed 's/^v//')

# Compare versions
if [ "$LATEST_VERSION" = "$INSTALLED_VERSION" ]; then
  echo "Neovim is already up to date (version $INSTALLED_VERSION)."
  exit 0
fi

echo "Updating Neovim from $INSTALLED_VERSION to $LATEST_VERSION..."

# Download latest release
echo "Creating tmp directories"
TMP_DIR="/tmp/$PKG_NAME $LATEST_VERSION"
DEB_DIR="$TMP_DIR/nvim-linux-x86_64"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
sudo curl -LO "https://github.com/$REPO/releases/download/nightly/$TAR_FILE"
sudo curl -LO "https://github.com/$REPO/releases/download/nightly/$CHECKSUM_FILE"

# Remove all lines from the checksum file that doesn't contain the TAR_FILE file name
grep "$TAR_FILE" "$CHECKSUM_FILE" >"$CHECKSUM_FILE.filtered"
mv "$CHECKSUM_FILE.filtered" "$CHECKSUM_FILE"

# Verify checksum
sha256sum -c "$CHECKSUM_FILE" || {
  echo "Checksum verification failed!"
  exit 1
}

# Extract and configure directories
tar xzf "$TAR_FILE"
cd "nvim-linux-x86_64"
sudo mkdir -p "$DEB_DIR/DEBIAN" "$DEB_DIR/usr/local"
sudo mv "bin" "usr/local"
sudo mv "lib" "usr/local"
sudo mv "share" "usr/local"

sudo cat <<EOF >"$DEB_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $LATEST_VERSION
Section: editors
Priority: optional
Architecture: $ARCH
Depends: libc6 (>= 2.29)
Maintainer: avargas05 <avargas05.github@outlook.com>
Description: heavily refactored vim fork (nightly)
EOF

dpkg-deb --build "$DEB_DIR"

# Remove current package
sudo apt remove neovim

# Install the package
sudo dpkg -i "$DEB_DIR.deb"

echo "Removing tmp files"
sudo rm -rf "$TMP_DIR"

echo "Neovim $LATEST_VERSION installed successfully."
