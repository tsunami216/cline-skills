---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [android, release, compose, signing]
project: SCCAnalyzer
---

# Android release checklist: imports, same keystore, verify before install

## Context
`assembleRelease` failed after Android slim-down due to missing Compose imports (`clickable`, `Icons`). Signed installs must reuse the same keystore or the phone rejects the update.

## Lesson
- Slimming UI can drop imports that still compile in IDE caches — always run **`assembleRelease`** before claiming ship  
- Reuse the **same** release keystore (`key.properties` + `.jks`); never regenerate for “just an update”  
- `apksigner verify` then `adb install -r`  
- Bump `versionCode` every Play/sideload update

## Rule for next time
Release path: clean → assembleRelease → apksigner verify → install -r → dumpsys versionName/versionCode.

## Related
- SCCAnalyzer: `android/sccanalyzer/app/build.gradle.kts`, cursor_chat keystore fallback
- Cursor Chat: `adb install -r` signed 1.0.17 over 1.0.16 (`com.cursorchat.app`)
