# Android 32-bit (ARMv7) port status

This branch adds initial ARMv7 build plumbing while preserving the existing
ARM64 default. It is **not yet a verified, end-to-end 32-bit port**.

## Changes implemented on this branch

- `src/android/app/build.gradle.kts` now includes both `arm64-v8a` and
  `armeabi-v7a` in the NDK ABI filters and keeps the PRoot assets uncompressed.
- `deps/build_proot.sh` accepts `OPENMINIS_ANDROID_ABI=arm64-v8a` (default) or
  `OPENMINIS_ANDROID_ABI=armeabi-v7a`. It selects the NDK target, output
  asset/JNI directory, and expected ELF machine accordingly. For ARMv7 it
  verifies and stages the vendored Termux ARM32 loader as the ABI's
  `libproot-loader.so` instead of rebuilding that loader from the fork.
- `scripts/prepare_android_sandbox.sh` selects Alpine `aarch64` or `armhf`
  and names the rootfs and PRoot assets separately.
- `RootfsManager` now selects the rootfs asset and `.arch` marker based on the
  running Android process bitness. The native PRoot executable is selected by
  Android's `nativeLibraryDir` ABI extraction.
- `deps/build_rclone_android.sh` now builds one AAR targeting both `android/arm`
  and `android/arm64`, and stages it at `src/android/app/libs/rclone.aar` for
  the existing Gradle local-AAR dependency.

Example ARMv7 build-asset preparation:

```sh
export OPENMINIS_ANDROID_ABI=armeabi-v7a
./deps/build_proot.sh
./scripts/prepare_android_sandbox.sh
./deps/build_rclone_android.sh
```

The default remains ARM64 if `OPENMINIS_ANDROID_ABI` is unset.

## Remaining blockers before this can be called supported

1. Verify that every resolved native dependency, especially the VAD/ONNX AAR,
   actually contains its `armeabi-v7a` library. The new CI job checks this in the
   built APK; an upstream build declaration alone is not sufficient proof.
2. Verify the ARM32 loader's runtime behavior with the PRoot build on a real
   32-bit device and perform an on-device shell smoke test where a command
   exits with status 0.

## Acceptance criteria

- The existing `arm64-v8a` build and sandbox continue to work unchanged.
- A 32-bit ARM device can install and launch the app.
- The embedded Linux shell starts and executes a command successfully.
- Every required native dependency is present for the selected ABI.

Until the runtime selection, dependency audit, and device tests above pass,
ARMv7 support should be treated as experimental rather than complete.
