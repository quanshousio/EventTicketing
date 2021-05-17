//
//  WriteBatch+Combine.swift
//  CombineFirebase
//
//  Created by Kumar Shivang on 23/02/20.
//  Copyright © 2020 Kumar Shivang. All rights reserved.
//

import Combine
import FirebaseFirestore

public extension WriteBatch {
  func commit() -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.commit { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }
}
