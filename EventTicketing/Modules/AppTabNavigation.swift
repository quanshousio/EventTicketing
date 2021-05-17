//
//  AppTabNavigation.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/27/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import SwiftUI
import ToastUI

#if !os(macOS)
struct AppTabNavigation: View {
  @SceneStorage("selectedTab") private var selectedTab: NavigationItem = .customers

  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationView {
        DatabaseView()
      }
      .tabItem {
        Label(L10n.customers, systemImage: "rectangle.stack.person.crop.fill")
          .accessibility(label: Text(L10n.customers))
      }
      .tag(NavigationItem.customers)

      NavigationView {
        OrderView()
      }
      .tabItem {
        Label(L10n.order, systemImage: "greetingcard.fill")
          .accessibility(label: Text(L10n.order))
      }
      .tag(NavigationItem.order)

      NavigationView {
        ScannerView()
      }
      .tabItem {
        Label(L10n.scanner, systemImage: "qrcode.viewfinder")
          .accessibility(label: Text(L10n.scanner))
      }
      .tag(NavigationItem.scanner)

      NavigationView {
        SettingsView()
      }
      .tabItem {
        Label(L10n.settings, systemImage: "gearshape.2.fill")
          .accessibility(label: Text(L10n.settings))
      }
      .tag(NavigationItem.settings)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
#endif
