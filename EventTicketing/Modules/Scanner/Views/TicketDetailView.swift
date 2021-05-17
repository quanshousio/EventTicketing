//
//  TicketDetailView.swift
//  EventTicketing
//
//  Created by Quan Tran on 7/12/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import FirebaseFirestore
import Resolver
import SwiftUI
import ToastUI

#if !os(macOS)
struct TicketDetailView: View {
  @Environment(\.presentationMode) private var presentationMode
  @Environment(\.verticalSizeClass) private var verticalSizeClass

  @StateObject private var model: TicketDetailModel

  init(customer: Customer) {
    _model = StateObject(wrappedValue: TicketDetailModel(customer: customer))
  }

  var body: some View {
    VStack(spacing: 0) {
      if verticalSizeClass == .regular {
        Image(uiImage: model.ticket)
          .resizable()
          .padding(.horizontal)
          .padding(.top)
          .aspectRatio(1, contentMode: .fit)
          .shadow(radius: 4.0)
          .saturation(!verified ? 1.0 : 0.0)
      }

      if !model.customer.name.isEmpty {
        Text(model.customer.name).font(.title).bold().padding()
      }

      Form {
        if let email = model.customer.email, !email.isEmpty {
          TicketDetailRow(title: L10n.email, detail: email)
        }
        if let phone = model.customer.phone, !phone.isEmpty {
          TicketDetailRow(title: L10n.phone, detail: phone)
        }
        if let createdAt = model.customer.createdAt {
          TicketDetailRow(title: L10n.createdAt, detail: convertDateToString(createdAt.dateValue()))
        }
        if let sent = model.customer.sent, sent >= 0 {
          TicketDetailRow(title: L10n.sent, detail: String(sent))
        }
        if let sentAt = model.customer.sentAt {
          TicketDetailRow(title: L10n.sentAt, detail: convertDateToString(sentAt.dateValue()))
        }
        if let verifiedAt = model.customer.verifiedAt {
          TicketDetailRow(
            title: L10n.verifiedAt,
            detail: convertDateToString(verifiedAt.dateValue())
          )
        }
      }

      // confirm button
      Button {
        model.confirmTicket()
      } label: {
        Text(
          valid
            ? !verified
            ? L10n.verify
            : L10n.Ticket.alreadyVerified
            : L10n.Ticket.notValid
        )
        .bold()
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .colorMultiply(validity ? Color(.white) : .init(.placeholderText))
        .background(
          RoundedRectangle(cornerRadius: 14.0, style: .continuous)
            .fill(validity ? Color(.cdsl) : Color(.systemGray5))
            .shadow(radius: validity ? 3 : 0, x: 0, y: validity ? 3 : 0)
        )
      }
      .padding()
      .disabled(!validity)
      .toast(item: $model.toastItem, dismissAfter: 1.5) {
        presentationMode.wrappedValue.dismiss()
      } content: { item in
        switch item.type {
        case .success:
          ToastView(item.message)
            .toastViewStyle(SuccessToastViewStyle())
        case .error:
          ToastView(item.message)
            .toastViewStyle(ErrorToastViewStyle())
        default:
          EmptyView()
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          L10n.cancel.text.bold()
        }
      }
    }
  }
}

extension TicketDetailView {
  private var valid: Bool {
    model.customer.id != nil
  }

  private var verified: Bool {
    model.customer.verified
  }

  private var validity: Bool {
    !verified && valid
  }
}

extension TicketDetailView {
  private func convertDateToString(_ date: Date) -> String {
    DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
  }
}

struct TicketDetailRow: View {
  var title: String
  var detail: String

  var body: some View {
    HStack {
      Text(title)
      Spacer()
      Text(detail)
    }
  }
}
#endif

#if os(macOS)
struct TicketDetailView: View {
  init(customer: Customer) {}

  var body: some View {
    EmptyView()
  }
}
#endif
