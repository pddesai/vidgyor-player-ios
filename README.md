# 🎬 VidgyorPlayer SDK Integration Guide
Integrate the VidgyorPlayer SDK to enable both VOD (Video-On-Demand) and Live TV playback with ad support and analytics callbacks.

Supported platforms: **tvOS 15+** and **iOS 16+**

## Vidgyor SDK - Installation Guide

### Installation via Swift Package Manager (SPM)

The **Vidgyor SDK** can be easily integrated using Swift Package Manager.

#### Step 1: Add Vidgyor SDK

1. Open your Xcode project.
2. Navigate to **File → Add Packages...**
3. In the search bar, enter the SDK's repository URL:
```
   https://github.com/pddesai/vidgyor-player-ios.git
```
4. Select the latest version of the package and click **Add Package**.
5. Import the SDK in your Swift files where needed:
```swift
   import Vidgyor
```

> **Moving from the previous repository?** Versions up to 1.6.x were distributed from a
> different, private repository. Remove that package from your project, then add this one —
> the product and the module are unchanged (`import Vidgyor`), so no code changes are needed.

#### Step 2: Add Google IMA SDK (Required Dependency)

Vidgyor SDK depends on the **Google IMA SDK** for ad playback functionality. You must add it separately via SPM. Add the version matching your target platform.

**For tvOS targets:**
1. In Xcode, navigate to **File → Add Packages...**
2. Enter the Google IMA SDK URL for tvOS:
```
   https://github.com/googleads/swift-package-manager-google-interactive-media-ads-tvos
```
3. Select the latest version of the package and click **Add Package**.

**For iOS targets:**
1. In Xcode, navigate to **File → Add Packages...**
2. Enter the Google IMA SDK URL for iOS:
```
   https://github.com/googleads/swift-package-manager-google-interactive-media-ads-ios
```
3. Select the latest version of the package and click **Add Package**.

If your project targets **both tvOS and iOS**, add both packages.

#### Important Notes

- **Google IMA SDK is required** for Vidgyor SDK to function properly. The SDK will not work without it.
- Make sure the correct IMA package(s) for your platform are successfully added before using Vidgyor SDK.
- Recommended Google IMA SDK versions: **iOS 3.33.0**, **tvOS 4.17.0** (the versions this SDK release is built and tested with).

#### Verification

After installation, verify both packages are added:
1. In Xcode, select your project in the navigator.
2. Go to your app target → **General** tab.
3. Scroll to **Frameworks, Libraries, and Embedded Content**.
4. Confirm both **Vidgyor** and **GoogleInteractiveMediaAds** are listed.

---

### Installation via CocoaPods

The SDK is also available as the binary pod **`Vidgyor-Player`**, installed straight from this repository. **Google IMA is resolved automatically** — you do not add it yourself.

> Point your `Podfile` at this repository and a release tag, as below. That works for every
> release; each release's tag is listed under **Releases**. 1.7.0 is also on the CocoaPods
> trunk (`pod 'Vidgyor-Player', '~> 1.7'`), but the trunk becomes read-only in December 2026
> and will not receive later releases, so a trunk line stops getting updates there.

#### Step 1: Add the pod

Add the SDK to your `Podfile`:

```ruby
platform :ios, '16.0'      # or: platform :tvos, '15.0'
use_frameworks!

target 'YourApp' do
  pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.7.0'
end
```

If your project has **both iOS and tvOS targets**, declare the platform per target:

```ruby
use_frameworks!

target 'YourApp-iOS' do
  platform :ios, '16.0'
  pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.7.0'
end

target 'YourApp-tvOS' do
  platform :tvos, '15.0'
  pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.7.0'
end
```

Then install:

```bash
pod install
```

From now on, open the generated **`.xcworkspace`**, not the `.xcodeproj`. To upgrade later, change the `:tag` to the new release and run `pod install` again.

#### Step 2: Import the SDK

```swift
import Vidgyor
```

> **The pod is `Vidgyor-Player`, but the module is `Vidgyor`.** You install `pod 'Vidgyor-Player'` and import `Vidgyor` — the framework inside the pod keeps its original name. This is normal for CocoaPods; the pod `GoogleAds-IMA-iOS-SDK` likewise vends the module `GoogleInteractiveMediaAds`. `import Vidgyor-Player` is not valid Swift and will not compile.

#### Important Notes

- **`use_frameworks!` is required.** Vidgyor ships as a dynamic framework, so a static-linkage Podfile (`use_frameworks! :linkage => :static`) is not supported.
- **Do not add Google IMA manually.** The pod declares it per platform — `GoogleAds-IMA-iOS-SDK` on iOS, `GoogleAds-IMA-tvOS-SDK` on tvOS. Adding it again produces a `Multiple commands produce .../GoogleInteractiveMediaAds.framework` build error. If you are migrating from SPM, remove the Google IMA package from your project first.
- **Set `ENABLE_USER_SCRIPT_SANDBOXING = NO`** on your app target. Xcode enables it by default for new projects, and it makes CocoaPods' "[CP] Embed Pods Frameworks" phase fail with `Sandbox: rsync(...) deny(1) file-write-create`. This affects every CocoaPods project that embeds frameworks, not just Vidgyor. You can also set it from the Podfile:

  ```ruby
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
        end
      end
    end
  end
  ```
