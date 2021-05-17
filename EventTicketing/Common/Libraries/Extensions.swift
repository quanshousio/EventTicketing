//
//  Extensions.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/25/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import AVFoundation
import Combine
import FirebaseFirestore
import Foundation
import SwiftUI

#if !os(macOS)
import UIKit
internal typealias UXBezierPath = UIBezierPath
internal typealias UXColor = UIColor
internal typealias UXFont = UIFont
internal typealias UXImage = UIImage
internal typealias UXImageView = UIImageView
internal typealias UXView = UIView
internal typealias UXViewController = UIViewController
internal typealias UXViewControllerRepresentable = UIViewControllerRepresentable
internal typealias UXViewRepresentable = UIViewRepresentable
#else
import AppKit
internal typealias UXBezierPath = NSBezierPath
internal typealias UXColor = NSColor
internal typealias UXFont = NSFont
internal typealias UXImage = NSImage
internal typealias UXImageView = NSImageView
internal typealias UXView = NSView
internal typealias UXViewController = NSViewController
internal typealias UXViewControllerRepresentable = NSViewControllerRepresentable
internal typealias UXViewRepresentable = NSViewRepresentable
#endif

#if !os(macOS)
extension UIImage: Identifiable {
  public var id: UIImage { self }
}

extension UIColor {
  static var cdsl = UIColor(red: 213 / 255, green: 0 / 255, blue: 58 / 255, alpha: 1)

  func inverseColor() -> UIColor {
    var alpha: CGFloat = 1.0

    var white: CGFloat = 0.0
    if getWhite(&white, alpha: &alpha) {
      return UIColor(white: 1.0 - white, alpha: alpha)
    }

    var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
    if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
      return UIColor(
        hue: 1.0 - hue,
        saturation: 1.0 - saturation,
        brightness: 1.0 - brightness,
        alpha: alpha
      )
    }

    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
    if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
    }

    return self
  }
}

extension UITextView {
  #if targetEnvironment(macCatalyst)
  @objc(_focusRingType)
  var focusRingType: UInt { 1 } // NSFocusRingTypeNone
  #endif
}

extension UITextField {
  #if targetEnvironment(macCatalyst)
  @objc(_focusRingType)
  var focusRingType: UInt { 1 } // NSFocusRingTypeNone
  #endif
}

extension AVCaptureVideoOrientation {
  init?(deviceOrientation: UIDeviceOrientation) {
    switch deviceOrientation {
    case .portrait: self = .portrait
    case .portraitUpsideDown: self = .portraitUpsideDown
    case .landscapeLeft: self = .landscapeRight
    case .landscapeRight: self = .landscapeLeft
    default: return nil
    }
  }

  init?(interfaceOrientation: UIInterfaceOrientation) {
    switch interfaceOrientation {
    case .portrait: self = .portrait
    case .portraitUpsideDown: self = .portraitUpsideDown
    case .landscapeLeft: self = .landscapeLeft
    case .landscapeRight: self = .landscapeRight
    default: return nil
    }
  }
}
#endif

#if os(macOS)
extension NSImage: Identifiable {
  public var id: NSImage { self }
}

extension NSColor {
  static var cdsl = NSColor(red: 213 / 255, green: 0 / 255, blue: 58 / 255, alpha: 1)

  static var label = NSColor.labelColor
  static var secondaryLabel = NSColor.secondaryLabelColor
  static var placeholderText = NSColor.placeholderTextColor
  static var systemBackground = NSColor.systemGray
  static var systemGray1 = NSColor.systemGray
  static var systemGray2 = NSColor.systemGray
  static var systemGray3 = NSColor.systemGray
  static var systemGray4 = NSColor.systemGray
  static var systemGray5 = NSColor.systemGray
  static var systemGray6 = NSColor.systemGray

  func inverseColor() -> NSColor {
    self
  }
}

extension NSTextField {
  override open var focusRingType: NSFocusRingType {
    get { .none }
    set {}
  }
}

