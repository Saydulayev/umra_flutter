# Release checklist — Umrah Guide

Work through this before every store submission. Items marked **(blocker)** must
be resolved before shipping.

## 1. Versioning

Versioning is **unified** across platforms with a single source of truth:
`version:` in `pubspec.yaml` (`<marketing>+<build>`, currently `4.4.0+25`).
iOS and Android both derive their version from it.

- [ ] Bump `version:` in `pubspec.yaml`. The build number must be **strictly
      higher** than the last submission on each store (last iOS build was 10,
      last Android `versionCode` was 24 — so the shared build number must keep
      climbing from 25).
- [ ] iOS: `CFBundleShortVersionString`/`CFBundleVersion` resolve from
      `$(FLUTTER_BUILD_NAME)`/`$(FLUTTER_BUILD_NUMBER)` (Generated.xcconfig,
      driven by pubspec). `Debug.xcconfig`/`Release.xcconfig` no longer override
      the version, and `project.pbxproj` `MARKETING_VERSION`/
      `CURRENT_PROJECT_VERSION` reference the same variables — so Xcode's
      General tab always matches the shipped build. Do **not** re-add hardcoded
      version overrides.
- [ ] After bumping, run `flutter pub get` so Generated.xcconfig is regenerated,
      then confirm iOS and Android both report the same version.

## 2. Crash reporting & observability **(blocker)**

- [ ] Wire a real backend into `ErrorReporter.install()` in `lib/main.dart`.
      Implement `CrashReportingBackend` (see `lib/services/error_reporter.dart`)
      with Firebase Crashlytics **or** Sentry, then:

      ```dart
      ErrorReporter.install(backend: CrashlyticsBackend());
      ```

      Global handlers (`FlutterError.onError`, `PlatformDispatcher.onError`,
      `runZonedGuarded`) are already in place — only the backend adapter is
      missing.
- [ ] Verify a forced test crash appears in the dashboard from a release build.

## 3. Android

- [ ] **Exact alarms (blocker for Play review):** the app declares
      `SCHEDULE_EXACT_ALARM` for prayer-time notifications. Google Play requires
      a justification in the **App content → Permissions declaration** form.
      Prayer-time scheduling is an eligible use case, but the form must be
      filled or the release will be rejected. If eligible, consider migrating to
      `USE_EXACT_ALARM` (auto-granted for alarm/calendar-class apps) to avoid the
      runtime permission flow on Android 13+.
- [ ] Release signing uses `key.properties` + keystore (already configured).
      Confirm the keystore and `key.properties` exist on the build machine and
      are **not** committed to git.
- [ ] `isMinifyEnabled` / `isShrinkResources` are on — smoke-test a release
      build to confirm ProGuard/R8 rules don't strip anything used via
      reflection (notifications, IAP, just_audio).
- [ ] Build an `.aab` (`flutter build appbundle --release`) and test on a real
      device.

## 4. iOS

- [ ] Bundle ID `saydulayev.wien-gmail.com.umra` matches the App Store Connect
      record.
- [ ] Usage-description strings in `Info.plist` are accurate (microphone string
      explains it is referenced by an audio library but not used).
- [ ] Push a build via `flutter build ipa --release` and run through
      TestFlight on a physical device.

## 5. In-app purchases **(blocker)**

- [ ] Products are created and **Approved/Ready** in App Store Connect and Play
      Console with matching product IDs.
- [ ] Purchase, restore, and cancellation tested with sandbox accounts on both
      platforms. State-machine logic (success/error/cancel/pending-timeout and
      the cancellation-code matrix) is also covered by
      `test/unit/purchase_provider_test.dart` — sandbox runs verify the native
      billing integration on top of that.
- [ ] Receipt/entitlement handling verified after app restart.

## 6. Localization & UI

- [ ] All 7 locales (en, ru, de, fr, tr, id, ar) render without overflow.
- [ ] **Arabic:** text size now matches other locales (bundled Cairo). Re-verify
      on device after this change — headings/selected tabs show heavier weight,
      Latin/digits inside Arabic screens stay in Cairo.
- [ ] RTL layout for Arabic looks correct (padding, icons, chevrons).

## 7. Quality gates

- [ ] `flutter analyze` → **No issues found!**
- [ ] `flutter test` → all green.
- [ ] Manual smoke test: audio playback + backgrounding, notifications fire at
      prayer times, review prompt does **not** appear prematurely
      (`ReviewConfig.isTestMode == false`, guarded by a unit test).

## 8. Store metadata & compliance

- [ ] Privacy policy URL live and reachable (`docs/privacy-policy.html`).
- [ ] Data-safety / App Privacy forms completed on both stores.
- [ ] Screenshots, descriptions, and what's-new notes updated.
- [ ] App icons present for all required sizes (verified: iOS + Android).

---

## Known maintenance debt (track, not blocking)

- `dependency_overrides → audio_service` is a local fork. See
  `patched_packages/PATCH_NOTES.md`; remove once the NPE fix lands upstream.
- `test/unit/*` now covers fonts, review config, the review-dialog decision
  procedure (all 6 gating conditions), prayer-time calculations, theme and
  notification-preferences loading, and the purchase state machine;
  `test/widget/screens_smoke_test.dart` smoke-tests the 4 main screens across
  3 themes × 2 locales (incl. RTL). Still untested: native platform channels
  (`flutter_local_notifications`, `in_app_review`, real billing) — covered by
  the manual items above.
