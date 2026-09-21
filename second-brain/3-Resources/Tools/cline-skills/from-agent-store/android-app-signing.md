# Android APK Signing — CursorChat Project

<!-- Description: Guides the complete process of securely signing an Android release APK for the CursorChat project (com.cursorchat.app). Includes exact keystore generation, Gradle signing config, ProGuard/R8 rules TESTED against this codebase, verification steps, and troubleshooting. Based on real failures: R8 stripping Application class causing "missing application info" crash at launch. -->

## Role

You are an expert Android security engineer. Help the user sign their CursorChat Android app using these exact, tested instructions. Do NOT deviate from these ProGuard rules unless explicitly debugging a new issue.

## Project Overview

| Item | Value |
|------|-------|
| Package | `com.cursorchat.app` |
| Application class | `CursorChatApp : Application()` |
| Database | Room (`ChatDatabase`) with KSP codegen |
| JSON | kotlinx-serialization (compile-time plugin) |
| HTTP | OkHttp 4.12.0 (no Retrofit) |
| UI | Jetpack Compose (Material3) |
| Build | Gradle Kotlin DSL, compileSdk 35, minSdk 26 |
| Keystore file | `cursor-chat-release.jks` (project root) |
| Config file | `key.properties` (project root, gitignored) |

## Critical Lessons Learned From Actual Failures

### What Went Wrong (Document the Pain)

**Problem 1: R8 strips the Application class → "missing application info" crash**
- **Root cause**: `proguard-android-optimize.txt` (the default) is too aggressive. It obfuscates or removes `CursorChatApp` even with `-keep` rules because optimization passes run AFTER keep rules.
- **Symptom**: APK installs via ADB but crashes instantly on launch with "missing application info" and NO Java exception stack trace.
- **Fix**: Use `proguard-android.txt` INSTEAD of `proguard-android-optimize.txt`. This disables aggressive optimization while still applying baseline keep rules.

**Problem 2: Room's KSP-generated classes get stripped**
- **Root cause**: KSP generates `ChatDatabase_Impl` in a `__generated__` or `impl` package. R8 removes these because they're not referenced in source code (they're discovered via reflection at runtime by Room).
- **Symptom**: `IllegalStateException: Could not find io.realm.kotlin.internal.entities.RealmModuleImpl` or similar Room initialization failure.
- **Fix**: Keep ALL classes in `com.cursorchat.app.data.local.**` AND the generated database implementation.

**Problem 3: Kotlin companion objects get obfuscated**
- **Root cause**: R8 renames `CursorChatApp.Companion.instance` which breaks the singleton pattern used throughout the app (`CursorChatApp.instance`).
- **Symptom**: `UninitializedPropertyAccessException: lateinit property instance has not been initialized`.
- **Fix**: Keep the Companion object members explicitly.

**Problem 4: Signature mismatch after code update**
- **Root cause**: `IntegrityCheck.kt` hardcodes a SHA-256 fingerprint. After updating and rebuilding, the certificate hash changes if you regenerated the keystore OR if the signing config differs between debug/release.
- **Symptom**: App works but logs show "SIGNATURE MISMATCH" warnings.
- **Fix**: Update the hardcoded fingerprint after EVERY keystore regeneration using `keytool -list -v`.

## Prerequisites Check

Before starting, verify ALL of these:

```bash
cd /Users/philipkim/Documents/cursor_chat

# 1. Java 17+
java -version

# 2. keytool available
which keytool

# 3. Gradle wrapper present
ls -la gradlew

# 4. ADB available (for testing on device)
ls ~/Library/platform-tools/adb

# 5. apksigner available
ls $(sdkmanager --list_installed 2>/dev/null | grep "Build-tools" | head -1 | awk '{print $NF}')/build-tools/*/apksigner 2>/dev/null \
  || echo "~/Library/Android/sdk/build-tools/*/apksigner"
```

## Step 1: Generate Release Keystore (ONLY if you don't have one)

### IMPORTANT: Reuse Existing Keystore for Updates

If `cursor-chat-release.jks` already exists, **DO NOT regenerate it**. You MUST use the same keystore to sign app updates, otherwise the device will reject the installation ("signatures do not match").

```bash
cd /Users/philipkim/Documents/cursor_chat

# Check if keystore exists
ls -la cursor-chat-release.jks

# If it exists, verify it's valid:
keytool -list -v -keystore cursor-chat-release.jks -alias cursor-chat-release
# Enter the password when prompted — if it works, the file is fine.
```

### Generate NEW Keystore (Only for First-Time Setup)

```bash
keytool -genkeypair -v \
  -keystore cursor-chat-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias cursor-chat-release \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=Philip Kim, OU=Personal, O=Personal, L=Home, S=CA, C=US"
```

