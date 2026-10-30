# Changelog

All notable changes to the Vidgyor SDK are documented here. This project follows
[Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`, tagged `vX.Y.Z` on `main`.

## [Unreleased]

## [1.8.1] - 2026-10-30

### Fixed
- **App Store Connect rejected apps embedding the SDK with ITMS-91056 "Invalid privacy
  manifest"** for `Frameworks/Vidgyor.framework/PrivacyInfo.xcprivacy`. The manifest gave its
  `UserDefaults` reason (`CA92.1`) under the key `NSPrivacyAccessedAPIReasons`; Apple's key is
  `NSPrivacyAccessedAPITypeReasons`. 1.6.5, 1.7.0 and 1.8.0 all carry the wrong key: update to
  1.8.1 and upload a new build. What the manifest declares is unchanged, and there are no code or
  API changes.

### CocoaPods
- 1.8.1 is also on the CocoaPods trunk, so `pod 'Vidgyor-Player', '~> 1.8'` picks it up.

## [1.8.0] - 2026-10-27

### CocoaPods: the last trunk release
- **1.8.x is the last Vidgyor-Player line on the CocoaPods trunk.** CocoaPods makes its trunk
  read-only on **2 December 2026** ([announcement](https://blog.cocoapods.org/CocoaPods-Specs-Repo/)),
  so `pod 'Vidgyor-Player', '~> 1.8'` from the trunk gets no updates after that date, and the
  trunk pod will be marked deprecated. Every release, including all later ones, is published in
  this repository: use Swift Package Manager (recommended) or
  `pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'vX.Y.Z'`.

### Added
- **FairPlay DRM** for live and VOD HLS streams. Pass a `DRMConfig` with `LiveConfig(drmConfig:)`
  or `VODItem(drmConfig:)`, or configure it per channel (`live_drm` / `vod_drm`); settings in the
  app win. The license comes from a fixed URL (`DRMConfig.fairPlay(certificate:licenseURL:)`) or
  from a URL that a token endpoint issues for each request
  (`fairPlay(certificate:licenseTokenURL:)`). FairPlay doesn't run in the Simulator: protected
  streams there fail with error 6001. See the README's "Protected Streams (FairPlay DRM)".
- **`onPlaybackError(_:)`** on `VidgyorVODPlayerDelegate` and `VidgyorLivePlayerDelegate`, with a
  typed `VidgyorPlaybackError` (`category`, `code`, `message`). Optional: it has a default
  implementation.
- DRM error codes, as on Android: 6001 (this device can't play protected video), 6003 (encrypted
  stream without DRM settings), 6004 (playback rights couldn't be obtained — offline, not
  authorised, or other), 6006 (protected playback couldn't be set up). `ErrorConfig.drmTitle` /
  `drmMessage` change the DRM error screen's text.

### Changed
- **New player controls, matching the Android SDK**, on iOS and tvOS: the title at the top left;
  rewind, play/pause and forward in the centre; a full-width seek bar that also shows buffered
  content; position and duration at the bottom left; the LIVE badge, settings and full-screen
  buttons at the bottom right. The settings popup lists Speed (now from 0.25x), Audio, Subtitles
  and Quality. On tvOS the focus look matches Android TV, and the seek bar can be focused and
  scrubbed with the remote.
- **`OverlayConfig.backgroundAlpha`** now works as on Android — the strength of the controls'
  40% dim — and defaults to **0.8** (was 0.25). If your app sets 0.25, the dim is now much
  lighter: remove the setting for the default look.
- While the settings popup is open, swipes scroll the popup instead of reaching the app.
- iOS: the system Live Text button no longer covers the full-screen button on a paused video.
- **Logging, as in the Android SDK:** one line per event, `[Component] message`, under the
  subsystem `SP-Player` (was `Sp-Player`), **in every build including release**. Filter on
  `subsystem == "SP-Player"` and a component (`Player`, `Playback`, `Ads`, `Midroll`, `Polling`,
  `SCTE`, `DRM`, `Analytics`, `Network`, `UI`, `Perf`). Work that repeats on a timer no longer logs
  every few seconds. `setDiagnosticLogging(enabled: false)` silences the SDK; mirrored syslog
  lines read `SP-Player I [Ads] …`. An ad's `Loaded` line names its creative, and the reason IMA
  drops an ad is logged.
- An ad that hasn't started is now given up after 9 seconds (was 8).

### Fixed
- A mid-roll ad pod no longer loses all its ads when one ad's video doesn't load in time: the next
  ad in the pod plays.
- SCTE-35 mid-rolls signalled with `#EXT-X-CUE-OUT` start when the viewer reaches the cue, instead
  of up to ~40 seconds early.
- A VOD pre-roll that stalled before starting no longer resumes later over the playing video.
- A content failure that happened while an ad was on screen left a frozen black screen after the
  ad. It is now handled when content resumes (a retry, or the error screen), and reported once.

### Compatibility
- Source-compatible with 1.7.0: every API change adds a type, a method or a parameter with a
  default.
- **CocoaPods:** the pod now requires Google IMA **iOS 3.33+** and **tvOS 4.17+** (`~> 3.33` /
  `~> 4.17`, up from `~> 3.30` / `~> 4.16`), the versions the SDK is built and tested with. If
  your `Podfile.lock` holds an older IMA and `pod install` reports a conflict, run
  `pod update GoogleAds-IMA-iOS-SDK` (or `GoogleAds-IMA-tvOS-SDK`). SPM is unaffected: you add
  IMA yourself, at the versions the README lists.
- Built with Xcode 27.0 (Swift 6.4).

## [1.7.0] - 2026-10-07

**New home: [github.com/pddesai/vidgyor-player-ios](https://github.com/pddesai/vidgyor-player-ios).**
From this release the SDK is published there, for both Swift Package Manager and CocoaPods.
This is the last release to the previous repository.

- **SPM:** remove the old package and add `https://github.com/pddesai/vidgyor-player-ios.git`.
  The product and `import Vidgyor` are unchanged.
- **CocoaPods:** install from the repository:
  `pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.7.0'`.
  1.7.0 is also on the CocoaPods trunk, but the trunk becomes read-only in December 2026, so
  later releases will be published only in the repository.
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
