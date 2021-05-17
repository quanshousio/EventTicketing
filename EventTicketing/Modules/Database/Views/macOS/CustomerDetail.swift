//
//  CustomerDetail.swift
//  EventTicketing
//
//  Created by Quan Tran on 12/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Firebase
import SwiftUI

struct CustomerDetail: View {
  @Environment(\.verticalSizeClass) private var verticalSizeClass

  @Binding var model: CustomerDetailModel

  @State private var chosenTicket: UXImage?

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    return formatter
  }

  var body: some View {
    List {
      Section(header: L10n.identification.text) {
        if verticalSizeClass == .regular {
          Image(nsImage: model.ticket)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 100, height: 100)
            .shadow(radius: 4)
            .contextMenu {
//              ShareButton(images: [ticket])
              Button {
                chosenTicket = model.ticket
              } label: {
                Label(L10n.share, systemImage: "square.and.arrow.up")
              }
              SaveButton(iconOnly: false, images: [model.ticket])
              SendButton(
                iconOnly: false,
                images: [model.ticket],
                name: model.customer.name,
                email: model.customer.email
              )
            }
        }
        CustomerTextView(title: "ID", text: $model.customer.id.unwrapped).disabled(true)
        if model.customer.createdAt != nil {
          CustomerValueView(
            title: L10n.createdAt,
            value: $model.customer.createdAt.unwrapped.date,
            formatter: dateFormatter
          ).disabled(true)
        }
        if model.customer.updatedAt != nil {
          CustomerValueView(
            title: L10n.updatedAt,
            value: $model.customer.updatedAt.unwrapped.date,
            formatter: dateFormatter
          ).disabled(true)
        }
      }

      Section(header: L10n.about.text) {
        CustomerTextView(title: L10n.name, text: $model.customer.name)
        CustomerTextView(title: L10n.phone, text: $model.customer.phone)
        CustomerTextView(title: L10n.email, text: $model.customer.email)
      }

      Section(header: L10n.verification.text) {
        Toggle(L10n.verify, isOn: $model.customer.verified)
        if model.customer.verifiedAt != nil {
          CustomerValueView(
            title: L10n.verifiedAt,
            value: $model.customer.verifiedAt.unwrapped.date,
            formatter: dateFormatter
          ).disabled(true)
        }
        CustomerValueView(
          title: L10n.sent,
          value: $model.customer.sent,
          formatter: NumberFormatter()
        )
        if model.customer.sentAt != nil {
          CustomerValueView(
            title: L10n.sentAt,
            value: $model.customer.sentAt.unwrapped.date,
            formatter: dateFormatter
          ).disabled(true)
        }
      }
    }
    .onChange(of: model.customer.verified) {
      model.customer.verifiedAt = $0 ? Timestamp(date: Date()) : nil
    }
    .onChange(of: model.customer.sent) {
      model.customer.sentAt = $0 > 0 ? Timestamp(date: Date()) : nil
    }
    .sheet(item: $chosenTicket) { ticket in
      ActivityView(activityItems: [ticket])
    }
    .padding()
  }
}
