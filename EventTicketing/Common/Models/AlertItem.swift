//
//  AlertItem.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/19/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct AlertItem: Identifiable, Equatable {
  let id = UUID()
  var title: Text
  var message: Text?
  var primaryButton: Alert.Button?
  var secondaryButton: Alert.Button?
  var dismissButton: Alert.Button?

  static func == (lhs: AlertItem, rhs: AlertItem) -> Bool {
    lhs.id == rhs.id
  }
}
