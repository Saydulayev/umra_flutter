# Vendored / patched packages

This directory holds local forks of pub.dev packages that are pulled in via
`dependency_overrides` in the root `pubspec.yaml`. They exist to carry fixes
that are not yet available in an upstream release.

> ⚠️ A `dependency_override` pins the package and **stops it from receiving
> upstream updates** (including security and bug fixes). Each override below
> must be re-evaluated on every dependency bump and removed once the fix lands
> upstream.

---

## audio_service (fork of 0.18.18)

**Override:**

```yaml
dependency_overrides:
  audio_service:
    path: patched_packages/audio_service
```

**Why it exists**

Fixes a `NullPointerException` on Android during media-browser connection.
In the stock `0.18.18`, `MediaBrowserCompat.ConnectionCallback.onConnected()`
and `onConnectionFailed()` could dereference `applicationContext`,
`mainClientInterface` or `clientInterface` after the hosting Activity had been
detached (e.g. app backgrounded / killed while the audio service was binding),
crashing the app.

**What changed**

File: `android/src/main/java/com/ryanheise/audioservice/AudioServicePlugin.java`

* `onConnected()` now early-returns when `applicationContext == null`.
* The Activity is resolved via a null-safe
  `mainClientInterface != null ? mainClientInterface.activity : null` and only
  used when non-null.
* Both `onConnected()` (error branch) and `onConnectionFailed()` null-check the
  local `clientInterface` before calling `setServiceConnectionFailed(true)`.

No public Dart API changed — this is an Android-native-only patch.

**How to verify the patch is still needed**

1. Check the upstream changelog / issues:
   <https://github.com/ryanheise/audio_service> for a release `> 0.18.18` that
   includes these null-guards in `AudioServicePlugin.java`.
2. If fixed upstream, bump `audio_service` in `pubspec.yaml`, **remove** the
   `dependency_overrides` entry, delete `patched_packages/audio_service/`, then
   run `flutter pub get` and a smoke test of audio playback + backgrounding.

**How to re-create the fork after an upstream bump (if the fix is still needed)**

```bash
# from a clean checkout of the target upstream version
cp -R ~/.pub-cache/hosted/pub.dev/audio_service-<version> patched_packages/audio_service
# re-apply the null-guards described above to AudioServicePlugin.java
flutter pub get
```

_Last reviewed: 2026-06-22 against upstream 0.18.18._