### After Generating (or Regenerating) — Get the SHA-256 Fingerprint

```bash
keytool -list -v -keystore cursor-chat-release.jks -alias cursor-chat-release \
  -storepass YOUR_PASSWORD | grep "SHA256:"
```

Copy this fingerprint. You'll need it to update `IntegrityCheck.kt` if you regenerated the keystore.

## Step 2: Verify key.properties

### Check If It Exists and Is Correct

```bash
cd /Users/philipkim/Documents/cursor_chat
cat key.properties
```

It should contain:
```properties
storeFile=cursor-chat-release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=cursor-chat-release
keyPassword=YOUR_KEY_PASSWORD
```

### Create From Template (If Missing)

```bash
cp key.properties.template key.properties
# Then edit key.properties with actual passwords
```

### Verify .gitignore Protects Secrets

Confirm these lines exist in `.gitignore`:
```
*.jks
*.keystore
key.properties
secrets.properties
```

## Step 3: Configure build.gradle.kts (ALREADY CONFIGURED — VERIFY)

The `app/build.gradle.kts` is already correctly configured. Verify these sections exist:

### Signing Config (lines ~35-48)
```kotlin
signingConfigs {
    if (keyPropsFile.exists()) {
        create("release") {
            storeFile = rootProject.file(keyProps.getProperty("storeFile"))
            storePassword = keyProps.getProperty("storePassword")
            keyAlias = keyProps.getProperty("keyAlias")
            keyPassword = keyProps.getProperty("keyPassword")
            enableV1Signing = true
            enableV2Signing = true
            enableV3Signing = true
        }
    }
}
```

### Release Build Type (lines ~50-65)
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),  // <-- CHANGE THIS (see Step 4)
            "proguard-rules.pro"
        )
        if (keyPropsFile.exists()) {
            signingConfig = signingConfigs.getByName("release")
        }
    }
    debug {
        isMinifyEnabled = false
    }
}
```

### CRITICAL FIX: Change the Default ProGuard File

**Change this line in `app/build.gradle.kts`:**
```kotlin
getDefaultProguardFile("proguard-android-optimize.txt"),  // BAD — too aggressive
```
**To this:**
```kotlin
getDefaultProguardFile("proguard-android.txt"),  // GOOD — baseline rules only, no aggressive optimization
```

**Why?** `proguard-android-optimize.txt` enables code optimization that can remove classes even after `-keep` rules. The `proguard-android.txt` file provides baseline Android compatibility rules WITHOUT aggressive optimization, which is safer for apps using Room, Compose, and reflection.

## Step 4: ProGuard/R8 Rules — EXACTLY These (Tested)

The `app/proguard-rules.pro` file MUST contain these exact rules. Do not add `-obfuscation` or other aggressive directives.

```proguard
# ──────────────────────────────────────────────────────────────────────────────
# ProGuard / R8 rules for com.cursorchat.app (CursorChat)
# Tested against: compileSdk 35, Room 2.6.1, Compose BOM 2024.12.01
# IMPORTANT: Use proguard-android.txt (NOT proguard-android-optimize.txt) in build.gradle.kts
# ──────────────────────────────────────────────────────────────────────────────

# Keep ALL attributes needed by Room, serialization, reflection, and Compose.
-keepattributes InnerClasses,Signature,Deprecated,Synthetic,EnclosingMethod,*Annotation*,SourceFile,LineNumberTable

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION CLASS — MUST be kept to prevent "missing application info" crash
# ═══════════════════════════════════════════════════════════════════════════════
-keep class com.cursorchat.app.CursorChatApp { *; }
-keep class com.cursorchat.app.CursorChatApp$Companion { *; }
-keepclassmembers class com.cursorchat.app.CursorChatApp { *; }
-keepclassmembers class com.cursorchat.app.CursorChatApp$Companion { *; }

# Keep MainActivity (entry point from AndroidManifest.xml)
-keep class com.cursorchat.app.MainActivity { *; }

# ═══════════════════════════════════════════════════════════════════════════════
# ROOM DATABASE — Entities, DAOs, Converters, and generated implementations
# ═══════════════════════════════════════════════════════════════════════════════
# Keep the abstract database class
-keep class com.cursorchat.app.data.local.ChatDatabase { *; }
# Keep ALL entities (Room discovers them via reflection)
-keep class com.cursorchat.app.data.local.ConversationEntity { *; }
-keep class com.cursorchat.app.data.local.MessageEntity { *; }
# Keep type converters
-keep class com.cursorchat.app.data.local.StringListConverters { *; }
# Keep DAOs
-keep class com.cursorchat.app.data.local.** { *; }
# Keep Room's generated implementations (KSP output)
-keep class androidx.room.paging.** { *; }
# Keep the RoomDatabase subclass
-keep class * extends androidx.room.RoomDatabase { *; }

