//
//  CustomerRepository.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/2/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

final class CustomerRepository: ObservableObject {
  @Published private(set) var customers: [Customer] = []

  private let db = Firestore.firestore()
  private let path = "users2"

  private var cancellables: Set<AnyCancellable> = []

  init() {
    load()
  }

  func add(customer: Customer) {
    _ = try? db.collection(path).addDocument(from: customer) as DocumentReference
//      .sink { completion in
//        switch completion {
//        case .finished:
//          break
//        case let .failure(error):
//          print("[Firebase] Failed to add the data: \(error)")
//        }
//      } receiveValue: { reference in
//        print("[Firebase] Document added with ID: \(reference.documentID)")
//      }
//      .store(in: &cancellables)
  }

  func add(customer: Customer, quantity: Int = 1) -> [String] {
    var ids: [String] = []
    let batch = db.batch()
    for _ in 0 ..< quantity {
      let ref = db.collection(path).document()
      _ = try? batch.setData(from: customer, forDocument: ref)
      ids.append(ref.documentID)
    }
    batch.commit() as Void

    return ids
  }

  func remove(customer: Customer) {
    guard let id = customer.id else { return }
    db.collection(path).document(id).delete() as Void
//      .sink { completion in
//        switch completion {
//        case .finished:
//          break
//        case let .failure(error):
//          print("[Firebase] Failed to remove the data: \(error)")
//        }
//      } receiveValue: { _ in }
//      .store(in: &cancellables)
  }

  func remove(customers: [Customer]) {
    let batch = db.batch()
    customers.forEach { customer in
      guard let id = customer.id else { return }
      let ref = db.collection(path).document(id)
      batch.deleteDocument(ref)
    }
    batch.commit() as Void
  }

  func remove(ids: [String]) {
    let batch = db.batch()
    ids.forEach { id in
      let ref = db.collection(path).document(id)
      batch.deleteDocument(ref)
    }
    batch.commit() as Void
  }

  func set(customer: Customer) {
    guard let id = customer.id else { return }
    try? db.collection(path).document(id).setData(from: customer) as Void
//      .sink { completion in
//        switch completion {
//        case .finished:
//          break
//        case let .failure(error):
//          print("[Firebase] Failed to update the data: \(error)")
//        }
//      } receiveValue: { _ in }
//      .store(in: &cancellables)
  }

  func update(
    id: String,
    fields: [AnyHashable: Any],
    _ completion: ((Bool) -> Void)? = nil
  ) {
    db.collection(path).document(id).updateData(fields)
      .sink { _completion in
        switch _completion {
        case .finished:
          completion?(true)
        case let .failure(error):
          completion?(false)
          print("[Firebase] Failed to update the data: \(error)")
        }
      } receiveValue: { _ in }
      .store(in: &cancellables)
  }

  func load() {
    db.collection(path).order(by: "updatedAt", descending: true)
      .publisher(as: Customer.self)
      .replaceError(with: [])
      .assign(to: \.customers, on: self)
      .store(in: &cancellables)
  }
}