extension NSBezierPath {
  var cgPath: CGPath {
    let path = CGMutablePath()
    let points = NSPointArray.allocate(capacity: 3)

    for i in 0 ..< elementCount {
      let type = element(at: i, associatedPoints: points)
      switch type {
      case .moveTo:
        path.move(to: points[0])
      case .lineTo:
        path.addLine(to: points[0])
      case .curveTo:
        path.addCurve(to: points[2], control1: points[0], control2: points[1])
      case .closePath:
        path.closeSubpath()
      @unknown default:
        fatalError("[NSBezierPath] Unknown element type to covert to CGPath")
      }
    }
    return path
  }

  func addLine(to point: NSPoint) {
    line(to: point)
  }

  func addCurve(to point: NSPoint, controlPoint1: NSPoint, controlPoint2: NSPoint) {
    curve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
  }

  func addQuadCurve(to point: NSPoint, controlPoint: NSPoint) {
    curve(
      to: point,
      controlPoint1: NSPoint(
        x: (controlPoint.x - currentPoint.x) * (2.0 / 3.0) + currentPoint.x,
        y: (controlPoint.y - currentPoint.y) * (2.0 / 3.0) + currentPoint.y
      ),
      controlPoint2: NSPoint(
        x: (controlPoint.x - point.x) * (2.0 / 3.0) + point.x,
        y: (controlPoint.y - point.y) * (2.0 / 3.0) + point.y
      )
    )
  }
}

enum UserInterfaceSizeClass {
  case compact
  case regular
}

struct HorizontalSizeClassEnvironmentKey: EnvironmentKey {
  static let defaultValue: UserInterfaceSizeClass = .regular
}

struct VerticalSizeClassEnvironmentKey: EnvironmentKey {
  static let defaultValue: UserInterfaceSizeClass = .regular
}

extension EnvironmentValues {
  var horizontalSizeClass: UserInterfaceSizeClass {
    get { self[HorizontalSizeClassEnvironmentKey] }
    set { self[HorizontalSizeClassEnvironmentKey] = newValue }
  }

  var verticalSizeClass: UserInterfaceSizeClass {
    get { self[VerticalSizeClassEnvironmentKey] }
    set { self[VerticalSizeClassEnvironmentKey] = newValue }
  }
}
#endif

extension AnyTransition {
  static var slideReversed: AnyTransition {
    AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
  }
}

extension View {
  func Print(_ vars: Any...) -> some View {
    for v in vars { print(v) }
    return EmptyView()
  }

  func eraseToAnyView() -> AnyView {
    AnyView(self)
  }
}

extension Image {
  init(uxImage: UXImage) {
    #if !os(macOS)
    self.init(uiImage: uxImage)
    #else
    self.init(nsImage: uxImage)
    #endif
  }
}

/// https://forums.swift.org/t/does-assign-to-produce-memory-leaks/29546
extension Publisher where Failure == Never {
  func assign<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output>,
    on root: Root
  ) -> AnyCancellable {
    sink { [weak root] in
      root?[keyPath: keyPath] = $0
    }
  }
}

extension Sequence {
  func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
    compactMap { $0[keyPath: keyPath] }
  }

  func flatMap<T>(_ keyPath: KeyPath<Element, [T]>) -> [T] {
    flatMap { $0[keyPath: keyPath] }
  }
}

extension Bundle {
  var activityType: String {
    Bundle.main.infoDictionary?["NSUserActivityTypes"].flatMap { ($0 as? [String])?.first } ?? ""
  }
}

extension Optional where Wrapped == String {
  var _unwrapped: String? {
    get { self }
    set { self = newValue }
  }

  public var unwrapped: String {
    get { _unwrapped ?? "" }
    set { _unwrapped = newValue.isEmpty ? nil : newValue }
  }
}

extension Optional where Wrapped == Timestamp {
  var _unwrapped: Timestamp? {
    get { self }
    set { self = newValue }
  }

  public var unwrapped: Timestamp {
    get { _unwrapped ?? Timestamp() }
    set { _unwrapped = newValue }
  }
}

extension Binding where Value == Timestamp {
  var date: Binding<Date> {
    .init {
      wrappedValue.dateValue()
    } set: {
      wrappedValue = Timestamp(date: $0)
    }
  }
}

extension String {
  var text: Text { Text(self) }
}

extension String: Identifiable {
  public var id: String { self }
}