- Minimum deployment targets: **iOS 16.0**, **tvOS 15.0**. `pod install` fails if your target is lower.

#### Verification

1. The `pod install` summary should list **Vidgyor-Player** and the matching **GoogleAds-IMA-…-SDK** for your platform.
2. In Xcode, app target → **General** → **Frameworks, Libraries, and Embedded Content** shows `Pods_YourApp.framework`.
3. At runtime, `print(VidgyorPlayer.sdkVersion)` prints the installed version.


## 🧩 Table of Contents

* Global Player Instance
* VOD Player Integration
    * Create VOD Items
    * Create VOD Configuration
    * Initialize Player
    * Add Player View & Attach
    * Implement Delegate
* Live Player Integration
    * Create Live Configuration
    * Initialize Player
    * Add Player View & Attach
    * Implement Delegate
* Focus Management (tvOS)
    * Overview
    * Transferring Focus to Client App
    * Restoring Focus to Player
    * Use Cases & Examples
* Gesture-based Input (iOS)
    * Overview
    * Handling Focus Move Callbacks
* Player Lifecycle
* Best Practices
* Complete Examples
* Player Customization (SpPlayerConfig)
* Repeat and Replay (VOD)
* Error Screen
* Diagnostic Logging


## 1. Global Player Instance

Declare the VidgyorPlayer instance at the view-controller level.
Using an optional is recommended for safety and cleanup.
```swift
private var vidgyorPlayer: VidgyorPlayer?
```

## 2. VOD Player Integration
### Step 1: Create VOD Items
Each video is represented by a VODItem.
```swift
let vodItem = VODItem(
    videoUrl: "https://example.com/video1.mp4",
    thumbnailUrl: "https://example.com/thumb1.jpg",
    title: "Episode 1",
    videoId: "VODItem-1"
)

let vodItems = [vodItem]
```


**VODItem Properties**

| Property      | Type     | Required | Description                          |
|----------------|----------|-----------|--------------------------------------|
| `url`          | `String` | ✅        | The video URL.                       |
| `thumbnailUrl` | `String?`| ❌        | Thumbnail image URL.                 |
| `title`        | `String?`| ❌        | Video title.                         |
| `videoId`      | `String?`| ❌        | Unique identifier for analytics.     |


### Step 2: Create VOD Configuration
Define how your VOD playlist and ads behave.

```swift
let vodConfig = PlayerConfig.VODConfig(
    vodList: vodItems,
    vodPrerollAdTag: "https://adserver.com/vast/preroll.xml",
    disableVodPrerollAdTags: false,
    delegate: self // must conform to VidgyorVODPlayerDelegate
)
```


**VODConfig Properties**
| Property                  | Type          | Required | Description                              |
|----------------------------|---------------|----------|------------------------------------------|
| `vodList`                 | `[VODItem]`   | ✅       | Array of VOD items.                       |
| `vodPrerollAdTag`         | `String?`     | ❌       | URL of preroll VAST ad tag.               |
| `disableVodPrerollAdTags` | `Bool`        | ❌       | Disable preroll ads (default: `false`).   |
| `delegate` | `VidgyorVODPlayerDelegate` | ✅ | Delegate for player callbacks. |

### Step 3: Initialize VidgyorPlayer Instance
```swift
vidgyorPlayer = VidgyorPlayer(
    accountId: "ACCOUNT_ID",
    channelId: "CHANNEL_ID",
    config: .vod(vodConfig)
)
```

| Parameter   | Type          | Description                               |
|------------|---------------|-------------------------------------------|
| `accountId` | `String`      | Your account identifier.                  |
| `channelId` | `String`      | Associated channel ID.                    |
| `config`    | `PlayerConfig`| Player configuration (`.vod` or `.live`).|

