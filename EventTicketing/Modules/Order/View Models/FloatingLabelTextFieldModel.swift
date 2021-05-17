//
//  FloatingLabelTextFieldModel.swift
//  EventTicketing
//
//  Created by Quan Tran on 11/11/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import SwiftUI

final class FloatingLabelTextFieldModel: ObservableObject {
  struct TextProperties {
    var color: Color
    var fontSize: ScaledMetric<CGFloat>
    var fontWeight: Font.Weight
  }

  struct DividerProperties {
    var color: Color
    var height: CGFloat
  }

  struct ImageProperties {
    var color: Color
    var systemName: String?
  }

//  @Published var placeholder: TextProperties
  @Published var divider: DividerProperties
  @Published var image: ImageProperties

  @Published var selected: Bool = false
  @Published var valid: Validation = .indeterminate

  @ScaledMetric(relativeTo: .title) var placeholderSize: CGFloat = 17
  @ScaledMetric(relativeTo: .caption) var titleSize: CGFloat = 12

  var offsetTitle: CGFloat = 28.0
  var duration: Double = 0.3

  private var cancellables: Set<AnyCancellable> = []

  init(
    //    _ text: AnyPublisher<String, Never>,
    _ validator: AnyPublisher<Validation, Never>
  ) {
//    placeholder = TextProperties(
//      color: .init(.placeholderText),
//      fontSize: .init(wrappedValue: 17, relativeTo: .body),
//      fontWeight: .regular
//    )
    divider = DividerProperties(color: .init(.placeholderText), height: 0.4)
    image = ImageProperties(color: .accentColor, systemName: "")

    validator
      .receive(on: RunLoop.main)
      .assign(to: \.valid, on: self)
      .store(in: &cancellables)

//    text
//      .receive(on: RunLoop.main)
//      .combineLatest($valid, $selected)
//      .sink { [self] string, validation, selected in
//        if string.isEmpty {
//          placeholder = TextProperties(
//            color: .init(.placeholderText),
//            fontSize: ScaledMetric<CGFloat>(wrappedValue: 17, relativeTo: .body),
//            fontWeight: .regular
//          )
//          return
//        }
//        switch validation {
//        case .indeterminate:
//          placeholder = TextProperties(
//            color: .init(.placeholderText),
//            fontSize: ScaledMetric<CGFloat>(wrappedValue: 12, relativeTo: .caption),
//            fontWeight: .bold
//          )
//        case .success:
//          placeholder = TextProperties(
//            color: selected ? .green : .init(.placeholderText),
//            fontSize: ScaledMetric<CGFloat>(wrappedValue: 12, relativeTo: .caption),
//            fontWeight: .bold
//          )
//        case .failure:
//          placeholder = TextProperties(
//            color: selected ? .red : .init(.placeholderText),
//            fontSize: ScaledMetric<CGFloat>(wrappedValue: 12, relativeTo: .caption),
//            fontWeight: .bold
//          )
//        }
//      }
//      .store(in: &cancellables)

    $valid
      .receive(on: RunLoop.main)
      .combineLatest($selected)
      .sink { [weak self] validation, selected in
        switch validation {
        case .indeterminate:
          self?.divider = DividerProperties(
            color: .init(.placeholderText),
            height: selected ? 1.0 : 0.4
          )
          self?.image = ImageProperties(color: .accentColor)
        case .success:
          self?.divider = DividerProperties(color: .green, height: selected ? 1.0 : 0.4)
          self?.image = ImageProperties(color: .green, systemName: "checkmark")
        case .failure:
          self?.divider = DividerProperties(color: .red, height: selected ? 1.0 : 0.4)
          self?.image = ImageProperties(color: .red, systemName: "xmark")
        }
      }
      .store(in: &cancellables)
  }
}
