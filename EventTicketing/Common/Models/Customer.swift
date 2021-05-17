//
//  Customer.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Cache
import Combine
import EFQRCode
import FirebaseFirestore
import FirebaseFirestoreSwift
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

struct Customer: Codable, Identifiable {
  @DocumentID var id: String?
  @ServerTimestamp var createdAt: Timestamp?
  @ServerTimestamp var updatedAt: Timestamp?
  var name: String = ""
  var phone: String = ""
  var email: String = ""
  var verified: Bool = false
  var verifiedAt: Timestamp?
  var sent: Int = -1
  var sentAt: Timestamp?
}

extension Customer: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Customer {
  func ticketImage() -> AnyPublisher<UXImage, Never> {
    Future<UXImage, Never> { promise in
      guard let id = id else {
        promise(.success(Asset.ticketPlaceholder.image))
        return
      }
      if let image = try? AppDelegate.imageCache.object(forKey: id) {
        promise(.success(image))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        #if !os(macOS)
        let watermark = Asset.cdslWithBg.image.cgImage
        #else
        let watermark = Asset.cdslWithBg.image.cgImage(
          forProposedRect: nil,
          context: nil,
          hints: nil
        )
        #endif
        if let cgQrCode = EFQRCode.generate(
          for: id,
          size: EFIntSize(width: 800, height: 800),
          backgroundColor: UXColor.white.cgColor,
          foregroundColor: UXColor.black.cgColor,
          watermark: watermark
        ) {
          #if !os(macOS)
          let image = UIImage(cgImage: cgQrCode)
          #else
          let image = NSImage(cgImage: cgQrCode, size: NSSize(width: 800, height: 800))
          #endif
          try? AppDelegate.imageCache.setObject(image, forKey: id)
          promise(.success(image))
        } else {
          promise(.success(Asset.ticketPlaceholder.image))
        }
      }
    }
    .receive(on: RunLoop.main)
    .eraseToAnyPublisher()
  }
}