> **Optional — customize the player.** The initializer also accepts a `playerConfig: SpPlayerConfig`, letting you tune video behavior (`VideoConfig`), on-screen controls (`OverlayConfig`), a channel logo (`LogoConfig`), the error screen (`ErrorConfig`) and analytics (`AnalyticsConfig`). Every option is listed in [Player Customization](#9-player-customization-spplayerconfig).
> ```swift
> var overlay = OverlayConfig()
> overlay.speedControl = true
> overlay.seekForwardIncrement = 10
>
> vidgyorPlayer = VidgyorPlayer(
>     accountId: "ACCOUNT_ID",
>     channelId: "CHANNEL_ID",
>     config: .vod(vodConfig),
>     playerConfig: SpPlayerConfig(overlayConfig: overlay)
> )
> ```

### Step 4: Add a Player View and Attach

Create an `SpPlayerView`, add it to your view hierarchy and give it a size (Auto Layout or a frame), then attach the player with `attach(to:)`. This is the **preferred integration API**: your app owns the view and its layout, and the SDK drives playback and overlays inside it — so the player can be full-screen, a 16:9 card, split-view, or any size you choose.

```swift
private let playerView = SpPlayerView()

override func viewDidLoad() {
    super.viewDidLoad()

    // 1. Add the player view to your layout and give it a determinate size.
    playerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(playerView)
    NSLayoutConstraint.activate([
        playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0 / 16.0)
    ])

    // 2. Attach the player to the view you just added.
    vidgyorPlayer?.attach(to: playerView)
}
```

* The `SpPlayerView` **must already be in a view-controller hierarchy** when you call `attach(to:)` — the SDK finds the owning view controller from the responder chain.
* Attaching automatically starts playback for VOD content.
* With `attach(to:)` the SDK shows **no dismiss button** — your app owns the layout, so add your own close
  control and call `vidgyorPlayer?.dismiss()` from it.

> **Migrating from `embed(in:)`?** `embed(in:)` and `embed(into:in:)` are **deprecated**: they still work, with a compiler warning, and will be removed in a future release. They create an `SpPlayerView` for you, and on iOS `embed(in:)` also shows the SDK's own dismiss button in the top-left corner. Move to `attach(to:)`.

### Step 5: Conform to VidgyorVODPlayerDelegate

Implement delegate methods to handle player events, errors, and analytics.
```swift
extension MyViewController: VidgyorVODPlayerDelegate {

    // MARK: - Required

    // Triggered when SDK fails to initialize
    func didFailToLoadConfiguration(error: String) {
        presentAlert(title: "Error", message: error)
    }

    // Triggered when all VOD items finish playing. The SDK is showing its Replay
    // screen at this point; dismissing here closes the player instead.
    func didFinishPlayingAllVideos() {
        vidgyorPlayer?.dismiss()
    }


    // MARK: - Optional Callbacks (both platforms)

    // Called when user swipes up (iOS) or presses UP on remote (tvOS)
    // direction is .up or .down
    func didRequestFocusMove(_ direction: PlayerFocusDirection) {}

    // Current playback position in seconds
    func onCurrentPlaybackTime(seconds: Int) {}

    // Current playback position in milliseconds
    func onTimeUpdate(currentPosition: Int64) {}

    // Renders the total video duration in milliseconds
    func onDuration(duration: Int64) {}

    // Called when video playback completes
    func onVideoComplete() {}

    // Called when player errors occur
    func onPlayerError(error: String) {}

    // Called when content starts playing
    func notifyPlay() {}

    // Called when content is paused
    func notifyPause() {}

    // Called when video buffering starts; value is current system time
    func notifyBufferStart(value: Int64) {}

    // Called when user initiates seeking; value is current system time
    func notifySeekStart(value: Int64) {}

    // Called when the content video starts
    func contentStart() {}

    // Called when video is watched 25%, 50%, 75%, 90%; value is percent number
    func videoWatchPercent(value: Int) {}

    // Called when an ad starts playing
    func isAdStart(value: Bool) {}

    // Called when an ad finishes playing
    func isAdEnd(value: Bool) {}

    // Called when the user skips an ad
    func isAdSkip(value: Bool) {}

    // Called when there is an error during ad playback
    func adError() {}


    // MARK: - Optional Callbacks (tvOS only)

    // Called when player controls are shown (transport bar visible)
    func showOverlay(isVisible: Bool) {}

    // Called when player controls are hidden (transport bar hidden)
    func hideOverlay(isVisible: Bool) {}
}
```

#### Required Delegates
| Method               | Description         |
|-------------------------|--------------|
| `didFailToLoadConfiguration(error:)` | Triggered when SDK fails to initialize. |
| `didFinishPlayingAllVideos()` | Triggered when all VOD items finish playing. The SDK shows a Replay screen at the same time; call `vidgyorPlayer?.dismiss()` here if you'd rather close the player. |


## 3. Live Player Integration
The setup for Live content is similar but uses LiveConfig.

### Step 1: Create Live Configuration
```swift
let liveConfig = PlayerConfig.LiveConfig(
    title: "Sports Channel",
    livetvUrl: "https://example.com/live/stream.m3u8",
    prerollAdTag: "https://adserver.com/vast/livepreroll.xml",
    disablePrerollAdTags: false,
    disableMidrollAdTags: false,
    midrollAdTags: ["https://adserver.com/vast/midroll1.xml"],
    delegate: self
)
```

#### LiveConfig Properties
| Property               | Type         | Required | Description                                      |
|-------------------------|--------------|-----------|--------------------------------------------------|
| `title`                 | `String?`    | ❌        | Title shown at the top of the controls; `nil` uses the channel name. (Was `channelName`.) |
| `livetvUrl`             | `String?`    | ❌        | Custom live stream URL (optional).               |
| `prerollAdTag`          | `String?`    | ❌        | Override preroll ad tag URL.                     |
| `disablePrerollAdTags`  | `Bool`       | ❌        | `true` turns off live pre-roll ads. The default, `false`, leaves it to the channel's configuration. |
| `disableMidrollAdTags`  | `Bool`       | ❌        | `true` turns off live mid-roll ads. The default, `false`, leaves it to the channel's configuration. |
| `midrollAdTags`         | `[String]`   | ❌        | Array of midroll ad tag URLs.                    |
| `delegate` | `VidgyorLivePlayerDelegate` | ✅ | Delegate for playback and analytics events.

> **How live ads are enabled.** Live pre-roll and mid-roll ads play only when the channel's configuration enables them, as on Android. `disablePrerollAdTags` and `disableMidrollAdTags` can only turn ads off: `true` disables them in your app, while `false` leaves the decision to the channel. If live ads don't appear, contact Vidgyor support to check the channel's configuration.

### Step 2: Initialize Player for Live Content
```swift
vidgyorPlayer = VidgyorPlayer(
    accountId: "ACCOUNT_ID",
    channelId: "CHANNEL_ID",
    config: .live(liveConfig)
)
```

### Step 3: Add a Player View and Attach

Exactly like VOD — create an `SpPlayerView`, add it to your layout and size it, then attach:

```swift
private let playerView = SpPlayerView()

override func viewDidLoad() {
    super.viewDidLoad()

    playerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(playerView)
    NSLayoutConstraint.activate([
        playerView.topAnchor.constraint(equalTo: view.topAnchor),
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    vidgyorPlayer?.attach(to: playerView)
}
```

* Attaching automatically starts the live stream playback.
* With `attach(to:)` the SDK shows **no dismiss button** — your app owns the layout, so add your own close
  control and call `vidgyorPlayer?.dismiss()` from it.
* `embed(in:)` still works but is deprecated (see [Player Lifecycle](#6-player-lifecycle)).

### Step 4: Implement VidgyorLivePlayerDelegate
```swift
extension MyViewController: VidgyorLivePlayerDelegate {

    // MARK: - Required

    // Triggered when SDK fails to initialize
    func didFailToLoadConfiguration(error: String) {
        presentAlert(title: "Error", message: error)
    }


    // MARK: - Optional Callbacks (both platforms)

    // Called when user swipes up (iOS) or presses UP on remote (tvOS)
    // direction is .up or .down
    func didRequestFocusMove(_ direction: PlayerFocusDirection) {}

    // Called when content starts playing
    func notifyPlay() {}

    // Called when content is paused
    func notifyPause() {}

    // Called with True when ad is playing; with False when ad is completed or skipped
    func isAdPlayingCallback(isPlaying: Bool) {}

    // Called when the live content video starts
    func contentStart() {}

    // Called every 10 seconds during live video stream play
    func videoLiveWatchDuration(value: Int) {}

    // Called when the live stream URL is retrieved
    func getLiveUrl(str: String) {}

    // Called when an ad starts playing
    func isAdStart(value: Bool) {}

    // Called when an ad is completed
    func isAdEnd(value: Bool) {}

    // Called when the user skips an ad
    func isAdSkip(value: Bool) {}

    // Called when there is an error during ad playback
    func adError() {}


    // MARK: - Optional Callbacks (tvOS only)

    // Called when player controls are shown (transport bar visible)
    func showOverlay(isVisible: Bool) {}

    // Called when player controls are hidden (transport bar hidden)
    func hideOverlay(isVisible: Bool) {}
}
```

#### Required Delegates
| Method               | Description         |
|-------------------------|--------------|
| `didFailToLoadConfiguration(error:)` | Triggered when SDK fails to initialize. |

---

## 4. Focus Management (tvOS)

> **tvOS only.** These APIs and behaviors do not apply to iOS. For iOS gesture-based input, see [Section 5: Gesture-based Input (iOS)](#5-gesture-based-input-ios).

### Overview

The VidgyorPlayer SDK provides focus management capabilities for Apple TV apps, allowing you to transfer focus between the video player and your custom UI elements. This enables interactive experiences such as:

- Displaying related content recommendations
- Showing channel guides or program information
- Creating custom navigation menus
- Building interactive overlays during playback

### How It Works

The SDK detects when the user presses the **UP button** or performs an **UP swipe** on the Apple TV remote and notifies your app through the `didRequestFocusMove(_ direction: PlayerFocusDirection)` delegate callback. Your app can then:

1. Show custom UI (overlays, menus, content grids, etc.)
2. Transfer focus from the player to your UI
3. Handle user interactions in your custom UI
4. Restore focus back to the player when done

---

### Transferring Focus to Client App

#### Step 1: Implement the Delegate Callback

When the user presses UP or swipes up on the remote, the SDK calls the `didRequestFocusMove(.up)` delegate method.

```swift
extension MyViewController: VidgyorVODPlayerDelegate {
    
    func didRequestFocusMove(_ direction: PlayerFocusDirection) {
        if direction == .up {
            // User pressed UP - show your custom UI
            showCustomOverlay()
        }
    }
}
```

#### Step 2: Disable Player Focus

Before showing your custom UI, disable the player's focus capability to prevent it from stealing focus back:

```swift
private func showCustomOverlay() {
    // Disable player focus
    vidgyorPlayer?.setPlayerFocusEnabled(false)
    
    // Show your custom UI
    // ... your overlay code here ...
    
    // Update focus environment
    setNeedsFocusUpdate()
    updateFocusIfNeeded()
}
```

#### Step 3: Direct Focus to Your UI

Override `preferredFocusEnvironments` in your view controller to direct focus to your custom UI:

```swift
override var preferredFocusEnvironments: [UIFocusEnvironment] {
    if isCustomOverlayVisible {
        return [customOverlayView] // Your custom UI element
    }
    return super.preferredFocusEnvironments
}
```

---

### Restoring Focus to Player

When the user is done interacting with your custom UI (e.g., dismissing the overlay), restore focus back to the player:

#### Step 1: Hide Your Custom UI

```swift
private func hideCustomOverlay() {
    // Hide your overlay with animation
    UIView.animate(withDuration: 0.3) {
        self.customOverlayView.alpha = 0
    } completion: { _ in
        self.customOverlayView.removeFromSuperview()
        
        // Restore focus to player
        self.vidgyorPlayer?.restoreFocusToPlayer()
    }
}
```

#### Step 2: Call `restoreFocusToPlayer()`

The `restoreFocusToPlayer()` method re-enables the player's focus capability and requests focus:

```swift
vidgyorPlayer?.restoreFocusToPlayer()
```

---

### Focus Management API (tvOS only)

The VidgyorPlayer provides two public methods for focus control on tvOS:

| Method | Description |
|--------|-------------|
| `setPlayerFocusEnabled(_ enabled: Bool)` | Enable or disable the player's ability to receive focus. Set to `false` when showing custom UI, `true` to allow player focus. |
| `restoreFocusToPlayer()` | Re-enables player focus and requests focus back to the player. Call this when dismissing custom UI. |

---

### Use Cases & Examples

#### Example 1: Showing a Horizontal Content Grid

Display a horizontally scrolling collection of related videos when the user presses UP:

```swift
final class VideoPlayerViewController: UIViewController {
    
    private var vidgyorPlayer: VidgyorPlayer?
    private var relatedVideosView: UIView?
    private var isOverlayVisible = false
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVODPlayer()
        setupDownGestureForOverlay()
    }
    
    private func setupVODPlayer() {
        let vodItem = VODItem(videoUrl: "https://example.com/video.mp4")
        let config = PlayerConfig.VODConfig(vodList: [vodItem], delegate: self)
        
        vidgyorPlayer = VidgyorPlayer(
            accountId: "123", 
            channelId: "456", 
            config: .vod(config)
        )

        let playerView = SpPlayerView()
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)
        vidgyorPlayer?.attach(to: playerView)
    }
    
    // MARK: - DOWN Gesture Setup (for dismissing overlay)
    
    private func setupDownGestureForOverlay() {
        // DOWN swipe gesture
        let swipeDown = UISwipeGestureRecognizer(
            target: self, 
            action: #selector(handleDownSwipe)
        )
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func handleDownSwipe(_ gesture: UISwipeGestureRecognizer) {
        if isOverlayVisible {
            hideRelatedVideos()
        }
    }
    
    // Also handle DOWN button press
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var handled = false
        
        for press in presses {
            if press.type == .downArrow && isOverlayVisible {
                hideRelatedVideos()
                handled = true
                break
            }
        }
        
        if !handled {
            super.pressesBegan(presses, with: event)
        }
    }
    
    // MARK: - Show Related Videos
    
    private func showRelatedVideos() {
        guard !isOverlayVisible else { return }
        isOverlayVisible = true
        
        // Create your custom overlay view (collection view, grid, etc.)
        let overlay = createRelatedVideosOverlay()
        view.addSubview(overlay)
        relatedVideosView = overlay
        
        // Disable player focus
        vidgyorPlayer?.setPlayerFocusEnabled(false)
        
        // Animate in and update focus
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1
        } completion: { _ in
            self.setNeedsFocusUpdate()
            self.updateFocusIfNeeded()
        }
    }
    
    private func hideRelatedVideos() {
        guard isOverlayVisible, let overlay = relatedVideosView else { return }
        isOverlayVisible = false
        
        // Animate out
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 0
        } completion: { _ in
            overlay.removeFromSuperview()
            self.relatedVideosView = nil
            
            // Restore focus to player
            self.vidgyorPlayer?.restoreFocusToPlayer()
        }
    }
    
    // MARK: - Focus Management
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if isOverlayVisible, let overlay = relatedVideosView {
            return [overlay]
        }
        return super.preferredFocusEnvironments
    }
    
    // MARK: - Helper
    
    private func createRelatedVideosOverlay() -> UIView {
        // Create your custom UI here
        // This could be a UICollectionView, custom container, etc.
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlay.alpha = 0
        
        // Add your collection view, labels, buttons, etc.
        // ...
        
        return overlay
    }
}

// MARK: - VidgyorVODPlayerDelegate

extension VideoPlayerViewController: VidgyorVODPlayerDelegate {
    
    func didRequestFocusMove(_ direction: PlayerFocusDirection) {
        if direction == .up {
            // User pressed UP or swiped up - show related content
            showRelatedVideos()
        }
    }
    
    func didFailToLoadConfiguration(error: String) {
        presentAlert(title: "Error", message: error)
    }
    
    func didFinishPlayingAllVideos() {
        vidgyorPlayer?.dismiss()
    }
}
```

#### Example 2: Channel Guide or Menu

```swift
func didRequestFocusMove(_ direction: PlayerFocusDirection) {
    if direction == .up {
        showChannelGuide()
    }
}

private func showChannelGuide() {
    vidgyorPlayer?.setPlayerFocusEnabled(false)
    
    // Display your channel guide UI
    channelGuideView.isHidden = false
    
    setNeedsFocusUpdate()
    updateFocusIfNeeded()
}

private func dismissChannelGuide() {
    channelGuideView.isHidden = true
    vidgyorPlayer?.restoreFocusToPlayer()
}
```

---

### Best Practices for Focus Management (tvOS)

1. **Always disable player focus before showing custom UI**
   ```swift
   vidgyorPlayer?.setPlayerFocusEnabled(false)
   ```

2. **Always restore focus when dismissing custom UI**
   ```swift
   vidgyorPlayer?.restoreFocusToPlayer()
   ```

3. **Implement `preferredFocusEnvironments`** to direct focus properly
   ```swift
   override var preferredFocusEnvironments: [UIFocusEnvironment] {
       if customUIVisible {
           return [customView]
       }
       return super.preferredFocusEnvironments
   }
   ```

4. **Handle DOWN gesture in your view controller** to dismiss overlays
   - Use both `pressesBegan` for DOWN button
   - Use `UISwipeGestureRecognizer` for DOWN swipe

5. **Update focus after UI changes**
   ```swift
   setNeedsFocusUpdate()
   updateFocusIfNeeded()
   ```

---

## 5. Gesture-based Input (iOS)

> **iOS only.** On tvOS, directional input is handled via the Siri Remote — see [Section 4: Focus Management (tvOS)](#4-focus-management-tvos).

### Overview

On iOS, the player responds to touch gestures automatically. No additional setup is required on your part:

- **Swipe up / Swipe down** — triggers the `didRequestFocusMove` delegate callback with `.up` or `.down` direction
- **Tap** — shows or hides the player controls; play and pause with the center button. While an ad is playing, touches go to the ad (for example its Skip button)
- **Dismiss button** — shown in the top-left corner only with the deprecated `embed(in:)`, where it calls `vidgyorPlayer?.dismiss()`. With `attach(to:)`, add your own close control

### Handling Focus Move Callbacks

When the user swipes up or down on the player, the SDK calls `didRequestFocusMove`. Use this to show or hide any custom UI in your app:

```swift
extension MyViewController: VidgyorVODPlayerDelegate {
    
    func didRequestFocusMove(_ direction: PlayerFocusDirection) {
        switch direction {
        case .up:
            showRelatedContent()
        case .down:
            hideRelatedContent()
        }
    }
}
```

Unlike tvOS, there is no need to call `setPlayerFocusEnabled` or `restoreFocusToPlayer` on iOS — those APIs are not available on iOS.

---

## 6. Player Lifecycle
| Action               | Method         |  Description                                      | Platform |
|-------------------------|--------------|-----------|---|
| Attach player | `vidgyorPlayer?.attach(to: playerView)` | Attaches the player to an `SpPlayerView` you created and starts playback. **Preferred.** | Both |
| Embed player (deprecated) | `vidgyorPlayer?.embed(in: parentVC)` / `embed(into:in:)` | Backward-compatible shim; the SDK creates the `SpPlayerView` for you. Deprecated: use `attach(to:)`. | Both |
| Dismiss player | `vidgyorPlayer?.dismiss()` | Removes player and frees resources. | Both |
| Replay (VOD) | `vidgyorPlayer?.replay()` | Restarts from the first video, including its pre-roll. No effect for live. See [Repeat and Replay](#10-repeat-and-replay-vod). | Both |
| Diagnostic logging | `VidgyorPlayer.setDiagnosticLogging(enabled:mirrorToSyslog:)` | Turns on SDK logs in a release build. Call before creating a player. See [Diagnostic Logging](#12-diagnostic-logging). | Both |
| Disable player focus | `vidgyorPlayer?.setPlayerFocusEnabled(false)` | Prevents player from receiving focus (for custom overlays). | tvOS only |
| Restore player focus | `vidgyorPlayer?.restoreFocusToPlayer()` | Re-enables focus and returns focus to player. | tvOS only |
| Handle load errors | `didFailToLoadConfiguration(error:)` | The player couldn't load (for example, a configuration or network failure). | Both |
| Handle playback errors | `onPlayerError(error:)` | Playback failed after the SDK's automatic recovery gave up. | Both |
| Track ads | `isAdStart(value:), isAdEnd(value:), adError()` | Use for ad analytics and tracking. | Both |

## 7. Best Practices

* Always declare VidgyorPlayer as optional and clean up with dismiss().
* Implement `didFailToLoadConfiguration` and `didFinishPlayingAllVideos`.
* Avoid multiple player instances at once.
* Use delegate methods for tracking ads, buffering, and playback.
* Always dismiss player before switching between VOD and Live modes.
* With `repeatMode` `.off` (the default), the SDK shows a Replay screen at the end of a VOD list. Dismiss in `didFinishPlayingAllVideos()` only if you'd rather close the player.
* Don't ship with diagnostic logging turned on.
* **For custom overlays on tvOS:**
  * Disable player focus with `setPlayerFocusEnabled(false)` before showing UI
  * Restore focus with `restoreFocusToPlayer()` when dismissing UI
  * Handle DOWN gesture in your view controller to dismiss overlays
* **For custom UI on iOS:**
  * Use `didRequestFocusMove(_ direction:)` to detect swipe up/down gestures
  * No focus management APIs needed — the player handles touch input automatically

## 8. Complete Examples
### 🎞 VOD Example
```swift
final class PlayerViewController: UIViewController, VidgyorVODPlayerDelegate {

    private var vidgyorPlayer: VidgyorPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVODPlayer()
    }

    private func setupVODPlayer() {
        let vodItem = VODItem(videoUrl: "https://example.com/video.mp4")
        let config = PlayerConfig.VODConfig(vodList: [vodItem], delegate: self)

        let playerView = SpPlayerView()
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)

        vidgyorPlayer = VidgyorPlayer(accountId: "123", channelId: "456", config: .vod(config))
        vidgyorPlayer?.attach(to: playerView)
    }

    func didFailToLoadConfiguration(error: String) {
        presentAlert(title: "Error", message: error)
    }

    func didFinishPlayingAllVideos() {
        vidgyorPlayer?.dismiss()
    }
}
```

### 📡 Live Example
```swift
final class LiveViewController: UIViewController, VidgyorLivePlayerDelegate {

    private var vidgyorPlayer: VidgyorPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLivePlayer()
    }

    private func setupLivePlayer() {
        let liveConfig = PlayerConfig.LiveConfig(
            title: "Vidgyor News",
            delegate: self
        )

        let playerView = SpPlayerView()
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)

        vidgyorPlayer = VidgyorPlayer(accountId: "123", channelId: "LIVE001", config: .live(liveConfig))
        vidgyorPlayer?.attach(to: playerView)
    }

    func didFailToLoadConfiguration(error: String) {
        presentAlert(title: "Error", message: error)
    }
}
```

## 9. Player Customization (SpPlayerConfig)

Pass an optional `SpPlayerConfig` to the `VidgyorPlayer` initializer to customize video behavior, the on-screen controls, the logo, the error screen and analytics. Every field is optional: a value you set wins, and a field you leave `nil` falls back to the channel's configuration (where one exists) and then to the default listed below. Leaving out `playerConfig` keeps every default.

```swift
let playerConfig = SpPlayerConfig(
    videoConfig: VideoConfig(autoPlay: true, repeatMode: .off),
    overlayConfig: OverlayConfig(seekForwardIncrement: 10, showTitle: true),
    logoConfig: LogoConfig(enable: true, logoUrl: "https://example.com/logo.png"),
    errorConfig: ErrorConfig(retryTitle: "Try again")
)

vidgyorPlayer = VidgyorPlayer(
    accountId: "ACCOUNT_ID",
    channelId: "CHANNEL_ID",
    config: .vod(vodConfig),
    playerConfig: playerConfig
)
```

**SpPlayerConfig**

| Property | Type | Description |
|---|---|---|
| `videoConfig` | `VideoConfig` | Video behavior: scaling, autoplay, start position, rotation and repeat. |
| `overlayConfig` | `OverlayConfig` | The on-screen controls. |
| `logoConfig` | `LogoConfig` | A channel logo over live content. |
| `analyticsConfig` | `AnalyticsConfig` | Analytics reporting. |
| `errorConfig` | `ErrorConfig` | The error screen. |

**VideoConfig**

| Property | Type | Default | Description |
|---|---|---|---|
| `resizeMode` | `VideoResizeMode?` | `.fit` | How the video fills the player: `.fit` (letterboxed), `.zoom` (fills and crops) or `.fill` (stretches). iOS only. |
| `autoPlay` | `Bool?` | `true` | Start playback as soon as the video is ready. |
| `startPositionMs` | `Int?` | `0` | Start position for the first VOD video, in milliseconds. Applies once, to the first video only; ignored for live. Use it to resume where a viewer left off: the SDK doesn't save positions, so store one yourself (for example from `onTimeUpdate`). |
| `autoRotate` | `Bool?` | `true` | Enter full screen when the device rotates to landscape. iOS only. |
| `repeatMode` | `RepeatMode?` | `.off` | What happens when a video ends: `.off`, `.one` or `.all`. VOD only. See [Repeat and Replay](#10-repeat-and-replay-vod). |

**OverlayConfig**

| Property | Type | Default | Description |
|---|---|---|---|
| `autoHideDelay` | `TimeInterval?` | `3.0` | Seconds the controls stay visible before hiding. |
| `qualityControl` | `Bool?` | `true` | Show the Quality row in Settings. |
| `audioControl` | `Bool?` | `true` | Show the Audio row in Settings. |
| `captionControl` | `Bool?` | `false` | Show the Subtitles row in Settings. |
| `speedControl` | `Bool?` | `true` | Show the Playback Speed row in Settings (VOD only). |
| `showLiveBadge` | `Bool?` | `true` | Show the LIVE / GO LIVE badge on live streams. |
| `fullScreenControl` | `Bool?` | `true` | Show the full-screen button. iOS only; tvOS is always full screen. |
| `seekForwardIncrement` | `TimeInterval?` | `15` | Skip-forward step, in seconds (VOD). |
| `seekBackIncrement` | `TimeInterval?` | `5` | Skip-back step, in seconds (VOD). |
| `liveEdgeThreshold` | `TimeInterval?` | `30` | Seconds behind the live edge before the badge changes to GO LIVE. |
| `backgroundAlpha` | `CGFloat?` | `0.25` | Opacity of the dimming behind the controls, 0–1. |
| `enableSettings` | `Bool?` | `true` | Master switch for Settings. `false` hides the Quality, Audio and Playback Speed rows. |
| `showTitle` | `Bool?` | `true` | Show the content title at the top of the controls: `LiveConfig.title` for live, or the playing `VODItem`'s `title` for VOD, falling back to the channel's name. Hidden when blank and during ads. |

**LogoConfig**

| Property | Type | Default | Description |
|---|---|---|---|
| `enable` | `Bool?` | `false` | Show the logo. |
| `logoUrl` | `String?` | — | URL of the logo image. |
| `contentMode` | `UIView.ContentMode` | `.scaleAspectFit` | How the image scales within its box. |
| `widthPercentage` | `CGFloat?` | `0.25` | Logo width as a fraction of the player's width, 0–1. |
| `heightPercentage` | `CGFloat?` | `0.12` | Logo height as a fraction of the player's height, 0–1. |
| `horizontalBias` | `CGFloat?` | `1.0` | Horizontal position: 0 = left, 0.5 = center, 1 = right. |
| `verticalBias` | `CGFloat?` | `0.0` | Vertical position: 0 = top, 0.5 = center, 1 = bottom. |

The logo appears only on live content. It sits beneath the player controls and stays hidden for the whole of an ad break. Configure it here: since 1.7.0, `PlayerConfig.LiveConfig` no longer takes a `logoConfig`.

**AnalyticsConfig**

| Property | Type | Default | Description |
|---|---|---|---|
| `customEnabled` | `Bool?` | `true` | Send playback analytics to Vidgyor. |
| `firebaseEnabled` | `Bool?` | `true` | Present for parity with the Android SDK; has no effect on iOS or tvOS. |

**ErrorConfig**

| Property | Type | Default | Description |
|---|---|---|---|
| `enabled` | `Bool?` | `true` | Show the SDK's error screen. See [Error Screen](#11-error-screen). |
| `title` | `String?` | `"Something went wrong"` | Title for playback failures. |
| `message` | `String?` | `"We couldn't play this video. Please try again."` | Message for playback failures. |
| `retryTitle` | `String?` | `"Retry"` | Retry button label. |

## 10. Repeat and Replay (VOD)

`VideoConfig.repeatMode` sets what happens when a video ends. It applies to VOD only.

| Mode | Behavior | `didFinishPlayingAllVideos()` |
|---|---|---|
| `.off` (default) | The list plays through once. At the end, the player shows a Replay screen. | Called at the end of the list |
| `.one` | Loops the current video; a list never advances. | Never called |
| `.all` | Loops the whole list; a single-video list loops that video. | Never called |

The pre-roll ad plays at every content start in all three modes, including each loop.

```swift
let playerConfig = SpPlayerConfig(videoConfig: VideoConfig(repeatMode: .all))
```

To offer your own replay button, call `vidgyorPlayer?.replay()`. It restarts from the first video, including its pre-roll, and does nothing for live.

## 11. Error Screen

When the player can't load (for example, with no network or a configuration failure), or playback fails after the SDK's automatic recovery, the SDK shows an error screen with a title, a message and a Retry button. Ad failures never show it: the player continues with the content.

```swift
let playerConfig = SpPlayerConfig(
    errorConfig: ErrorConfig(
        title: "Playback problem",
        message: "Please check your connection and try again.",
        retryTitle: "Try again"
    )
)
```

Your title and message apply to playback failures; load failures use a specific title, such as "No Internet". To show your own error UI instead, pass `ErrorConfig(enabled: false)` and handle `didFailToLoadConfiguration(error:)` and `onPlayerError(error:)`, which are called either way.

## 12. Diagnostic Logging

Release builds of your app emit no SDK logs by default. To capture logs from a release build, for example on a device farm, turn on diagnostic logging before creating a player:

```swift
VidgyorPlayer.setDiagnosticLogging(enabled: true, mirrorToSyslog: true)
```

`mirrorToSyslog` also writes each line to the system log, which device-farm services capture. Lines look like `[Sp-Player:<Category>] <message>`. Use this for diagnosis only and ship with it off: the SDK logs a lot, and mirroring has a performance cost.

## 🧾 Summary
| Player Type               | Config Type         |  Delegate                                      |
|-------------------------|--------------|-----------|
| `VOD` | `PlayerConfig.VODConfig` | `VidgyorVODPlayerDelegate` |
| `Live` | `PlayerConfig.LiveConfig` | `VidgyorLivePlayerDelegate` |

Both configurations share the same `attach(to:)` workflow but differ in ad handling and playback source.

Both player types work on **tvOS** and **iOS** with the same public API. Platform differences are limited to focus/gesture input handling, the `showOverlay`/`hideOverlay` delegate callbacks (tvOS only) and the `playerWillEnterFullScreen`/`playerWillExitFullScreen` callbacks (iOS only).
