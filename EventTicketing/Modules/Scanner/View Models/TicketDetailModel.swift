//
//  TicketDetailModel.swift
//  EventTicketing
//
//  Created by Quan Tran on 11/15/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import FirebaseFirestore
import Resolver
import SwiftUI

final class TicketDetailModel: ObservableObject {
  @Published var customer: Customer
  @Published var ticket: UXImage

  @Injected private var repository: CustomerRepository

  @Published var toastItem: ToastItem?

  private var cancellables: Set<AnyCancellable> = []

  init(customer: Customer) {
    self.customer = customer
    self.ticket = Asset.ticketPlaceholder.image

    customer.ticketImage()
      .assign(to: \.ticket, on: self)
      .store(in: &cancellables)
  }

  func confirmTicket() {
    if let id = customer.id, !customer.verified {
      let fields: [String: Any] = ["verified": true, "verifiedAt": Timestamp()]
      repository.update(id: id, fields: fields) { [weak self] result in
        if result {
          self?.toastItem = ToastItem(message: L10n.Ticket.verifySuccess, type: .success)
        } else {
          self?.toastItem = ToastItem(message: L10n.Ticket.verifyFailed, type: .error)
        }
      }
    } else {
      toastItem = ToastItem(message: L10n.Ticket.verifyFailed, type: .error)
    }
  }
}
