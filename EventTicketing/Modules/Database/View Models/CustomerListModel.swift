//
//  CustomerListViewModel.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/2/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import Foundation
import Resolver
import SwiftUI
import OrderedDictionary

final class CustomerListModel: ObservableObject {
  @Published var customers: OrderedDictionary<String, CustomerDetailModel> = [:]

  @Injected private var repository: CustomerRepository
  
  private var cancellables: Set<AnyCancellable> = []

  init() {
    repository.$customers
      .map {
        OrderedDictionary(uniqueKeysWithValues: $0.map {
          ($0.id ?? "", CustomerDetailModel(customer: $0))
        })
      }
      .assign(to: \.customers, on: self)
      .store(in: &cancellables)
  }

  func remove(atOffsets indexSet: IndexSet) {
    let customers = indexSet.map { repository.customers[$0] }
    repository.remove(customers: customers)
  }

  func remove(ids: [String]) {
    repository.remove(ids: ids)
  }
}

extension OrderedDictionary where Key == String, Value == CustomerDetailModel {
  subscript(unchecked key: Key) -> Value {
    get {
      if let result = self[key] {
        return result
      } else {
//        fatalError("[OrderedDictionary] CustomerDetailModel does not exist for key: \(key)")
        return CustomerDetailModel(customer: Customer())
      }
    }
    set {
      self[key] = newValue
    }
  }
}
