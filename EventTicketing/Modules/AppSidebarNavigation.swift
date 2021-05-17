//
//  AppSidebarNavigation.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/27/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import SwiftUI

#if !os(macOS)
struct AppSidebarNavigation: View {
  @State private var selection: NavigationItem? = .customers
//  @SceneStorage("selectedTab") private var selectedTab: NavigationItem = .customers

  var body: some View {
    NavigationView {
      List(selection: $selection) {
        NavigationLink(destination: DatabaseView()) {
          Label(L10n.customers, systemImage: "rectangle.stack.person.crop.fill")
        }
        .accessibility(label: Text(L10n.customers))
        .tag(NavigationItem.customers)

        NavigationLink(destination: OrderView()) {
          Label(L10n.order, systemImage: "greetingcard.fill")
        }
        .accessibility(label: Text(L10n.order))
        .tag(NavigationItem.order)

        NavigationLink(destination: ScannerView()) {
          Label(L10n.scanner, systemImage: "qrcode.viewfinder")
        }
        .accessibility(label: Text(L10n.scanner))
        .tag(NavigationItem.scanner)
        
        NavigationLink(destination: SettingsView()) {
          Label(L10n.settings, systemImage: "gearshape.2.fill")
        }
        .accessibility(label: Text(L10n.settings))
        .tag(NavigationItem.settings)
      }
      .listStyle(SidebarListStyle())
    }
  }
}
#endif

#if os(macOS)
struct AppSidebarNavigation: View {
  @State private var selection: NavigationItem? = .customers
  //  @SceneStorage("selectedTab") private var selectedTab: NavigationItem = .customers
  
  var body: some View {
    NavigationView {
      List(selection: $selection) {
        NavigationLink(destination: DatabaseView()) {
          Label(L10n.customers, systemImage: "rectangle.stack.person.crop")
        }
        .accessibility(label: Text(L10n.customers))
        .tag(NavigationItem.customers)
        
        NavigationLink(destination: OrderView()) {
          Label(L10n.order, systemImage: "greetingcard")
        }
        .accessibility(label: Text(L10n.order))
        .tag(NavigationItem.order)
        
        NavigationLink(destination: ScannerView()) {
          Label(L10n.scanner, systemImage: "qrcode.viewfinder")
        }
        .accessibility(label: Text(L10n.scanner))
        .tag(NavigationItem.scanner)
      }
      .listStyle(SidebarListStyle())
      .animation(nil)
      .frame(minWidth: 200, idealWidth: 200, maxWidth: 200, maxHeight: .infinity)
    }
  }
}
#endif
