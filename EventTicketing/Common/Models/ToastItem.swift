//
//  ToastItem.swift
//  EventTicketing
//
//  Created by Quan Tran on 11/3/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Foundation

enum ToastItemType {
  case indefinite
  case definite
  case success
  case error
  case warning
  case info
}

struct ToastItem: Identifiable, Equatable {
  let id = UUID()
  var message: String
  var type: ToastItemType

  static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
    lhs.id == rhs.id
  }
}
