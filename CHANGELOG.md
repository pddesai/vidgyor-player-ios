# Changelog

All notable changes to the Vidgyor SDK are documented here. This project follows
[Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`, tagged `vX.Y.Z` on `main`.

## [1.7.0] - 2026-10-07

**New home: [github.com/pddesai/vidgyor-player-ios](https://github.com/pddesai/vidgyor-player-ios).**
From this release the SDK is published there, for both Swift Package Manager and CocoaPods.
This is the last release to the previous repository.

- **SPM:** remove the old package and add `https://github.com/pddesai/vidgyor-player-ios.git`.
  The product and `import Vidgyor` are unchanged.
- **CocoaPods:** the pod is no longer published to the CocoaPods trunk, which becomes read-only
  in December 2026. Install from the repository instead:
  `pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.7.0'`
- Upgrading from 1.6.3 also brings everything in 1.6.5, including the bundled privacy manifest.

### Breaking
- **`PlayerConfig.LiveConfig` no longer takes a `logoConfig`.** Configure the logo with
  `SpPlayerConfig(logoConfig:)`, its only home now (as on Android). Only call sites that
  passed `logoConfig:` to `LiveConfig` need changing.

### Added
- **Content title** at the top of the controls, as in Android 1.0.8. It shows the app's title
  — `LiveConfig.title`, or the playing `VODItem`'s `title` — and falls back to the channel's
  name from the backend. It hides with the controls, when blank, and during ads. Turn it off
  with the new `OverlayConfig.showTitle = false`.
- **VOD repeat mode**: `VideoConfig.repeatMode` (`.off`, `.one` loops the current video,
  `.all` loops the list). With `.off`, reaching the end of the list shows a **Replay** screen,
  and `VidgyorPlayer.replay()` restarts from the first video (pre-roll included) for apps
  that offer their own replay.
- **Diagnostic logging in release builds**:
  `VidgyorPlayer.setDiagnosticLogging(enabled:mirrorToSyslog:)`. Off by default; turn it on
  to capture SDK logs from a device or a device farm.
- An **Auto** option in the audio list, to hand track choice back to the player.
- Mid-rolls on channels that signal breaks with `#EXT-X-CUE-OUT` / `#EXT-X-CUE-IN`, which
  AVFoundation itself ignores.

### Changed
- **Renamed to match Android:** `LiveConfig(channelName:)` → `LiveConfig(title:)` and
  `VODItem(videoTitle:)` → `VODItem(title:)`. The old names still compile, with a deprecation
  warning.
- **Live ads now play only when the channel config enables them explicitly**
  (`disable_preroll_adtags` / `disable_midroll_adtags` set to `false`), as on Android. A
  missing key now means no ads, and is logged once per channel.
- **tvOS: the remote's Play/Pause no longer pauses an ad.** An ad pauses only when the app
  leaves the foreground, and resumes on return.
- Mid-roll monitoring starts after 15s of actual content playback rather than 15s of wall
  time, and a live stream rejoins the live edge when a break ends.
- The logo stays hidden for a whole mid-roll break, and now sits beneath the controls rather
  than over them.
- In the settings popup, Menu (tvOS) or a left-edge swipe (iOS) goes back a level instead of
  closing the player.
- Faster start-up: the config request starts as soon as the player is attached and is retried
  like Android's (3 attempts, on a 5xx or a dropped connection). The audio session and player
  setup no longer sit between the config and the pre-roll request, and live content no longer
  competes with a loading pre-roll for bandwidth.
- Ad deadlines scale with the measured network speed, and the wait from content pause to ad
  start is capped at 8s, as on Android.
- The shipped binary is stripped and carries no Swift reflection metadata, so it gives away
  fewer of the SDK's internals. `Mirror` and `dump` no longer show the fields of SDK types.

### Fixed
- Playback hanging forever on a dead stream instead of showing the error screen.
- Live VMAP ads: pre-roll and mid-roll VMAP breaks were skipped or left the player spinning.
  VAST, VMAP and ad pods now all play.
- A mid-roll break stuck on "Ad starting soon" after a multi-break VMAP's break ended.
- Ad breaks starting up to ~40s late when the ad signal arrived in an alternate format.
- An ad that started and then froze left the viewer on a spinner; it is now abandoned.
- tvOS: the ad countdown falling behind the video, the Skip button becoming unreachable after
  leaving and returning to the app, and the controls leaving ad mode under a fast pre-roll.
- Live audio playing underneath a mid-roll ad, a no-fill pre-roll affecting the next break,
  and a crash when a mid-roll ended on a failing connection.
- On tvOS, ads that failed on real hardware but worked in the simulator.

### Analytics
- `adImpression` is now sent when an ad starts (once per ad), not when its VAST loads, so
  impression counts reflect ads actually shown.
- `playerLoadTime` and `contentLoadTime` are now true milliseconds.
- SDK-driven resumes (e.g. after an ad break) are no longer reported as a viewer's `resume`.

### Compatibility
- Platforms unchanged: **tvOS 15+**, **iOS 16+**.
- Built and tested with Google IMA **iOS 3.33.0** and **tvOS 4.17.0**. With SPM, add them
  yourself, as before; the CocoaPods pod resolves them (`~> 3.30` / `~> 4.16`).
- Source-compatible apart from the `LiveConfig(logoConfig:)` removal above.

## [1.6.5] - 2026-07-28

### Added
- **CocoaPods support.** The SDK is now published as a binary pod:
  `pod 'Vidgyor-Player', '~> 1.6'`. Unlike the SPM route, Google IMA is resolved automatically
  (`GoogleAds-IMA-iOS-SDK` on iOS, `GoogleAds-IMA-tvOS-SDK` on tvOS) — do not add it yourself.
  `use_frameworks!` is required. See the README for setup.
- **`PrivacyInfo.xcprivacy`** is now bundled in the framework. It declares the SDK's
  `UserDefaults` required-reason API usage (`CA92.1`), and the data its analytics beacon
  collects: product interaction, user id, and diagnostic data (playback error messages). It
  reports no tracking — the SDK uses no IDFA, no `identifierForVendor`, and no
  AppTrackingTransparency. This clears the **ITMS-91053** "Missing API declaration" warning
  that App Store Connect sent for apps embedding the SDK. Applies to the SPM channel too — no
  integration changes needed.

### Notes
- `1.6.4` was built but never published on either channel; it went out as `1.6.5` after the
  privacy manifest was corrected to declare diagnostic data. Nothing depends on `1.6.4`.

## [1.6.3] - 2026-07-17

### Added
- **`VideoConfig.startPositionMs`** — start VOD playback at a host-supplied position (in
  milliseconds); applied once, to the first video, after any preroll. Matches Android's
  `VideoConfig.startPositionMs`.
- Ads now render in **full screen (landscape)** — entered via device rotation or the
  full-screen icon — instead of playing audio over a frozen content frame. The poster,
  buffering spinner, ad-break mask, and close button also carry into full screen.
- **Compact analytics logging** matching Android (`source · type · event · ei=N`) under an
  `Analytics` log category, plus a `Logger.analyticsOnly` switch to show only analytics logs.

### Changed
- Midroll ad-break load gaps now show a dimmed frame + spinner instead of a black screen.

### Removed
- The implicit cross-launch **session-restore** (auto-resume) behavior and its
  `onSessionRestored()` delegate callback. Use `VideoConfig.startPositionMs` for an explicit
  start position instead. The callback was default-implemented, so integrations that never
  implemented it are unaffected; those that did can delete it (it is no longer called).

### Fixed
- SDK crash hardening: URL construction no longer traps on malformed input (including the
  backend-supplied polling URL); the player-ready and audio-interruption handlers now run on
  the main thread; shared session state and the analytics request-id are guarded against data
  races; and assorted NaN / array-index / assertion guards were added.

### Compatibility
- Platforms unchanged: **tvOS 15+**, **iOS 16+**. Google IMA is still added by the consumer
  (recommended 4.16.0). Source-compatible except for the removed, default-implemented
  `onSessionRestored()` delegate method.

## [1.6.2] - 2026-07-15

### Added
- Analytics events for Android parity: `fullScreen`, `adClick`, `videoWatchSecs`, and
  `watchDurationMins`.

### Changed
- Internal playback refinements in `MediaPlaybackManager` (including player presentation-size
  observation) and ad-handling tidy-ups. No public API changes.

### Notes
- `v1.6.1` was never a published SDK build — its tag points at the 1.6.0 binary. Use `v1.6.0`
  or `v1.6.2`.

### Compatibility
- **Source-compatible with v1.6.0** — no public API changes; existing integrations compile and
  run unchanged. Platforms unchanged: **tvOS 15+**, **iOS 16+**. Google IMA is still added by the
  consumer (recommended 4.16.0).

## [1.6.0] - 2026-07-12

### Added
- **`SpPlayerView` + `VidgyorPlayer.attach(to:)`** — the preferred integration API. The host creates and lays out an `SpPlayerView`; the SDK drives playback and overlays inside it (host-owned layout).
- **Configuration system** via `SpPlayerConfig`: `VideoConfig` (resize mode, autoplay, autorotate), `OverlayConfig` (control toggles, seek increments, auto-hide, live badge, settings), and `LogoConfig` (channel logo placement).
- **Custom player controls** for tvOS and iOS: native-style settings popup, seek bar, and playback-speed control.
- **Playback resilience**: crash-safe resume and automatic session recovery, surfaced via new (default-implemented) delegate callbacks — `onPlaybackRecoveryStarted()`, `onPlaybackRecovered()`, `onSessionRestored()`.
- **Public `VidgyorPlayer.sdkVersion`** — reports the running SDK version at runtime.

### Changed
- Version is now single-sourced from `MARKETING_VERSION`; the shipped binary, analytics (`player-version`), and `VidgyorPlayer.sdkVersion` all report the same value.

### Compatibility
- **Source-compatible with v1.5.0.** The existing `embed(in:)` / `embed(into:in:)` entry points are retained; new parameters on existing initializers are defaulted. Existing integrations compile and run unchanged; migrate to `attach(to:)` at your own pace.
- Platforms unchanged: **tvOS 15+**, **iOS 16+**. Google IMA is still added by the consumer (recommended 4.16.0).

## Earlier releases

Versions `v0.0.1` … `v1.5.0` predate this changelog; see the git tag history.
