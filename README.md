# Neovim Nightly Package Installer

Shell script for installing the nightly release package on Debian-based operating systems.

## Features

1. Checks the latest nightly version
2. Compares currently installed version
3. Creates `/tmp` directories to download the binaries
4. Compares the checksum
5. Extracts the tar file
6. Reconfigure the directories to install in `usr/local/`
7. Creates the `DEBIAN/control` file
8. Creates the deb package
9. Removes the currently installed neovim package (not neovim-runtime)
10. Installs the new deb package

## Installation

Run command:

```sh
sudo sh nvim.sh
```
