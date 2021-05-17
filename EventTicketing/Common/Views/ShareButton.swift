//
//  ShareButton.swift
//  EventTicketing
//
//  Created by Quan Tran on 11/10/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct ShareButton: View {
  var images: [UXImage]

  @State private var isPresented: Bool = false

  var body: some View {
    Button {
      isPresented = true
    } label: {
      Label(L10n.share, systemImage: "square.and.arrow.up")
    }
    .sheet(isPresented: $isPresented) {
      ActivityView(activityItems: images)
    }
  }
}
