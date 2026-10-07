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

> The pod is not published to the CocoaPods trunk: the trunk becomes read-only in December
> 2026 and accepts no new versions after that. Point your `Podfile` at this repository and
> the release tag instead, as below. Each release's tag is listed under **Releases**.

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

> **Optional — customize the player.** The initializer also accepts a `playerConfig: SpPlayerConfig`, letting you tune video behavior (`VideoConfig`), on-screen controls (`OverlayConfig`), and a channel logo (`LogoConfig`):
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
* **iOS only:** A dismiss button is displayed automatically in the top-left corner of the player.

> **Migrating from `embed(in:)`?** The legacy `embed(in:)` / `embed(into:in:)` methods still work (see [Player Lifecycle](#6-player-lifecycle)) — they now create an `SpPlayerView` for you under the hood. New integrations should prefer `attach(to:)`.

### Step 5: Conform to VidgyorVODPlayerDelegate

Implement delegate methods to handle player events, errors, and analytics.
```swift
extension MyViewController: VidgyorVODPlayerDelegate {

    // MARK: - Required

    // Triggered when SDK fails to initialize
    func didFailToLoadConfiguration(error: String) {
        presentAlert(title: "Error", message: error)
    }

    // Triggered when all VOD items finish playing
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
| `didFinishPlayingAllVideos()` | Triggered when all VOD items finish playing. Use to call `vidgyorPlayer?.dismiss()`. |


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
| `disablePrerollAdTags`  | `Bool`       | ❌        | Disable preroll ads (default: `false`).          |
| `disableMidrollAdTags`  | `Bool`       | ❌        | Disable midroll ads (default: `false`).          |
| `midrollAdTags`         | `[String]`   | ❌        | Array of midroll ad tag URLs.                    |
| `delegate` | `VidgyorLivePlayerDelegate` | ✅ | Delegate for playback and analytics events.


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
* **iOS only:** A dismiss button is displayed automatically in the top-left corner of the player.
* `embed(in:)` remains available for existing integrations (see [Player Lifecycle](#6-player-lifecycle)).

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
- **Tap** — toggles play/pause (tap is automatically suppressed during ad playback so the IMA skip button can receive touches)
- **Dismiss button** — a dismiss button is shown in the top-left corner of the player and calls `vidgyorPlayer?.dismiss()` automatically

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
| Embed player (legacy) | `vidgyorPlayer?.embed(in: parentVC)` / `embed(into:in:)` | Backward-compatible shim; the SDK creates the `SpPlayerView` for you. | Both |
| Dismiss player | `vidgyorPlayer?.dismiss()` | Removes player and frees resources. | Both |
| Disable player focus | `vidgyorPlayer?.setPlayerFocusEnabled(false)` | Prevents player from receiving focus (for custom overlays). | tvOS only |
| Restore player focus | `vidgyorPlayer?.restoreFocusToPlayer()` | Re-enables focus and returns focus to player. | tvOS only |
| Handle errors | `didFailToLoadConfiguration(error:)` | Called on load or playback failure. | Both |
| Track ads | `isAdStart(value:), isAdEnd(value:), adError()` | Use for ad analytics and tracking. | Both |

## 7. Best Practices

* Always declare VidgyorPlayer as optional and clean up with dismiss().
* Implement `didFailToLoadConfiguration` and `didFinishPlayingAllVideos`.
* Avoid multiple player instances at once.
* Use delegate methods for tracking ads, buffering, and playback.
* Always dismiss player before switching between VOD and Live modes.
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

## 🧾 Summary
| Player Type               | Config Type         |  Delegate                                      |
|-------------------------|--------------|-----------|
| `VOD` | `PlayerConfig.VODConfig` | `VidgyorVODPlayerDelegate` |
| `Live` | `PlayerConfig.LiveConfig` | `VidgyorLivePlayerDelegate` |

Both configurations share the same embedding workflow but differ in ad handling and playback source.

Both player types work on **tvOS** and **iOS** with the same public API. Platform differences are limited to focus/gesture input handling and the `showOverlay`/`hideOverlay` delegate callbacks which are tvOS-only.
