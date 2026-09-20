# AppleRSSFeedWatcher

A small macOS menu bar app that shows [Apple Developer releases](https://developer.apple.com/news/releases/)
and notifies you when something new is published.

## Features

- Menu bar popover with the latest entries from Apple's releases RSS feed
- Filter by All / Beta / Released, plus title search
- System notifications for new items; clicking one opens the release page
- Configurable refresh interval (15 minutes to 6 hours) and Launch at Login

## Requirements

macOS 14.6 or later. Building requires Xcode 26 (Swift 6).

## Build & Run

```sh
open src/AppleRSSFeedWatcher/AppleRSSFeedWatcher.xcodeproj
```

Then build and run the `AppleRSSFeedWatcher` scheme, or from the command line:

```sh
xcodebuild -project src/AppleRSSFeedWatcher/AppleRSSFeedWatcher.xcodeproj \
           -scheme AppleRSSFeedWatcher build
```

## Releases

Pushing a `v*` tag runs the [build-signed](.github/workflows/build-signed.yml) workflow, which builds, signs and notarizes the app and attaches a DMG to the GitHub release.
The version is set in [Versioning.xcconfig](src/AppleRSSFeedWatcher/Versioning.xcconfig).

## License

[MIT](LICENSE)
