#
# Vidgyor-Player.podspec — binary-only CocoaPods distribution of the Vidgyor SDK.
#
# Installed straight from this repository, not from the CocoaPods trunk (which becomes
# read-only on 2026-12-02, after which it accepts no new versions):
#
#   pod 'Vidgyor-Player', :git => 'https://github.com/pddesai/vidgyor-player-ios.git', :tag => 'v1.7.0'
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
  s.version = '1.7.0'

  s.summary = 'Video player SDK for iOS and tvOS with live, VOD and IMA ad support.'
  s.description = <<-DESC
    VidgyorPlayer is a binary-distributed video player SDK for iOS and tvOS. It provides
    live and VOD playback, Google IMA ad integration (preroll and midroll), custom player
    controls, tvOS focus handling, and playback analytics.

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
  s.ios.dependency  'GoogleAds-IMA-iOS-SDK',  '~> 3.30'
  s.tvos.dependency 'GoogleAds-IMA-tvOS-SDK', '~> 4.16'

  s.frameworks = 'AVFoundation', 'AVKit', 'CoreMedia', 'UIKit', 'Foundation'
end
