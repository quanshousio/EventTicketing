//
//  Validator.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/17/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import SwiftUI

enum Validation: Equatable {
  case indeterminate
  case success
  case failure(String)
}

final class Validator: ObservableObject {
  private let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
  private let phoneRegex: String = "((0|\\+84)+([3|5|7|8|9]))+([0-9]{8})\\b"
  private let dueTime: DispatchQueue.SchedulerTimeType.Stride = 0.5

  private init() {}

  static let shared = Validator()

  func name(_ name: Published<String>.Publisher) -> AnyPublisher<Validation, Never> {
    name
      .debounce(for: dueTime, scheduler: DispatchQueue.main)
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

  func phone(_ phone: Published<String>.Publisher) -> AnyPublisher<Validation, Never> {
    phone
      .debounce(for: dueTime, scheduler: DispatchQueue.main)
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

  func email(_ email: Published<String>.Publisher) -> AnyPublisher<Validation, Never> {
    email
      .debounce(for: dueTime, scheduler: DispatchQueue.main)
      .map {
        if $0.isEmpty {
          return .indeterminate
        } else if $0.range(of: self.emailRegex, options: .regularExpression) != nil {
          return .success
        } else {
          return .failure("Phone is not valid")
        }
      }
      .eraseToAnyPublisher()
  }
}
