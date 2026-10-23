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
- `deps/build_rclone_android.sh` accepts the same ABI variable and builds
  `android/arm64` or `android/arm` into a correspondingly named AAR.

Example ARMv7 build-asset preparation:

```sh
export OPENMINIS_ANDROID_ABI=armeabi-v7a
./deps/build_proot.sh
./scripts/prepare_android_sandbox.sh
./deps/build_rclone_android.sh
```

The default remains ARM64 if `OPENMINIS_ANDROID_ABI` is unset.

## Remaining blockers before this can be called supported

1. **Runtime selection is not wired yet.** App code must select the matching
   PRoot binary and rootfs for the device/process ABI. Merely staging both
   assets does not make the app use the ARMv7 pair.
2. **The rclone AAR is not automatically switched by Gradle.** The generated
   `rclone-armeabi-v7a.aar` must be integrated into the Android build in a
   reproducible way, without dropping ARM64 support.
3. **Audit bundled AAR/native payloads.** The current VAD/ONNX dependency and
   any other prebuilt native libraries must be checked for `armeabi-v7a`
   support. An ABI filter cannot manufacture missing native binaries.
4. Verify the ARM32 loader's runtime behavior with the PRoot build on a real
   32-bit device; validate the Alpine `armhf` URL and ELF execution.
5. Run Gradle unit tests, inspect APK contents for both ABIs, and perform an
   on-device shell smoke test where a command exits with status 0.

## Acceptance criteria

- The existing `arm64-v8a` build and sandbox continue to work unchanged.
- A 32-bit ARM device can install and launch the app.
- The embedded Linux shell starts and executes a command successfully.
- Every required native dependency is present for the selected ABI.

Until the runtime selection, dependency audit, and device tests above pass,
ARMv7 support should be treated as experimental rather than complete.
