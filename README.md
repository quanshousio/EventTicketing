# EventTicketing

`EventTicketing` is an iOS/macOS application that provides you a simple way to create and manage your own event tickets.

![screenshot](https://i.imgur.com/0XGoCwH.png)

## Features

* Rich user interface to display, order, edit, scan and validate tickets.
* Support different delivery services to send tickets. This app currently supports built-in Mail application and [SendGrid](https://sendgrid.com/).
* Display a toast notification to user while handling expensive computations using in-house [ToastUI](https://github.com/quanshousio/ToastUI) package.
* Support multiple languages and able to change the language at runtime. This app currently supports English and Vietnamese.
* Vectorized Twitter-like splash screen and animated confetti effect to celebrate the user using [Core Animation](https://developer.apple.com/documentation/quartzcore) framework.

## Frameworks

* MVVM architecture with [SwiftUI](https://developer.apple.com/documentation/swiftui/) and [Combine](https://developer.apple.com/documentation/combine) to build rich user interfaces and handle asynchronous events.
* [Firebase](https://firebase.google.com/) as the backend for real-time database.
* [Swift Package Manager](https://swift.org/package-manager/) for managing third-party packages.
* [Mac Catalyst](https://developer.apple.com/mac-catalyst/) for sharing code between iOS and macOS platforms. This app also has an in-development macOS native version using AppKit.

## Requirements

* iOS 14.0+ | macOS 11.0+
* Xcode 12.0+ | Swift 5.3+

## Installation

* Clone this repository.
* Replace the Firebase iOS configuration file `GoogleService-Info.plist` in `./EventTicketing/Application` folder with your own one.
* Change the Bundle Identifier of the application to match with the one you provided when you setup the Firebase integration.
* Replace the SendGrid API key in `SG_API_KEY` environment variable in Xcode's build scheme with your own one.
* Install [`SwiftGen`](https://github.com/SwiftGen/SwiftGen) using your choice of package manger.
* Open the project and build.

## Contributing

All issue reports, feature requests, pull requests and GitHub stars are welcomed and much appreciated.

## Author

Quan Tran ([@quanshousio](https://quanshousio.com))

## License

`EventTicketing` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
