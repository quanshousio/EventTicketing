//
//  Firestore+Combine.swift
//  CombineFirebase
//
//  Created by Kumar Shivang on 23/02/20.
//  Copyright © 2020 Kumar Shivang. All rights reserved.
//

import Combine
import FirebaseFirestore

public extension Firestore {
  func disableNetwork() -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.disableNetwork { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func enableNetwork() -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.enableNetwork { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func runTransaction(_ updateBlock: @escaping (Transaction) throws -> Any?)
    -> AnyPublisher<Any?, Error>
  {
    self.runTransaction(type: Any.self, updateBlock)
  }

  func runTransaction<T>(
    type: T.Type,
    _ updateBlock: @escaping (Transaction) throws -> T?
  ) -> AnyPublisher<T?, Error> {
    Future<T?, Error> { [weak self] promise in
      self?.runTransaction { transaction, errorPointer in
        do {
          return try updateBlock(transaction)
        } catch {
          errorPointer?.pointee = error as NSError
          return nil
        }
      } completion: { object, error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(object as? T))
        }
      }
    }.eraseToAnyPublisher()
  }
}
