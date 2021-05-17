//
//  OrderView.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import SwiftUI
import ToastUI

struct OrderView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.verticalSizeClass) private var verticalSizeClass

  @StateObject private var model = OrderModel()
//  @StateObject private var validator = Validator.shared

  @State private var shouldAnimate: Bool = false
  @State private var presentingTicketView: Bool = false
//  @State private var presentingAlert: Bool = false
  @State private var presentingToast: Bool = false

  private var content: some View {
    VStack(spacing: 16) {
      // form
      VStack {
        FloatingLabelTextField(
          L10n.name,
          text: $model.name,
          validator: model.nameValidator
        )
        .frame(height: 42)
        .tag(0)

        FloatingLabelTextField(
          L10n.phone,
          text: $model.phone,
          validator: model.phoneValidator
        )
        .frame(height: 42)
        .tag(1)

        FloatingLabelTextField(
          L10n.email,
          text: $model.email,
          validator: model.emailValidator
        )
        .frame(height: 42)
        .tag(2)

        Stepper(value: $model.quantity, in: 0 ... model.maxQuantity) {
          Text(L10n.quantity + ": \(model.quantity)").bold().animation(.none)
        }
      }

      Spacer()

      // buy button
      Button {
        presentingToast = true
        model.buyTicket {
          presentingToast = false
        }
      } label: {
        Text(L10n.order)
          .bold()
      }
      .disabled(!model.formValid)
//      .alert(isPresented: $presentingAlert) {
//        Alert(title: L10n.error.text, message: L10n.Ticket.buyFailed.text)
//      }
      .sheet(isPresented: $presentingTicketView) {
        OrderedTicketView(model: model)
      }
      .toast(isPresented: $presentingToast) {
        presentingTicketView = true
      } content: {
        ToastView(L10n.loading)
          .toastViewStyle(IndefiniteProgressToastViewStyle())
      }
    }
    .blur(radius: presentingTicketView ? 3.0 : .zero)
    .padding()
    .navigationTitle(L10n.order)
  }

  var body: some View {
    content
  }
}
