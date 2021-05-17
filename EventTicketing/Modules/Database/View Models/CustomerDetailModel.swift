//
//  CustomerDetailModel.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/17/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import Firebase
import Resolver
import SwiftUI

final class CustomerDetailModel: ObservableObject, Identifiable {
  @Published var customer: Customer
  @Published var ticket: UXImage

  var id: String = ""

  @Injected private var repository: CustomerRepository

  private var cancellables: Set<AnyCancellable> = []

  init(customer: Customer) {
    self.customer = customer
    self.ticket = Asset.ticketPlaceholder.image

    $customer
      .compactMap(\.id)
      .assign(to: \.id, on: self)
      .store(in: &cancellables)

    customer.ticketImage()
      .assign(to: \.ticket, on: self)
      .store(in: &cancellables)

    $customer
      .dropFirst() // prevent cycle
      .debounce(for: 1.5, scheduler: RunLoop.main)
      .sink { [weak self] customer in
        self?.repository.set(customer: customer)
        self?.repository.update(
          id: customer.id ?? "",
          fields: ["updatedAt": Timestamp(date: Date())]
        )
      }
      .store(in: &cancellables)
  }
}
