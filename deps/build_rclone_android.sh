#!/usr/bin/env bash
# Build rclone as an Android .aar via gomobile.
#
# Android is the EASIER of the two platforms here: rclone ships an official
# gomobile binding (librclone/gomobile) and upstream documents this exact
# command. iOS is the one upstream has not tested.
#
# One deviation from upstream's command: their gomobile package hardcodes
# `backend/all` (all 70 backends). We bind ./gomobile instead, which re-exports
# the same API against the trimmed backend list in backends/backends.go.
#
# Output: deps/build/rclone/rclone.aar
# Consume it by copying the .so into src/android/app/src/main/jniLibs/arm64-v8a/
# (the same place libproot.so lives), or by importing the .aar directly.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/deps/rclone-mobile"
BUILD="$ROOT/deps/build/rclone"
TARGET_ABI="${OPENMINIS_ANDROID_ABI:-arm64-v8a}"
case "$TARGET_ABI" in
  arm64-v8a) GOMOBILE_TARGET="android/arm64" ;;
  armeabi-v7a) GOMOBILE_TARGET="android/arm" ;;
  *) echo "error: unsupported OPENMINIS_ANDROID_ABI='$TARGET_ABI' (expected arm64-v8a or armeabi-v7a)" >&2; exit 1 ;;
esac

command -v go >/dev/null || { echo "error: go toolchain not found" >&2; exit 1; }
command -v gomobile >/dev/null || {
  echo "error: gomobile not installed. Run:" >&2
  echo "  go install golang.org/x/mobile/cmd/gomobile@latest" >&2
  echo "  gomobile init" >&2
  exit 1
}
[ -n "${ANDROID_NDK_HOME:-}${ANDROID_HOME:-}" ] || {
  echo "error: set ANDROID_NDK_HOME (or ANDROID_HOME) first" >&2; exit 1; }

mkdir -p "$BUILD"
cd "$SRC"

# Build one ABI per invocation, matching OPENMINIS_ANDROID_ABI in build_proot.sh.
gomobile bind -v \
  -target="$GOMOBILE_TARGET" \
  -androidapi 24 \
  -javapkg=com.openminis.rclone \
  -ldflags="-s -w" \
  -o "$BUILD/rclone-$TARGET_ABI.aar" \
  ./gomobile

echo "==> $BUILD/rclone-$TARGET_ABI.aar"
du -sh "$BUILD/rclone-$TARGET_ABI.aar" | awk '{print "    size:", $1}'
