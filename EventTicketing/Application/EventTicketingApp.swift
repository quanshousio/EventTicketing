//
//  EventTicketingApp.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/23/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

@main
struct EventTicketingApp: App {
  #if !os(macOS)
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  #else
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  #endif

  @State private var presentingSplashScreen: Bool = true

  var body: some Scene {
    WindowGroup {
      RootView()
        .splashScreen(isPresented: $presentingSplashScreen)
    }
    .commands {
      SidebarCommands()
    }

    #if os(macOS)
    Settings {
      SettingsView()
    }
    #endif
  }
}
