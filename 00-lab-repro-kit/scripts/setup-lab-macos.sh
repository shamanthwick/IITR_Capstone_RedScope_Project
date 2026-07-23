#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lab_root="$(cd "${script_dir}/.." && pwd)"

if [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
  echo "Unsupported host architecture: $(uname -m)"
  echo "These OVAs are x86/amd64 VirtualBox images and are not suitable for Apple Silicon/ARM64 Macs."
  exit 1
fi

missing=0
for command_name in pwsh docker VBoxManage; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Missing required command: ${command_name}"
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  echo
  echo "Install the missing prerequisites, then rerun this script."
  echo "Required: PowerShell 7, Docker Desktop, VirtualBox, and MEGAcmd with mega-get in PATH."
  exit 1
fi

if ! command -v mega-get >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Missing required command: mega-get"
    echo "Install MEGAcmd from https://mega.nz/cmd, or install Homebrew so this script can install MEGAcmd automatically."
    exit 1
  fi

  echo "MEGAcmd is missing. Installing MEGAcmd with Homebrew..."
  brew install --cask --appdir=/Applications megacmd-app
fi

export PATH="/Applications/MEGAcmd.app/Contents/MacOS:${PATH}"

if ! command -v mega-get >/dev/null 2>&1; then
  echo "MEGAcmd installation was attempted, but mega-get is still not available."
  echo "Confirm MEGAcmd is installed under /Applications/MEGAcmd.app and rerun this script."
  exit 1
fi

exec pwsh -NoProfile -ExecutionPolicy Bypass -File "${script_dir}/setup-lab.ps1" -Root "${lab_root}" "$@"
