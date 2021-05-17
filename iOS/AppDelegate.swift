//
//  AppDelegate.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/1/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Cache
import FirebaseCore
import IQKeyboardManagerSwift
import Resolver
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
  static var orientationLock: UIInterfaceOrientationMask = .all

  static var imageCache: Storage<String, Image> = {
    try! Storage<String, Image>(
      diskConfig: DiskConfig(name: "image_cache"),
      memoryConfig: MemoryConfig(),
      transformer: TransformerFactory.forImage()
    )
  }()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = false
    IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true

    return true
  }

  func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    AppDelegate.orientationLock
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    UISceneConfiguration(
      name: "Default Configuration",
      sessionRole: connectingSceneSession.role
    )
  }

  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running,
    // this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes,
    // as they will not return.
  }
}

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register { CustomerRepository() }.scope(.application)
  }
}
