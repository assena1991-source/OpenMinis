# Android 32-bit (ARMv7) port plan

This fork tracks the work needed to add 32-bit ARM Android support without
breaking the existing 64-bit ARM build.

## Current baseline

The public upstream build is 64-bit ARM only:

- `src/android/app/build.gradle.kts` filters native APK libraries to
  `arm64-v8a`.
- `deps/build_proot.sh` cross-compiles PRoot with the
  `aarch64-linux-android` NDK target and installs an aarch64 guest launcher.
- `scripts/prepare_android_sandbox.sh` downloads the Alpine **aarch64**
  minirootfs.
- `deps/build_rclone_android.sh` builds the Go mobile binding for
  `android/arm64`.

Changing only Gradle's ABI filter would produce an APK with missing or
incompatible native dependencies; it would not be a working 32-bit port.

## Required implementation

1. Add an explicit ARMv7 build target (`armeabi-v7a`) while retaining the
   current `arm64-v8a` target.
2. Make the PRoot build select the NDK triple and output JNI directory from the
   selected ABI, and verify the resulting ELF machine type.
3. Build the PRoot ELF loaders for ARMv7 as well as the existing ARM64 loaders.
4. Prepare an Alpine `armhf` root filesystem for the 32-bit guest, and select
   the matching rootfs and PRoot asset at runtime.
5. Build the rclone binding for Android ARM (`gomobile -target=android/arm`)
   and ensure the resulting AAR contains the expected ABI.
6. Audit other bundled/native dependencies and Kotlin/JNI assumptions for
   32-bit pointer size, then run Gradle unit tests and an on-device shell smoke
   test (a command must return exit code 0).

## Acceptance criteria

- The existing `arm64-v8a` build continues to work unchanged.
- A 32-bit ARM device can install and launch the app.
- The embedded Linux shell starts and executes a command successfully.
- The APK contains the correct ARMv7 JNI libraries and no ARM64-only native
  payload is required by the 32-bit process.

This document is a port checklist, not a claim that ARMv7 support is complete.
