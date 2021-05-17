//
//  OrderModel.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/3/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import EFQRCode
import FirebaseFirestore
import Resolver
import SwiftUI

final class OrderModel: ObservableObject {
  @Published var name: String = ""
  @Published var phone: String = ""
  @Published var email: String = ""
  @Published var quantity: Int = 1

  @Published var tickets: [UXImage] = []
  @Published var formValid: Bool = false

  @Injected private var repository: CustomerRepository

  private var cancellables: Set<AnyCancellable> = []

  private let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
  private let phoneRegex: String = "((0|\\+84)+([3|5|7|8|9]))+([0-9]{8})\\b"
  private let dueTime: RunLoop.SchedulerTimeType.Stride = 0.5

  let maxQuantity = 20

  init() {
    formValidPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.formValid, on: self)
      .store(in: &cancellables)

    didChangePublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.formValid = false
      }
      .store(in: &cancellables)
  }
}

extension OrderModel {
  var nameValidator: AnyPublisher<Validation, Never> {
    $name
      .debounce(for: dueTime, scheduler: RunLoop.main)
      .map {
        if $0.isEmpty {
          return .indeterminate
        } else if $0.count >= 3 {
          return .success
        } else {
          return .failure("Name is not valid")
        }
      }
      .eraseToAnyPublisher()
  }

  var phoneValidator: AnyPublisher<Validation, Never> {
    $phone
      .debounce(for: dueTime, scheduler: RunLoop.main)
      .map {
        if $0.isEmpty {
          return .indeterminate
        } else if $0.range(of: self.phoneRegex, options: .regularExpression) != nil {
          return .success
        } else {
          return .failure("Phone is not valid")
        }
      }
      .eraseToAnyPublisher()
  }

  var emailValidator: AnyPublisher<Validation, Never> {
    $email
      .debounce(for: dueTime, scheduler: RunLoop.main)
      .map {
        if $0.isEmpty {
          return .indeterminate
        } else if $0.range(of: self.emailRegex, options: .regularExpression) != nil {
          return .success
        } else {
          return .failure("Email is not valid")
        }
      }
      .eraseToAnyPublisher()
  }

  var quantityValidator: AnyPublisher<Validation, Never> {
    $quantity
      .debounce(for: dueTime, scheduler: RunLoop.main)
      .map { $0 > 0 && $0 <= self.maxQuantity ? .success : .failure("Quantity is not valid") }
      .eraseToAnyPublisher()
  }

  var formValidPublisher: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest4(
      nameValidator,
      phoneValidator,
      emailValidator,
      quantityValidator
    ).map { a, b, c, d in
      [a, b, c, d].allSatisfy { $0 == .success }
    }
    .eraseToAnyPublisher()
  }

  var didChangePublisher: AnyPublisher<(String, String, String, Int), Never> {
    Publishers.CombineLatest4(
      $name,
      $phone,
      $email,
      $quantity
    )
    .eraseToAnyPublisher()
  }
}

extension OrderModel {
  func clear() {
    name = ""
    phone = ""
    email = ""
    quantity = 1
    tickets = []
  }

  func buyTicket(_ completion: @escaping () -> Void) {
    let customer = Customer(
      createdAt: Timestamp(date: Date()),
      name: name,
      phone: phone,
      email: email,
      verified: false,
      sent: 0
    )

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }
      let ids = self.repository.add(customer: customer, quantity: self.quantity)
      ids.map { Customer(id: $0) }.forEach {
        $0.ticketImage()
          .sink {
            self.tickets.append($0)
            completion()
          }
          .store(in: &self.cancellables)
      }
    }
  }
}
