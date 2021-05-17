//
//  RootView.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

#if !os(macOS)
struct RootView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    if horizontalSizeClass == .compact {
      AppTabNavigation()
    } else {
      AppSidebarNavigation()
    }
  }
}
#endif

#if os(macOS)
struct RootView: View {
  var body: some View {
    AppSidebarNavigation()
  }
}
#endif
