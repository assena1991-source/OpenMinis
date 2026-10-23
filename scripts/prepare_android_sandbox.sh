#!/usr/bin/env bash
#
# Prepare Android sandbox assets in src/android/app/src/main/assets/:
#   1. Download the Alpine Linux aarch64 minirootfs
#   2. Check that the PRoot binary is present
#
# The PRoot binary (assets/proot-aarch64) is produced by deps/build_proot.sh,
# which must run first. This script used to fall back to downloading a Termux
# proot .deb, but that package version has been rotated out of
# packages.termux.dev (404), so the fallback could only fail.
#
# Usage: ./deps/build_proot.sh && ./scripts/prepare_android_sandbox.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$PROJECT_ROOT/src/android/app/src/main/assets"

ALPINE_VERSION="3.21"
ALPINE_RELEASE="3.21.3"
TARGET_ABI="${OPENMINIS_ANDROID_ABI:-arm64-v8a}"
case "$TARGET_ABI" in
    arm64-v8a)
        ALPINE_ARCH="aarch64"
        ROOTFS_NAME="alpine-minirootfs.tar.gz"
        PROOT_NAME="proot-aarch64"
        ;;
    armeabi-v7a)
        ALPINE_ARCH="armhf"
        ROOTFS_NAME="alpine-minirootfs-armv7.tar.gz"
        PROOT_NAME="proot-armv7"
        ;;
    *) echo "Unsupported OPENMINIS_ANDROID_ABI='$TARGET_ABI'" >&2; exit 1 ;;
esac
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/${ALPINE_ARCH}/alpine-minirootfs-${ALPINE_RELEASE}-${ALPINE_ARCH}.tar.gz"

mkdir -p "$ASSETS_DIR"

ROOTFS_FILE="$ASSETS_DIR/$ROOTFS_NAME"
PROOT_FILE="$ASSETS_DIR/$PROOT_NAME"

# --- Alpine rootfs ---
if [ -f "$ROOTFS_FILE" ]; then
    echo "✓ Alpine rootfs already exists: $ROOTFS_FILE"
else
    echo "Downloading Alpine Linux ${ALPINE_RELEASE} ${ALPINE_ARCH} minirootfs..."
    curl -fSL -o "$ROOTFS_FILE" "$ALPINE_URL"
    echo "✓ Downloaded: $ROOTFS_FILE ($(du -h "$ROOTFS_FILE" | cut -f1))"
fi

# --- PRoot binary ---
if [ -f "$PROOT_FILE" ]; then
    echo "✓ PRoot binary present: $PROOT_FILE"
else
    echo "Error: $PROOT_FILE is missing." >&2
    echo "       It is built from source by ./deps/build_proot.sh — run that first," >&2
    echo "       then rerun this script." >&2
    exit 1
fi

echo ""
echo "Assets ready in: $ASSETS_DIR"
ls -lh "$ASSETS_DIR"
