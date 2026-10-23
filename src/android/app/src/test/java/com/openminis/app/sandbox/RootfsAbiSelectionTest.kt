package com.openminis.app.sandbox

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Fast JVM tests for the ABI-to-payload mapping used by RootfsManager.
 * These tests do not require an Android device or unpacking the root filesystem.
 */
class RootfsAbiSelectionTest {

    @Test
    fun arm64ProcessSelectsAarch64GuestAndAssets() {
        assertEquals("aarch64", RootfsManager.guestArchFor(true))
        assertEquals("alpine-minirootfs.tar.gz", RootfsManager.rootfsAssetFor(true))
        assertEquals("alpine-minirootfs.tar", RootfsManager.rootfsAssetTarFor(true))
        assertEquals("proot-aarch64", RootfsManager.prootAssetFor(true))
    }

    @Test
    fun armv7ProcessSelectsArmhfGuestAndAssets() {
        assertEquals("armhf", RootfsManager.guestArchFor(false))
        assertEquals("alpine-minirootfs-armv7.tar.gz", RootfsManager.rootfsAssetFor(false))
        assertEquals("alpine-minirootfs-armv7.tar", RootfsManager.rootfsAssetTarFor(false))
        assertEquals("proot-armv7", RootfsManager.prootAssetFor(false))
    }

    @Test
    fun arm64AndArmv7PayloadsStayDistinct() {
        assertEquals(false, RootfsManager.rootfsAssetFor(true) == RootfsManager.rootfsAssetFor(false))
        assertEquals(false, RootfsManager.prootAssetFor(true) == RootfsManager.prootAssetFor(false))
        assertEquals(false, RootfsManager.guestArchFor(true) == RootfsManager.guestArchFor(false))
    }
}
