//
//  AppDelegate.swift
//  EventTicketing (macOS)
//
//  Created by Quan Tran on 11/14/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Cache
import Cocoa
import FirebaseCore
import Foundation
import Resolver
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!

  static var imageCache: Storage<String, Cache.Image> = {
    try! Storage<String, Cache.Image>(
      diskConfig: DiskConfig(name: "image_cache"),
      memoryConfig: MemoryConfig(),
      transformer: TransformerFactory.forImage()
    )
  }()

  override init() {
    super.init()
    FirebaseApp.configure()
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
//    window = NSWindow(
//      contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
//      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//      backing: .buffered,
//      defer: false
//    )
//    window.isReleasedWhenClosed = false
//    window.center()
//    window.setFrameAutosaveName("EventTicketing")
//    window.contentView = NSHostingView(rootView: RootView())
//    window.makeKeyAndOrderFront(nil)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register { CustomerRepository() }.scope(application)
  }
}
