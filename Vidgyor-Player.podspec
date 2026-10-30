#
# Vidgyor-Player.podspec — binary-only CocoaPods distribution of the Vidgyor SDK.
#
# Installed straight from this repository:
#
#   pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.8.1'
#
# 1.7.0 and 1.8.x were also pushed to the CocoaPods trunk with this file. The trunk becomes
# read-only on 2026-12-02 and takes no later versions, so 1.8.x is the last trunk line, the
# trunk pod is marked deprecated, and the summary and description below say so on
# cocoapods.org. Releases after 1.8.x install only from this repository (or with SPM).
#
# With a :git source CocoaPods takes the files from the tagged commit itself, so the
# prebuilt framework must be committed at Sources/Vidgyor.xcframework — the same copy the
# Swift package uses. `s.version` is rewritten by the SDK's release script to match the tag;
# do not edit it by hand.
#
# NOTE ON NAMES: the pod is `Vidgyor-Player`, but the framework and Swift module are
# `Vidgyor`, so consumers write `pod 'Vidgyor-Player'` and `import Vidgyor`. That split is
# normal for CocoaPods (the pod GoogleAds-IMA-iOS-SDK vends the module
# GoogleInteractiveMediaAds).
#

Pod::Spec.new do |s|
  s.name    = 'Vidgyor-Player'
  s.version = '1.8.0'

  s.summary = 'Video player SDK for iOS and tvOS (live, VOD, Google IMA ads). Last CocoaPods trunk release: later versions are on GitHub.'
  s.description = <<-DESC
    NOTICE: this is the last Vidgyor-Player release on the CocoaPods trunk. CocoaPods is making
    its trunk (the central Specs repository) read-only on 2 December 2026, after which it accepts
    no new versions (https://blog.cocoapods.org/CocoaPods-Specs-Repo/). Vidgyor-Player therefore
    gets no further updates here. New versions are published only on GitHub,
    https://github.com/pddesai/vidgyor-player-ios:
    - Swift Package Manager (recommended), or
    - CocoaPods from GitHub:
      pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'vX.Y.Z'

    VidgyorPlayer is a binary-distributed video player SDK for iOS and tvOS. It provides
    live and VOD playback, FairPlay DRM for protected HLS streams, Google IMA ad integration
    (preroll and midroll), custom player controls, tvOS focus handling, and playback analytics.

    Support: for technical questions about integration, email support@vidgyor.com
  DESC

  s.homepage = 'https://github.com/pddesai/vidgyor-player-ios'
  s.author   = { 'silverpush' => 'admin@silverpush.co' }
  s.documentation_url = 'https://docs.google.com/document/d/1VV8ACWhyZMrWEmnour4dBVYHP2x5pYOh/view'
  s.license  = { :type => 'Commercial', :file => 'LICENSE' }

  s.ios.deployment_target  = '16.0'
  s.tvos.deployment_target = '15.0'
  s.swift_versions         = ['5.0']

  s.source = { :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => "v#{s.version}" }
  s.vendored_frameworks = 'Sources/Vidgyor.xcframework'

  # Not optional: the public .swiftinterface inside the xcframework carries
  # `import GoogleInteractiveMediaAds`, so the module must resolve at consumer compile
  # time, not just at link time. Both pods vend the same `GoogleInteractiveMediaAds` module.
  # Minimums are the versions the SDK is built and tested with.
  s.ios.dependency  'GoogleAds-IMA-iOS-SDK',  '~> 3.33'
  s.tvos.dependency 'GoogleAds-IMA-tvOS-SDK', '~> 4.17'

  s.frameworks = 'AVFoundation', 'AVKit', 'CoreMedia', 'UIKit', 'Foundation'
end
