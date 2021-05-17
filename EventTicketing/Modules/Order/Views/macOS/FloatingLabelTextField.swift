//
//  FloatingLabelTextFieldView.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/4/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Combine
import SwiftUI

struct FloatingLabelTextField: View {
  typealias TextProperties = FloatingLabelTextFieldModel.TextProperties

  private var placeholder: TextProperties {
    // title
    switch model.valid {
    case .indeterminate:
      return TextProperties(
        color: .init(.placeholderText),
        fontSize: ScaledMetric<CGFloat>(wrappedValue: 12, relativeTo: .caption),
        fontWeight: .bold
      )
    case .success:
      return TextProperties(
        color: model.selected ? .green : .init(.placeholderText),
        fontSize: ScaledMetric<CGFloat>(wrappedValue: 12, relativeTo: .caption),
        fontWeight: .bold
      )
    case .failure:
      return TextProperties(
        color: model.selected ? .red : .init(.placeholderText),
        fontSize: ScaledMetric<CGFloat>(wrappedValue: 12, relativeTo: .caption),
        fontWeight: .bold
      )
    }
  }

  private var title: String
  @Binding private var text: String
  private var onEditingChanged: (Bool) -> Void
  private var onCommit: () -> Void

  @StateObject private var model: FloatingLabelTextFieldModel

  init<S>(
    _ title: S,
    text: Binding<String>,
    validator: AnyPublisher<Validation, Never>? = nil,
    onEditingChanged: @escaping (Bool) -> Void = { _ in },
    onCommit: @escaping () -> Void = {}
  ) where S: StringProtocol {
    self.title = title as! String
    _text = text
    self.onEditingChanged = onEditingChanged
    self.onCommit = onCommit
    let model = FloatingLabelTextFieldModel(validator ?? Empty().eraseToAnyPublisher())
    _model = StateObject(wrappedValue: model)
  }

  var body: some View {
    VStack {
      HStack {
        ZStack(alignment: .bottomLeading) {
          // title and placeholder
          Text(title)
            .animatableFont(
              size: placeholder.fontSize.wrappedValue,
              weight: placeholder.fontWeight
            )
            .lineLimit(1)
            .minimumScaleFactor(.zero) // disable truncation when text resized?
            .foregroundColor(Color.white)
            .colorMultiply(placeholder.color) // animate the color
            .offset(x: .zero, y: -model.offsetTitle)
            .animation(.easeInOut(duration: model.duration))

          TextField("", text: $text) { changed in
            DispatchQueue.main.async {
              model.selected = changed
            }
            onEditingChanged(changed)
          } onCommit: {
            onCommit()
          }
//          .font(.body)
          .foregroundColor(.init(.label))
        }

        // icon status view
        if model.valid == .indeterminate {
          EmptyView()
            .transition(.opacity)
            .animation(.easeInOut(duration: model.duration))
        } else {
          if let name = model.image.systemName {
            Image(systemName: name)
              .resizable()
              .frame(width: 14, height: 14)
              .foregroundColor(.white)
              .colorMultiply(model.image.color)
              .transition(.opacity)
              .animation(.easeInOut(duration: model.duration))
          }
        }
      }
    }
  }
}
