//
//  ConfettiView.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/14/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//
//  https://nshipster.com/caemitterlayer/
//  https://bryce.co/recreating-imessage-confetti/

import SwiftUI

struct ConfettiView: UXViewRepresentable {
  @Binding var isPresented: Bool

  #if !os(macOS)
  func makeUIView(context: Context) -> QTConfettiView {
    AppDelegate.orientationLock = UIDevice.current.orientation.isPortrait ? .portrait : .landscape

    let confettiView = QTConfettiView()
    confettiView.frame = UIScreen.main.bounds

    let cells: [QTConfettiView.Cell] = [
      .init(content: .shape(.rectangle, .cdsl)),
      .init(content: .shape(.rectangle, UIColor.systemBackground.inverseColor())),
      .init(content: .shape(.plus, .cdsl)),
      .init(content: .shape(.plus, UIColor.systemBackground.inverseColor())),
    ]

    confettiView.emit(with: cells) {
      isPresented = false
      AppDelegate.orientationLock = .all
    }

    return confettiView
  }

  func updateUIView(_ uiView: QTConfettiView, context: Context) {}
  #endif

  #if os(macOS)
  func makeNSView(context: Context) -> QTConfettiView {
    let confettiView = QTConfettiView()
    confettiView.frame = NSScreen.main!.frame

    let cells: [QTConfettiView.Cell] = [
      .init(content: .shape(.rectangle, .cdsl)),
      .init(content: .shape(.rectangle, NSColor.systemBackground.inverseColor())),
      .init(content: .shape(.plus, .cdsl)),
      .init(content: .shape(.plus, NSColor.systemBackground.inverseColor())),
    ]

    confettiView.emit(with: cells) {
      isPresented = false
    }

    return confettiView
  }

  func updateNSView(_ nsView: QTConfettiView, context: Context) {}
  #endif
}

final class QTConfettiView: UXView {
  private let kAnimationLayerKey = "com.quanshousio.animationLayer"
  private var completion: (() -> Void)?

  init() {
    super.init(frame: .zero)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    #if !os(macOS)
    isUserInteractionEnabled = false
    #endif
  }

  func emit(
    with cells: [Cell],
    for duration: TimeInterval = 3.0,
    _ completion: (() -> Void)? = nil
  ) {
    let layer = EmitterLayer()
    layer.configure(with: cells)
    layer.frame = bounds
    layer.needsDisplayOnBoundsChange = true
    #if !os(macOS)
    self.layer.addSublayer(layer)
    #else
    self.layer = layer
    #endif

    guard duration.isFinite else { return }

    let birthRateAnimation = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.birthRate))
    birthRateAnimation.duration = duration
    birthRateAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
    birthRateAnimation.fillMode = .forwards
    birthRateAnimation.values = [1, 0, 0]
    birthRateAnimation.keyTimes = [0, 0.5, 1]
    birthRateAnimation.isRemovedOnCompletion = false

    layer.beginTime = CACurrentMediaTime()
    layer.birthRate = 1.0

    let gravityAnimation = CAKeyframeAnimation()
    gravityAnimation.duration = duration
    gravityAnimation.keyTimes = [0.05, 0.1, 0.5, 1]
    gravityAnimation.values = [0, 100, 2000, 4000]

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      let transition = CATransition()
      transition.delegate = self
      transition.type = .fade
      transition.duration = 0.0 // 1.0
      transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
      transition.setValue(layer, forKey: self.kAnimationLayerKey)
      transition.isRemovedOnCompletion = false

      layer.add(transition, forKey: nil)

      layer.opacity = 0
    }
    layer.add(birthRateAnimation, forKey: nil)
    cells.forEach {
      layer.add(gravityAnimation, forKey: "emitterCells.\($0.id).yAcceleration")
    }
    CATransaction.commit()

    self.completion = completion
  }

  #if !os(macOS)
  override func willMove(toSuperview newSuperview: UIView?) {
    guard let superview = newSuperview else { return }
    frame = superview.bounds
    isUserInteractionEnabled = false
  }
  #endif

  /// Content to be emitted as confetti
  struct Cell: Identifiable {
    var id = UUID().uuidString
    var content: Content

    enum Content {
      enum Shape {
        case circle
        case triangle
        case square
        case plus
        case rectangle
        case custom(CGPath)
      }

      case shape(Shape, UXColor)
      case image(UXImage, UXColor?)
      case text(String)
    }
  }

  private final class EmitterLayer: CAEmitterLayer {
    func configure(with cells: [Cell]) {
      emitterCells = cells.map { cell in
        let eCell = CAEmitterCell()

        eCell.name = cell.id
//        eCell.beginTime = 0.1
        eCell.birthRate = 100.0
        eCell.lifetime = 10.0
        eCell.velocity = 300.0
        eCell.velocityRange = eCell.velocity / 2
        eCell.emissionLongitude = .pi
        eCell.emissionRange = .pi / 4
        eCell.spinRange = .pi * 8
        eCell.scaleRange = 0.25
        eCell.scale = 1.0 - eCell.scaleRange
        eCell.contents = cell.content.image.cgImage
        eCell.yAcceleration = 0.0

        if let color = cell.content.color {
          eCell.color = color.cgColor
        }

        eCell.setValue("plane", forKey: "particleType")
        eCell.setValue(Double.pi, forKey: "orientationRange")
        eCell.setValue(Double.pi / 2, forKey: "orientationLongitude")
        eCell.setValue(Double.pi / 2, forKey: "orientationLatitude")

        return eCell
      }
    }

    override func layoutSublayers() {
      super.layoutSublayers()

      emitterMode = .outline
      emitterShape = .line
      emitterSize = CGSize(width: frame.size.width, height: 1.0)
      emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
    }
  }
}