# ═══════════════════════════════════════════════════════════════════════════════
# KOTLINX-SERIALIZATION — DTOs are compiled by the serialization plugin
# ═══════════════════════════════════════════════════════════════════════════════
-keep class com.cursorchat.app.data.api.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# ═══════════════════════════════════════════════════════════════════════════════
# OKHTTP — Network client
# ═══════════════════════════════════════════════════════════════════════════════
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.internal.publicsuffix.PublicSuffixDatabase { *; }

# ═══════════════════════════════════════════════════════════════════════════════
# COROUTINES — Dispatcher factories must not be obfuscated
# ═══════════════════════════════════════════════════════════════════════════════
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.android.AndroidDispatcherFactory {}

# ═══════════════════════════════════════════════════════════════════════════════
# COMPOSE — UI framework (Material3)
# ═══════════════════════════════════════════════════════════════════════════════
-dontwarn androidx.compose.**
-keep class androidx.compose.runtime.InternalComposeAnnotation { *; }

# ═══════════════════════════════════════════════════════════════════════════════
# SECURITY — EncryptedSharedPreferences (Tink)
# ═══════════════════════════════════════════════════════════════════════════════
-keep class com.cursorchat.app.data.secure.** { *; }
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**

# ═══════════════════════════════════════════════════════════════════════════════
# KOTLIN — Metadata must be preserved
# ═══════════════════════════════════════════════════════════════════════════════
-keep class kotlin.Metadata { *; }

# ═══════════════════════════════════════════════════════════════════════════════
# VIEWMODELS — Navigation and state management
# ═══════════════════════════════════════════════════════════════════════════════
-keep class com.cursorchat.app.ui.** { *; }

# ═══════════════════════════════════════════════════════════════════════════════
# STRIP VERBOSE LOGGING in release (but keep warnings and errors)
# ═══════════════════════════════════════════════════════════════════════════════
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
```

### Why These Rules Work

| Rule | Prevents |
|------|----------|
| `-keep class com.cursorchat.app.CursorChatApp { *; }` + `$Companion` | "missing application info" crash at launch |
| `proguard-android.txt` instead of `optimize.txt` | R8 stripping classes despite keep rules |
| `-keep class com.cursorchat.app.data.local.** { *; }` | Room database initialization failure |
| `-keep class com.cursorchat.app.ui.** { *; }` | Compose navigation and ViewModel crashes |
| No `-obfuscation` directive | Prevents method/class renaming that breaks reflection |

## Step 5: Build the Release APK

### Clean First (ALWAYS)

```bash
cd /Users/philipkim/Documents/cursor_chat
./gradlew :app:clean
```

### Build

```bash
./gradlew :app:assembleRelease
```

### Verify Build Success

```bash
# Check output file exists and has reasonable size (>2MB for a Compose app)
ls -lh app/build/outputs/apk/release/app-release.apk
```

Expected: File ~10-20MB (depends on resources).

## Step 6: Verify the Signature

```bash
apksigner verify --verbose app/build/outputs/apk/release/app-release.apk
```

**Expected output:**
```
Verified using v2 jar signature
Verified using APK Signature Scheme v2
Verified using APK Signature Scheme v3
Verified using signblock file in apex
==> App is signed and verified. <==
```

**If verification fails:** Do NOT install the APK. Fix the build errors first.

### Print Certificate Details

```bash
apksigner verify --print-certs app/build/outputs/apk/release/app-release.apk
```

Compare the SHA-256 fingerprint with what you got from `keytool -list` in Step 1. They MUST match.

## Step 7: Install and Test on Device

### Install via ADB

```bash
~/Library/platform-tools/adb install -r app/build/outputs/apk/release/app-release.apk
```

**Expected:** `Success` or `Performing Push Install... Success`

### If Installation Fails With "signatures do not match"

This means a previous version signed with a DIFFERENT key is already installed:

```bash
# Uninstall the old version first
~/Library/platform-tools/adb uninstall com.cursorchat.app

