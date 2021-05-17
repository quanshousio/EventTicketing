//
//  OrderedTicketView.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/27/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import CoreHaptics
import EFQRCode
import SwiftUI

struct OrderedTicketView: View {
  @Environment(\.presentationMode) private var presentationMode

  @ObservedObject private var model: OrderModel

  @State private var presentingConfettiView: Bool = false
  @State private var toolbarSize: CGSize = .zero
  @State private var chosenTicket: UXImage?

  private var engine: CHHapticEngine?

  private var columns: [GridItem] {
    Array(
      repeating: GridItem(.flexible()),
      count: Int(Double(model.quantity).squareRoot())
    )
  }

  init(model: OrderModel) {
    self.model = model

    // init engine doesn't work at onAppear
    do {
      engine = try CHHapticEngine()
      try engine?.start()
    } catch {
      print("[TicketView] Failed to initialize haptic engine: \(error.localizedDescription)")
    }
  }

  var body: some View {
    GeometryReader { proxy in
      ScrollView(showsIndicators: false) {
        LazyVGrid(columns: columns) {
          ForEach(model.tickets, id: \.self) { ticket in
            Image(uxImage: ticket)
              .resizable()
              .frame(
                maxWidth: proxy.size.width - 32,
                maxHeight: proxy.size.height - toolbarSize.height - 32
              )
              .aspectRatio(1, contentMode: .fit)
              .shadow(radius: 4)
              .padding(4) // padding for shadow
              .contextMenu {
                Button {
                  chosenTicket = ticket
                } label: {
                  Label(L10n.share, systemImage: "square.and.arrow.up")
                }
                SaveButton(iconOnly: false, images: [ticket])
                SendButton(
                  iconOnly: false,
                  images: [ticket],
                  name: model.name,
                  email: model.email
                )
              }
          }
        }
        .padding([.horizontal, .top])
      }
    }
    .overlay(
      ConfettiView(isPresented: $presentingConfettiView)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    )
    .sheet(item: $chosenTicket) { ticket in
      ActivityView(activityItems: [ticket])
    }
    .navigationTitle(L10n.ticket)
//    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          L10n.done.text.bold()
        }
      }

      #if !os(macOS)
      ToolbarItemGroup(placement: .bottomBar) {
        ShareButton(images: model.tickets)
        Spacer()
        SaveButton(iconOnly: true, images: model.tickets)
        Spacer()
        SendButton(iconOnly: true, images: model.tickets, name: model.name, email: model.email)
      }
      #else
      ToolbarItemGroup(placement: .automatic) {
        ShareButton(images: model.tickets)
        Spacer()
        SaveButton(iconOnly: true, images: model.tickets)
        Spacer()
        SendButton(iconOnly: true, images: model.tickets, name: model.name, email: model.email)
      }
      #endif
    }
    .onAppear {
      presentingConfettiView = true

      do {
        let path = Bundle.main.path(forResource: "HapticPattern", ofType: "ahap") ?? ""
        try engine?.playPattern(from: URL(fileURLWithPath: path))
      } catch {
        print("Failed to play haptic pattern: \(error.localizedDescription)")
      }
    }
    .onDisappear {
      model.clear()
    }
  }
}
