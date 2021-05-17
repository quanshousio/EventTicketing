//
//  ScannerView.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import FirebaseFirestore
import SwiftUI

#if !os(macOS)
struct ScannerView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @AppStorage(UserSettings.alwaysOnScanner) private var alwaysOnScanner: Bool = false

  @State private var runningScanner: Bool = true
  @State private var customer: Customer?
  @State private var viewAppearing: Bool = false

  var body: some View {
    Group {
      if viewAppearing {
        TicketScannerView(
          isRunning: $runningScanner,
          customer: $customer
        )
      } else {
        EmptyView()
      }
    }
    .navigationBarHidden(horizontalSizeClass == .compact)
    .ignoresSafeArea()
    .sheet(item: $customer) { item in
      NavigationView {
        TicketDetailView(customer: item)
      }
      .onAppear {
        if !alwaysOnScanner { runningScanner = false }
      }
      .onDisappear {
        if !alwaysOnScanner { runningScanner = true }
      }
    }
    .onAppearing {
      // workaround for views in TabView are prematurely initialized
      // https://developer.apple.com/forums/thread/656655
      viewAppearing = true
    }
  }
}

struct AppearView: UIViewControllerRepresentable {
  var action: () -> Void

  func makeUIViewController(context: Context) -> UIAppearViewController {
    let controller = UIAppearViewController()
    controller.action = action
    return controller
  }

  func updateUIViewController(_ controller: UIAppearViewController, context: Context) {}
}

class UIAppearViewController: UIViewController {
  var action: () -> Void = {}

  override func viewDidAppear(_ animated: Bool) {
    action()
  }
}

extension View {
  func onAppearing(perform action: @escaping () -> Void) -> some View {
    background(AppearView(action: action))
  }
}
#endif

#if os(macOS)
struct ScannerView: View {
  @AppStorage(UserSettings.alwaysOnScanner) private var alwaysOnScanner: Bool = false

  @State private var runningScanner: Bool = true
  @State private var customer: Customer?

  var body: some View {
    TicketScannerView(
      isRunning: $runningScanner,
      customer: $customer
    )
    .ignoresSafeArea()
    .sheet(item: $customer) { item in
      NavigationView {
        TicketDetailView(customer: item)
      }
      .onAppear {
        if !alwaysOnScanner { runningScanner = false }
      }
      .onDisappear {
        if !alwaysOnScanner { runningScanner = true }
      }
    }
  }
}
#endif