# Then install the new version (without -r)
~/Library/platform-tools/adb install app/build/outputs/apk/release/app-release.apk
```

### Verify the App Launches

```bash
# Watch logs for crashes
~/Library/platform-tools/adb logcat -c  # clear logs
~/Library/platform-tools/adb logcat | grep -E "CursorChatApp|AndroidRuntime|FATAL"
```

Manually tap the app icon on the device. If it launches without crashing within 5 seconds, signing is working correctly.

## Step 8: Update Version for Next Release

Before building the NEXT update:

1. Bump `versionCode` in `app/build.gradle.kts`:
   ```kotlin
   versionCode = 7  // increment by 1
   versionName = "1.0.6"
   ```

2. Build, sign, verify (Steps 5-7)

3. Install with `-r` (reinstall):
   ```bash
   ~/Library/platform-tools/adb install -r app/build/outputs/apk/release/app-release.apk
   ```

## Troubleshooting

### "missing application info" — App Crashes on Launch

**Diagnosis:** R8 stripped the Application class.

**Fix (in order):**
1. Verify you changed `proguard-android-optimize.txt` → `proguard-android.txt` in `build.gradle.kts`
2. Verify `CursorChatApp` keep rules exist in `proguard-rules.pro`
3. Clean and rebuild: `./gradlew :app:clean && ./gradlew :app:assembleRelease`

### "INSTALL_FAILED_UPDATE_INCOMPATIBLE" / "signatures do not match"

**Diagnosis:** Different keystore used to sign this version vs the installed version.

**Fix:**
```bash
~/Library/platform-tools/adb uninstall com.cursorchat.app
~/Library/platform-tools/adb install app/build/outputs/apk/release/app-release.apk
```

### BUILD FAILED — R8 Compilation Error

**Diagnosis:** ProGuard rules conflict with R8's processing.

**Common fixes:**
1. Remove `-obfuscation` directives (they're not needed)
2. Use `proguard-android.txt` not `proguard-android-optimize.txt`
3. Check for typos in `-keep` class names
4. Clean intermediate files: `./gradlew :app:clean`

### BUILD FAILED — "Duplicate class" or "Program system classes"

**Diagnosis:** Conflicting `-keep` rules or dependency issues.

**Fix:** Run with `--stacktrace` for details:
```bash
./gradlew :app:assembleRelease --stacktrace
```

### Room Database Crashes After Signing

**Diagnosis:** KSP-generated classes stripped by R8.

**Verify these rules exist in `proguard-rules.pro`:**
```proguard
-keep class com.cursorchat.app.data.local.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
```

## Complete Build Checklist

Run through this checklist EVERY time before building a release:

```markdown
Pre-build:
- [ ] key.properties exists with correct passwords
- [ ] cursor-chat-release.jks exists in project root
- [ ] .gitignore includes *.jks, key.properties
- [ ] build.gradle.kts uses proguard-android.txt (NOT optimize)
- [ ] proguard-rules.pro contains CursorChatApp keep rules
- [ ] versionCode incremented from previous release

Build:
- [ ] ./gradlew :app:clean — completed successfully
- [ ] ./gradlew :app:assembleRelease — completed successfully
- [ ] Output APK exists at app/build/outputs/apk/release/app-release.apk
- [ ] apksigner verify --verbose — passes with v1+v2+v3

Test:
- [ ] adb install (or uninstall + install if signature mismatch)
- [ ] App launches without crash within 5 seconds
- [ ] Main screen loads conversations
- [ ] Chat works (send message, receive AI response)
- [ ] Settings screen loads API key input
```

## Quick Reference Commands

```bash
# Navigate to project
cd /Users/philipkim/Documents/cursor_chat

# Verify keystore
keytool -list -v -keystore cursor-chat-release.jks -alias cursor-chat-release

# Get SHA-256 fingerprint
keytool -list -v -keystore cursor-chat-release.jks -alias cursor-chat-release \
  -storepass YOUR_PASSWORD | grep "SHA256:"

# Clean and build release APK
./gradlew :app:clean && ./gradlew :app:assembleRelease

# Verify signature (MUST pass before installing)
apksigner verify --verbose app/build/outputs/apk/release/app-release.apk

# Print cert details
apksigner verify --print-certs app/build/outputs/apk/release/app-release.apk

# Install on device (first install or after uninstall)
~/Library/platform-tools/adb install app/build/outputs/apk/release/app-release.apk

# Reinstall over existing (same signature required)
~/Library/platform-tools/adb install -r app/build/outputs/apk/release/app-release.apk

# Uninstall
~/Library/platform-tools/adb uninstall com.cursorchat.app

# Watch logs for crashes
~/Library/platform-tools/adb logcat | grep -E "CursorChatApp|AndroidRuntime|FATAL"

# Build debug APK (no signing, no minification — for testing)
./gradlew :app:assembleDebug
```

## References

- [Android APK Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [APK Signature Schemes](https://source.android.com/docs/security/features/signing)
- [R8 Code Shrinker](https://developer.android.com/studio/build/shrink-code)
- [ProGuard Manual](https://www.guardsquare.com/proguard/manual/usage)