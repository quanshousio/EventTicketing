//
//  UserSettings.swift
//  EventTicketing
//
//  Created by Quan Tran on 11/11/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Foundation

enum UserSettings {
  static let sendOption = "sendOption"
  static let verifyTicketAutomatically = "verifyTicketAutomatically"
  static let alwaysOnScanner = "alwaysOnScanner"
}

enum NavigationItem: Int {
  case customers = 0
  case order = 1
  case scanner = 2
  case settings = 3
}

enum SendOption: String, CaseIterable, Identifiable, Hashable, Codable {
  case defaultMail
  case sendGrid

  var id: SendOption { self }

  var localized: String {
    switch self {
    case .defaultMail:
      return L10n.defaultMail
    case .sendGrid:
      return L10n.sendGrid
    }
  }
}
