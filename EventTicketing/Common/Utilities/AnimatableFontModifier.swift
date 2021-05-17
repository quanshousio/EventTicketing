//
//  AnimatableFontModifier.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/23/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct AnimatableFontModifier: AnimatableModifier {
  var size: CGFloat
  var weight: Font.Weight = .regular
  var design: Font.Design = .default

  var animatableData: CGFloat {
    get { size }
    set { size = newValue }
  }

  func body(content: Content) -> some View {
    content
      .font(.system(size: size, weight: weight, design: design))
  }
}

extension View {
  func animatableFont(
    size: CGFloat,
    weight: Font.Weight = .regular,
    design: Font.Design = .default
  ) -> some View {
    modifier(AnimatableFontModifier(size: size, weight: weight, design: design))
  }
}