extension QTConfettiView: CAAnimationDelegate {
  func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
    if let layer = animation.value(forKey: kAnimationLayerKey) as? CALayer {
      layer.removeAllAnimations()
      layer.removeFromSuperlayer()
    }
    completion?()
  }
}

private extension QTConfettiView.Cell.Content.Shape {
  func path(in rect: CGRect) -> CGPath {
    switch self {
    case .circle:
      return CGPath(ellipseIn: rect, transform: nil)
    case .triangle:
      let path = CGMutablePath()
      path.addLines(between: [
        CGPoint(x: rect.midX, y: 0),
        CGPoint(x: rect.maxX, y: rect.maxY),
        CGPoint(x: rect.minX, y: rect.maxY),
        CGPoint(x: rect.midX, y: 0),
      ])

      return path
    case .square:
      return CGPath(rect: rect, transform: nil)
    case .plus:
      let path = CGMutablePath()
      let width: CGFloat = rect.size.width.squareRoot()
      let horizontal = CGRect(x: 0, y: rect.midY - width / 2, width: rect.height, height: width)
      let vertical = CGRect(x: rect.midX - width / 2, y: 0, width: width, height: rect.height)
      path.addRects([horizontal, vertical])

      return path
    case .rectangle:
      return CGPath(
        rect: rect.divided(atDistance: rect.width / 2, from: .minXEdge).slice,
        transform: nil
      )
    case let .custom(path):
      return path
    }
  }

  func image(with color: UXColor) -> UXImage {
    #if !os(macOS)
    let rect = CGRect(origin: .zero, size: CGSize(width: 5.0, height: 5.0))
    return UIGraphicsImageRenderer(size: rect.size).image { context in
      context.cgContext.setFillColor(color.cgColor)
      context.cgContext.addPath(path(in: rect))
      context.cgContext.fillPath()
    }
    #else
    return NSImage()
    #endif
  }
}

private extension QTConfettiView.Cell.Content {
  var color: UXColor? {
    switch self {
    case let .image(_, color?), let .shape(_, color):
      return color
    default:
      return nil
    }
  }

  var image: UXImage {
    switch self {
    case let .shape(shape, _):
      return shape.image(with: .white)
    case let .image(image, _):
      return image
    case let .text(string):
      let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: UXFont.systemFont(ofSize: 12.0),
        .foregroundColor: UXColor.systemBackground.inverseColor(),
      ]
      return NSAttributedString(string: "\(string)", attributes: defaultAttributes).image()
    }
  }
}

private extension NSAttributedString {
  func image() -> UXImage {
    #if !os(macOS)
    return UIGraphicsImageRenderer(size: size()).image { _ in
      self.draw(at: .zero)
    }
    #else
    return NSImage()
    #endif
  }
}
