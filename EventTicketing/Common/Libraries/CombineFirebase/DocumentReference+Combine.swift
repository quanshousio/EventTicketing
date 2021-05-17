//
//  DocumentReference+Combine.swift
//  CombineFirestore
//
//  Created by Kumar Shivang on 21/02/20.
//  Copyright © 2020 Kumar Shivang. All rights reserved.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

public extension DocumentReference {
  func setData(_ documentData: [String: Any]) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.setData(documentData) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func setData<T: Encodable>(
    from data: T,
    encoder: Firestore.Encoder = Firestore.Encoder()
  ) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      do {
        try self?.setData(from: data, encoder: encoder) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }

  func setData(_ documentData: [String: Any], merge: Bool) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.setData(documentData, merge: merge) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func setData<T: Encodable>(
    from data: T,
    merge: Bool,
    encoder: Firestore.Encoder = Firestore.Encoder()
  ) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      do {
        try self?.setData(from: data, merge: merge, encoder: encoder) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }

  func updateData(_ fields: [AnyHashable: Any]) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.updateData(fields) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func delete() -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.delete { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  internal struct Publisher: Combine.Publisher {
    typealias Output = DocumentSnapshot
    typealias Failure = Error

    private let documentReference: DocumentReference
    private let includeMetadataChanges: Bool

    init(_ documentReference: DocumentReference, includeMetadataChanges: Bool) {
      self.documentReference = documentReference
      self.includeMetadataChanges = includeMetadataChanges
    }

    func receive<S>(subscriber: S)
      where S: Subscriber, Publisher.Failure == S.Failure, Publisher.Output == S.Input
    {
      let subscription = DocumentSnapshot.Subscription(
        subscriber: subscriber,
        documentReference: documentReference,
        includeMetadataChanges: includeMetadataChanges
      )
      subscriber.receive(subscription: subscription)
    }
  }

  func publisher(includeMetadataChanges: Bool = true) -> AnyPublisher<DocumentSnapshot, Error> {
    Publisher(self, includeMetadataChanges: includeMetadataChanges)
      .eraseToAnyPublisher()
  }

  func publisher<D: Decodable>(
    includeMetadataChanges: Bool = true,
    as type: D.Type,
    documentSnapshotMapper: @escaping (DocumentSnapshot) throws -> D? = DocumentSnapshot
      .defaultMapper()
  ) -> AnyPublisher<D?, Error> {
    publisher(includeMetadataChanges: includeMetadataChanges)
      .map {
        do {
          return try documentSnapshotMapper($0)
        } catch {
          print("Error mapping document snapshot for \(self.path): \(error)")
          return nil
        }
      }
      .eraseToAnyPublisher()
  }

  func getDocument(source: FirestoreSource = .default) -> AnyPublisher<DocumentSnapshot, Error> {
    Future<DocumentSnapshot, Error> { [weak self] promise in
      self?.getDocument(source: source) { snapshot, error in
        if let error = error {
          promise(.failure(error))
        } else if let snapshot = snapshot {
          promise(.success(snapshot))
        } else {
          promise(.failure(FirestoreError.nil))
        }
      }
    }.eraseToAnyPublisher()
  }

  func getDocument<D: Decodable>(
    source: FirestoreSource = .default,
    as type: D.Type,
    documentSnapshotMapper: @escaping (DocumentSnapshot) throws -> D? = DocumentSnapshot
      .defaultMapper()
  ) -> AnyPublisher<D?, Error> {
    getDocument(source: source)
      .map {
        do {
          return try documentSnapshotMapper($0)
        } catch {
          print("Error getting document for \(self.path): \(error)")
          return nil
        }
      }
      .eraseToAnyPublisher()
  }
}

extension DocumentSnapshot {
  fileprivate final class Subscription<SubscriberType: Subscriber>: Combine.Subscription
    where SubscriberType.Input == DocumentSnapshot, SubscriberType.Failure == Error
  {
    private var registration: ListenerRegistration?

    init(
      subscriber: SubscriberType,
      documentReference: DocumentReference,
      includeMetadataChanges: Bool
    ) {
      registration = documentReference
        .addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
          if let error = error {
            subscriber.receive(completion: .failure(error))
          } else if let snapshot = snapshot {
            _ = subscriber.receive(snapshot)
          } else {
            subscriber.receive(completion: .failure(FirestoreError.nil))
          }
        }
    }

    func request(_ demand: Subscribers.Demand) {
      // We do nothing here as we only want to send events when they occur.
      // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
      registration?.remove()
      registration = nil
    }
  }

  public static func defaultMapper<D: Decodable>() -> (DocumentSnapshot) throws -> D? {
    {
      try $0.data(as: D.self)
    }
  }
}
