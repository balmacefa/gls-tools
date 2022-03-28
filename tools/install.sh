#!/bin/bash
#
# install-gls.sh
#
# Description:
# Installs gitpod-laravel-starter.
# Interactive prompts with automated backup when existing project files will be overwritten.

latest_version='1.5.0'

# Latest tarball url for gitpod.laravel-starter. Set via set_release_data()
latest_tarball_url='https://api.github.com/repos/apolopena/gitpod-laravel-starter/tarball/v1.5.0'

install_latest() {
  if ! curl -sL "$latest_tarball_url" | tar xz --strip=1; then return 1; fi
}

init() {
  local msg
  msg="Downloading and extracting the latest version of gitpod-laravel-starter v$latest_version\nfrom:"
  if ! spinner_task "$msg\n\t$latest_tarball_url\nto:\n\t$(pwd)" "install_latest"; then return 1; fi
  install_latest;
}

main() {
  if ! init; then echo "Script aborted" && exit 1; fi
}

main

