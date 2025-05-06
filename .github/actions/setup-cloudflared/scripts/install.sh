#!/bin/bash
set -euo pipefail

# Variables from environment (passed by action.yml)
VERSION="$CLOUDFLARED_VERSION"
OS="$TARGET_OS"          # linux, darwin, windows
ARCH="$TARGET_ARCH"        # amd64, arm64
INSTALL_DIR="$INSTALL_DIR" # e.g., /home/runner/work/_temp/runner_tool_cache/cloudflared/2024.4.1/amd64
RUNNER_OS="$RUNNER_OS_ORIGINAL" # Linux, macOS, Windows

echo "::group::Downloading cloudflared $VERSION for $RUNNER_OS ($ARCH)"
echo "OS Identifier: $OS"
echo "Architecture: $ARCH"
echo "Install Directory: $INSTALL_DIR"

BASE_URL="${GITHUB_SERVER_URL:-https://github.com}/cloudflare/cloudflared/releases/download/$VERSION"
ASSET_NAME=""
EXECUTABLE_NAME="cloudflared" # Default name

# Determine asset name and download method based on OS and Arch
if [ "$OS" = "linux" ]; then
  ASSET_NAME="cloudflared-$OS-$ARCH"
  DOWNLOAD_URL="$BASE_URL/$ASSET_NAME"
  DEST_PATH="$INSTALL_DIR/$EXECUTABLE_NAME"
  echo "Downloading $ASSET_NAME from $DOWNLOAD_URL to $DEST_PATH"
  curl -sfLo "$DEST_PATH" "$DOWNLOAD_URL"
  chmod +x "$DEST_PATH"
elif [ "$OS" = "darwin" ]; then
  ASSET_NAME="cloudflared-$OS-$ARCH.tgz"
  DOWNLOAD_URL="$BASE_URL/$ASSET_NAME"
  DEST_PATH="$INSTALL_DIR/$EXECUTABLE_NAME"
  echo "Downloading $ASSET_NAME from $DOWNLOAD_URL and extracting to $INSTALL_DIR"
  curl -sfL "$DOWNLOAD_URL" | tar -xz -C "$INSTALL_DIR" "$EXECUTABLE_NAME"
  chmod +x "$DEST_PATH"
elif [ "$OS" = "windows" ]; then
  # Handle potential Windows ARM fallback where ARCH might be amd64
  # but the actual runner could be ARM64. The .exe is usually amd64.
  if [ "$ARCH" = "arm64" ]; then
     echo "::warning::Windows ARM64 detected, but downloading AMD64 executable as ARM64 .exe is typically unavailable."
     # Use amd64 asset even if arch is arm64 for Windows
     ASSET_NAME="cloudflared-$OS-amd64.exe"
  else
     ASSET_NAME="cloudflared-$OS-$ARCH.exe"
  fi
  EXECUTABLE_NAME="cloudflared.exe" # Adjust executable name for Windows
  DOWNLOAD_URL="$BASE_URL/$ASSET_NAME"
  DEST_PATH="$INSTALL_DIR/$EXECUTABLE_NAME"
  echo "Downloading $ASSET_NAME from $DOWNLOAD_URL to $DEST_PATH"
  curl -sfLo "$DEST_PATH" "$DOWNLOAD_URL"
  # No chmod needed on Windows
else
  echo "::error::Unsupported OS identifier: $OS"
  exit 1
fi

echo "Download and setup complete."
echo "Executable path: $DEST_PATH"

# Save the executable path to a file for the action step to read
echo "$DEST_PATH" > "$INSTALL_DIR/executable_path.txt"

echo "::endgroup::"
