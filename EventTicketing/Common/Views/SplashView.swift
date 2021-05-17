//
//  SplashView.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/15/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//
//  https://github.com/callumboddy/CBZSplashView

import SwiftUI

struct SplashView: UXViewRepresentable {
  @Binding var isPresented: Bool

  #if !os(macOS)
  func makeUIView(context: Context) -> VectorSplashView {
    splashView()
  }

  func updateUIView(_ uiView: VectorSplashView, context: Context) {}
  #endif
  
  #if os(macOS)
  func makeNSView(context: Context) -> VectorSplashView {
    splashView()
  }

  func updateNSView(_ nsView: VectorSplashView, context: Context) {}
  #endif
  
  private func splashView() -> VectorSplashView {
    let splashView = VectorSplashView(
      bezierPath: SplashView.cdslBezierPath(),
      logoColor: .black,
      backgroundColor: .cdsl
    )
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      splashView.startAnimation {
        isPresented = false
      }
    }
    
    return splashView
  }
}

class VectorSplashView: UXView {
  private var shapeLayer: CAShapeLayer!
  private var animation: CAAnimation!
  private var backgroundViewColor: UXColor!
  private var completion: (() -> Void)?

  init(bezierPath: UXBezierPath, logoColor: UXColor = .white, backgroundColor: UXColor = .black) {
    #if !os(macOS)
    super.init(frame: UIScreen.main.bounds)
    #else
    super.init(frame: NSScreen.main!.frame)
    #endif

    backgroundViewColor = backgroundColor

    shapeLayer = createShapeLayer(with: bezierPath)
    #if !os(macOS)
    layer.addSublayer(shapeLayer)
    #else
    layer = shapeLayer
    #endif

    let scale = CAKeyframeAnimation()
    scale.keyPath = "transform.scale"
    scale.values = [1, 0.9, 350]
    scale.keyTimes = [0, 0.222, 1]
    scale.timingFunctions = [
      CAMediaTimingFunction(name: .easeOut),
      CAMediaTimingFunction(name: .easeInEaseOut),
    ]

    let bgColor = CAKeyframeAnimation()
    bgColor.keyPath = "backgroundColor"
    bgColor.values = [logoColor.cgColor, UXColor.clear.cgColor]
    bgColor.keyTimes = [0.2, 0.6]
    bgColor.timingFunctions = [
      CAMediaTimingFunction(name: .easeOut),
    ]

    let group = CAAnimationGroup()
    group.animations = [scale, bgColor]
    group.isRemovedOnCompletion = false
    group.fillMode = .forwards
    group.delegate = self
    animation = group
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func createShapeLayer(with bezier: UXBezierPath) -> CAShapeLayer {
    // Expand the shape bounds, so when it scales down a bit in the beginning, we have some padding
    let shapeBounds = bounds.insetBy(dx: -bounds.width, dy: -bounds.height)

    let mutablePath = CGMutablePath()
    mutablePath.addRect(shapeBounds, transform: .identity)

    // Move the icon to the middle
    let iconOffset = CGPoint(
      x: (bounds.width - bezier.bounds.width) / 2,
      y: (bounds.height - bezier.bounds.height) / 2
    )

    let translation = CGAffineTransform(translationX: iconOffset.x, y: iconOffset.y)
    mutablePath.addPath(bezier.cgPath, transform: translation)

    let shapeLayer = CAShapeLayer()
    shapeLayer.bounds = shapeBounds
    shapeLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    shapeLayer.path = mutablePath
    shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    shapeLayer.fillColor = backgroundViewColor.cgColor
    shapeLayer.backgroundColor = UXColor.black.cgColor

    return shapeLayer
  }

  func startAnimation(duration: TimeInterval = 1.5, _ completion: (() -> Void)? = nil) {
    animation.duration = duration
    shapeLayer.add(animation, forKey: "SplashViewAnimation")
    self.completion = completion
  }
}

extension VectorSplashView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    removeFromSuperview()
    completion?()
  }
}

#if !os(macOS)
extension View {
  func splashScreen(isPresented: Binding<Bool>) -> some View {
    ZStack {
      self
      if isPresented.wrappedValue {
        SplashView(isPresented: isPresented)
          .ignoresSafeArea()
          .onAppear {
            AppDelegate.orientationLock =
              UIDevice.current.orientation.isPortrait ? .portrait : .landscape
          }
          .onDisappear {
            AppDelegate.orientationLock = .all
          }
      }
    }
  }
}
#else
extension View {
  func splashScreen(isPresented: Binding<Bool>) -> some View {
    self
//    ZStack {
//      self
//      if isPresented.wrappedValue {
//        SplashView(isPresented: isPresented)
//          .ignoresSafeArea()
//      }
//    }
  }
}
#endif

class RasterSplashView: UXView {
  private var imageView: UXImageView!

  init(image: UXImage, backgroundColor: UXColor) {
    #if !os(macOS)
    super.init(frame: UIScreen.main.bounds)
    imageView = UIImageView()
    imageView.image = image
    imageView.frame = UIScreen.main.bounds
    imageView.contentMode = .scaleAspectFit
    imageView.center = center
    #else
    super.init(frame: NSScreen.main!.frame)
    imageView = NSImageView()
    imageView.image = image
    imageView.frame = NSScreen.main!.frame
    #endif

    addSubview(imageView)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func startAnimation(duration: TimeInterval = 1.0, _ completion: @escaping () -> Void) {
    let shrinkDuration: TimeInterval = duration * 0.3
    let growDuration: TimeInterval = duration * 0.7
    
    #if !os(macOS)
    UIView.animate(
      withDuration: shrinkDuration,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 20,
      options: .curveEaseInOut
    ) {
      let scaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      self.imageView.transform = scaleTransform
    } completion: { _ in
      UIView.animate(withDuration: growDuration) {
        let scaleTransform = CGAffineTransform(scaleX: 300, y: 300)
        self.imageView.transform = scaleTransform
        self.alpha = 0
      } completion: { _ in
        self.removeFromSuperview()
        completion()
      }
    }
    #endif
  }
}

extension SplashView {
  static func cdslBezierPath() -> UXBezierPath {
    // convert cdsl logo in vector format to bezier path using PaintCode
    // bounds: (0.0, 0.0, 160.65, 110.94)
    let bezierPath = UXBezierPath()
    bezierPath.move(to: CGPoint(x: 160.65, y: 58.69))
    bezierPath.addCurve(
      to: CGPoint(x: 148.69, y: 58.69),
      controlPoint1: CGPoint(x: 157.13, y: 58.69),
      controlPoint2: CGPoint(x: 148.99, y: 58.69)
    )
    bezierPath.addLine(to: CGPoint(x: 148.69, y: 70.76))
    bezierPath.addLine(to: CGPoint(x: 142.75, y: 70.76))
    bezierPath.addLine(to: CGPoint(x: 142.75, y: 58.69))
    bezierPath.addLine(to: CGPoint(x: 130.81, y: 58.69))
    bezierPath.addLine(to: CGPoint(x: 130.81, y: 52.7))
    bezierPath.addLine(to: CGPoint(x: 142.73, y: 52.7))
    bezierPath.addLine(to: CGPoint(x: 142.73, y: 40.68))
    bezierPath.addLine(to: CGPoint(x: 148.68, y: 40.68))
    bezierPath.addLine(to: CGPoint(x: 148.68, y: 52.69))
    bezierPath.addLine(to: CGPoint(x: 160.65, y: 52.69))
    bezierPath.addLine(to: CGPoint(x: 160.65, y: 58.69))
    bezierPath.close()

    // Bezier 2 Drawing
    let bezier2Path = UXBezierPath()
    bezier2Path.move(to: CGPoint(x: 26.2, y: 13.39))
    bezier2Path.addCurve(
      to: CGPoint(x: 17.76, y: 6.28),
      controlPoint1: CGPoint(x: 25.46, y: 8.63),
      controlPoint2: CGPoint(x: 21.94, y: 6.28)
    )
    bezier2Path.addCurve(
      to: CGPoint(x: 8.53, y: 17.4),
      controlPoint1: CGPoint(x: 10.14, y: 6.28),
      controlPoint2: CGPoint(x: 8.53, y: 12.93)
    )
    bezier2Path.addCurve(
      to: CGPoint(x: 17.76, y: 28.53),
      controlPoint1: CGPoint(x: 8.53, y: 21.88),
      controlPoint2: CGPoint(x: 10.14, y: 28.53)
    )
    bezier2Path.addCurve(
      to: CGPoint(x: 26.2, y: 21.24),
      controlPoint1: CGPoint(x: 21.65, y: 28.53),
      controlPoint2: CGPoint(x: 25.42, y: 26.45)
    )
    bezier2Path.addLine(to: CGPoint(x: 34.94, y: 21.24))
    bezier2Path.addCurve(
      to: CGPoint(x: 17.47, y: 34.81),
      controlPoint1: CGPoint(x: 33.94, y: 30.84),
      controlPoint2: CGPoint(x: 26.87, y: 34.81)
    )
    bezier2Path.addCurve(
      to: CGPoint(x: 0, y: 17.4),
      controlPoint1: CGPoint(x: 6.71, y: 34.81),
      controlPoint2: CGPoint(x: 0, y: 29.64)
    )
    bezier2Path.addCurve(
      to: CGPoint(x: 17.47, y: -0),
      controlPoint1: CGPoint(x: 0, y: 5.17),
      controlPoint2: CGPoint(x: 6.71, y: -0)
    )
    bezier2Path.addCurve(
      to: CGPoint(x: 34.85, y: 13.39),
      controlPoint1: CGPoint(x: 24.59, y: -0),
      controlPoint2: CGPoint(x: 33.65, y: 2.03)
    )
    bezier2Path.addLine(to: CGPoint(x: 26.2, y: 13.39))
    bezier2Path.close()

    // Bezier 3 Drawing
    let bezier3Path = UXBezierPath()
    bezier3Path.move(to: CGPoint(x: 44.54, y: 27.61))
    bezier3Path.addLine(to: CGPoint(x: 53.48, y: 27.61))
    bezier3Path.addCurve(
      to: CGPoint(x: 61.18, y: 17.08),
      controlPoint1: CGPoint(x: 58.78, y: 27.61),
      controlPoint2: CGPoint(x: 61.18, y: 24.05)
    )
    bezier3Path.addCurve(
      to: CGPoint(x: 52.74, y: 7.2),
      controlPoint1: CGPoint(x: 61.18, y: 10.99),
      controlPoint2: CGPoint(x: 58.86, y: 7.2)
    )
    bezier3Path.addLine(to: CGPoint(x: 44.54, y: 7.2))
    bezier3Path.addLine(to: CGPoint(x: 44.54, y: 27.61))
    bezier3Path.close()
    bezier3Path.move(to: CGPoint(x: 36.51, y: 0.92))
    bezier3Path.addLine(to: CGPoint(x: 54.93, y: 0.92))
    bezier3Path.addCurve(
      to: CGPoint(x: 69.46, y: 17.4),
      controlPoint1: CGPoint(x: 65.07, y: 0.92),
      controlPoint2: CGPoint(x: 69.46, y: 7.48)
    )
    bezier3Path.addCurve(
      to: CGPoint(x: 55.63, y: 33.89),
      controlPoint1: CGPoint(x: 69.46, y: 27.33),
      controlPoint2: CGPoint(x: 64.91, y: 33.89)
    )
    bezier3Path.addLine(to: CGPoint(x: 36.51, y: 33.89))
    bezier3Path.addLine(to: CGPoint(x: 36.51, y: 0.92))
    bezier3Path.close()

    // Bezier 4 Drawing
    let bezier4Path = UXBezierPath()
    bezier4Path.move(to: CGPoint(x: 91.77, y: 10.48))
    bezier4Path.addCurve(
      to: CGPoint(x: 84.36, y: 5.72),
      controlPoint1: CGPoint(x: 91.28, y: 6.19),
      controlPoint2: CGPoint(x: 87.59, y: 5.72)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 78.9, y: 9.6),
      controlPoint1: CGPoint(x: 81.05, y: 5.72),
      controlPoint2: CGPoint(x: 78.9, y: 7.39)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 82.29, y: 12.7),
      controlPoint1: CGPoint(x: 78.9, y: 11.36),
      controlPoint2: CGPoint(x: 80.22, y: 12.33)
    )
    bezier4Path.addLine(to: CGPoint(x: 92.35, y: 14.5))
    bezier4Path.addCurve(
      to: CGPoint(x: 101.83, y: 23.73),
      controlPoint1: CGPoint(x: 97.73, y: 15.47),
      controlPoint2: CGPoint(x: 101.83, y: 17.73)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 86.47, y: 34.81),
      controlPoint1: CGPoint(x: 101.83, y: 29.87),
      controlPoint2: CGPoint(x: 98.11, y: 34.81)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 69.83, y: 23.5),
      controlPoint1: CGPoint(x: 79.27, y: 34.81),
      controlPoint2: CGPoint(x: 69.92, y: 33.79)
    )
    bezier4Path.addLine(to: CGPoint(x: 78.86, y: 23.5))
    bezier4Path.addCurve(
      to: CGPoint(x: 86.47, y: 28.81),
      controlPoint1: CGPoint(x: 78.94, y: 28.02),
      controlPoint2: CGPoint(x: 83, y: 28.81)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 92.81, y: 24.7),
      controlPoint1: CGPoint(x: 90.24, y: 28.81),
      controlPoint2: CGPoint(x: 92.81, y: 27.56)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 87.8, y: 20.91),
      controlPoint1: CGPoint(x: 92.81, y: 22.16),
      controlPoint2: CGPoint(x: 90.99, y: 21.47)
    )
    bezier4Path.addLine(to: CGPoint(x: 80.47, y: 19.67))
    bezier4Path.addCurve(
      to: CGPoint(x: 70.37, y: 10.34),
      controlPoint1: CGPoint(x: 75.34, y: 18.79),
      controlPoint2: CGPoint(x: 70.37, y: 17.08)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 85.03, y: 0),
      controlPoint1: CGPoint(x: 70.37, y: 3),
      controlPoint2: CGPoint(x: 75.75, y: 0)
    )
    bezier4Path.addCurve(
      to: CGPoint(x: 100.67, y: 10.48),
      controlPoint1: CGPoint(x: 91.11, y: 0),
      controlPoint2: CGPoint(x: 100.13, y: 1.15)
    )
    bezier4Path.addLine(to: CGPoint(x: 91.77, y: 10.48))
    bezier4Path.close()

    // Bezier 5 Drawing
    let bezier5Path = UXBezierPath()
    bezier5Path.move(to: CGPoint(x: 103.24, y: 0.92))
    bezier5Path.addLine(to: CGPoint(x: 111.27, y: 0.92))
    bezier5Path.addLine(to: CGPoint(x: 111.27, y: 27.33))
    bezier5Path.addLine(to: CGPoint(x: 129.28, y: 27.33))
    bezier5Path.addLine(to: CGPoint(x: 129.28, y: 33.89))
    bezier5Path.addLine(to: CGPoint(x: 103.24, y: 33.89))
    bezier5Path.addLine(to: CGPoint(x: 103.24, y: 0.92))
    bezier5Path.close()

    // Bezier 6 Drawing
    let bezier6Path = UXBezierPath()
    bezier6Path.move(to: CGPoint(x: 26.2, y: 51.5))
    bezier6Path.addCurve(
      to: CGPoint(x: 17.76, y: 44.39),
      controlPoint1: CGPoint(x: 25.46, y: 46.74),
      controlPoint2: CGPoint(x: 21.94, y: 44.39)
    )
    bezier6Path.addCurve(
      to: CGPoint(x: 8.53, y: 55.51),
      controlPoint1: CGPoint(x: 10.14, y: 44.39),
      controlPoint2: CGPoint(x: 8.53, y: 51.03)
    )
    bezier6Path.addCurve(
      to: CGPoint(x: 17.76, y: 66.64),
      controlPoint1: CGPoint(x: 8.53, y: 59.99),
      controlPoint2: CGPoint(x: 10.14, y: 66.64)
    )
    bezier6Path.addCurve(
      to: CGPoint(x: 26.2, y: 59.34),
      controlPoint1: CGPoint(x: 21.65, y: 66.64),
      controlPoint2: CGPoint(x: 25.42, y: 64.56)
    )
    bezier6Path.addLine(to: CGPoint(x: 34.94, y: 59.34))
    bezier6Path.addCurve(
      to: CGPoint(x: 17.47, y: 72.92),
      controlPoint1: CGPoint(x: 33.94, y: 68.95),
      controlPoint2: CGPoint(x: 26.87, y: 72.92)
    )
    bezier6Path.addCurve(
      to: CGPoint(x: 0, y: 55.51),
      controlPoint1: CGPoint(x: 6.71, y: 72.92),
      controlPoint2: CGPoint(x: 0, y: 67.75)
    )
    bezier6Path.addCurve(
      to: CGPoint(x: 17.47, y: 38.11),
      controlPoint1: CGPoint(x: 0, y: 43.28),
      controlPoint2: CGPoint(x: 6.71, y: 38.11)
    )
    bezier6Path.addCurve(
      to: CGPoint(x: 34.85, y: 51.5),
      controlPoint1: CGPoint(x: 24.59, y: 38.11),
      controlPoint2: CGPoint(x: 33.65, y: 40.14)
    )
    bezier6Path.addLine(to: CGPoint(x: 26.2, y: 51.5))
    bezier6Path.close()

    // Bezier 7 Drawing
    let bezier7Path = UXBezierPath()
    bezier7Path.move(to: CGPoint(x: 44.54, y: 65.71))
    bezier7Path.addLine(to: CGPoint(x: 53.48, y: 65.71))
    bezier7Path.addCurve(
      to: CGPoint(x: 61.18, y: 55.19),
      controlPoint1: CGPoint(x: 58.78, y: 65.71),
      controlPoint2: CGPoint(x: 61.18, y: 62.16)
    )
    bezier7Path.addCurve(
      to: CGPoint(x: 52.74, y: 45.31),
      controlPoint1: CGPoint(x: 61.18, y: 49.09),
      controlPoint2: CGPoint(x: 58.86, y: 45.31)
    )
    bezier7Path.addLine(to: CGPoint(x: 44.54, y: 45.31))
    bezier7Path.addLine(to: CGPoint(x: 44.54, y: 65.71))
    bezier7Path.close()
    bezier7Path.move(to: CGPoint(x: 36.51, y: 39.03))
    bezier7Path.addLine(to: CGPoint(x: 54.93, y: 39.03))
    bezier7Path.addCurve(
      to: CGPoint(x: 69.46, y: 55.51),
      controlPoint1: CGPoint(x: 65.07, y: 39.03),
      controlPoint2: CGPoint(x: 69.46, y: 45.59)
    )
    bezier7Path.addCurve(
      to: CGPoint(x: 55.64, y: 71.99),
      controlPoint1: CGPoint(x: 69.46, y: 65.44),
      controlPoint2: CGPoint(x: 64.91, y: 71.99)
    )
    bezier7Path.addLine(to: CGPoint(x: 36.51, y: 71.99))
    bezier7Path.addLine(to: CGPoint(x: 36.51, y: 39.03))
    bezier7Path.close()

    // Bezier 8 Drawing
    let bezier8Path = UXBezierPath()
    bezier8Path.move(to: CGPoint(x: 91.77, y: 48.59))
    bezier8Path.addCurve(
      to: CGPoint(x: 84.36, y: 43.83),
      controlPoint1: CGPoint(x: 91.28, y: 44.29),
      controlPoint2: CGPoint(x: 87.59, y: 43.83)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 78.9, y: 47.71),
      controlPoint1: CGPoint(x: 81.05, y: 43.83),
      controlPoint2: CGPoint(x: 78.9, y: 45.49)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 82.29, y: 50.8),
      controlPoint1: CGPoint(x: 78.9, y: 49.46),
      controlPoint2: CGPoint(x: 80.22, y: 50.43)
    )
    bezier8Path.addLine(to: CGPoint(x: 92.35, y: 52.6))
    bezier8Path.addCurve(
      to: CGPoint(x: 101.83, y: 61.84),
      controlPoint1: CGPoint(x: 97.73, y: 53.57),
      controlPoint2: CGPoint(x: 101.83, y: 55.84)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 86.47, y: 72.92),
      controlPoint1: CGPoint(x: 101.83, y: 67.98),
      controlPoint2: CGPoint(x: 98.11, y: 72.92)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 69.83, y: 61.61),
      controlPoint1: CGPoint(x: 79.27, y: 72.92),
      controlPoint2: CGPoint(x: 69.92, y: 71.9)
    )
    bezier8Path.addLine(to: CGPoint(x: 78.86, y: 61.61))
    bezier8Path.addCurve(
      to: CGPoint(x: 86.47, y: 66.91),
      controlPoint1: CGPoint(x: 78.94, y: 66.13),
      controlPoint2: CGPoint(x: 83, y: 66.91)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 92.81, y: 62.81),
      controlPoint1: CGPoint(x: 90.24, y: 66.91),
      controlPoint2: CGPoint(x: 92.81, y: 65.67)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 87.8, y: 59.02),
      controlPoint1: CGPoint(x: 92.81, y: 60.27),
      controlPoint2: CGPoint(x: 90.99, y: 59.57)
    )
    bezier8Path.addLine(to: CGPoint(x: 80.47, y: 57.77))
    bezier8Path.addCurve(
      to: CGPoint(x: 70.37, y: 48.45),
      controlPoint1: CGPoint(x: 75.34, y: 56.9),
      controlPoint2: CGPoint(x: 70.37, y: 55.19)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 85.03, y: 38.11),
      controlPoint1: CGPoint(x: 70.37, y: 41.11),
      controlPoint2: CGPoint(x: 75.75, y: 38.11)
    )
    bezier8Path.addCurve(
      to: CGPoint(x: 100.67, y: 48.59),
      controlPoint1: CGPoint(x: 91.11, y: 38.11),
      controlPoint2: CGPoint(x: 100.13, y: 39.26)
    )
    bezier8Path.addLine(to: CGPoint(x: 91.77, y: 48.59))
    bezier8Path.close()

    // Bezier 9 Drawing
    let bezier9Path = UXBezierPath()
    bezier9Path.move(to: CGPoint(x: 103.24, y: 39.03))
    bezier9Path.addLine(to: CGPoint(x: 111.27, y: 39.03))
    bezier9Path.addLine(to: CGPoint(x: 111.27, y: 65.44))
    bezier9Path.addLine(to: CGPoint(x: 129.28, y: 65.44))
    bezier9Path.addLine(to: CGPoint(x: 129.28, y: 71.99))
    bezier9Path.addLine(to: CGPoint(x: 103.24, y: 71.99))
    bezier9Path.addLine(to: CGPoint(x: 103.24, y: 39.03))
    bezier9Path.close()

    // Bezier 10 Drawing
    let bezier10Path = UXBezierPath()
    bezier10Path.move(to: CGPoint(x: 26.2, y: 89.52))
    bezier10Path.addCurve(
      to: CGPoint(x: 17.76, y: 82.41),
      controlPoint1: CGPoint(x: 25.46, y: 84.76),
      controlPoint2: CGPoint(x: 21.94, y: 82.41)
    )
    bezier10Path.addCurve(
      to: CGPoint(x: 8.53, y: 93.54),
      controlPoint1: CGPoint(x: 10.14, y: 82.41),
      controlPoint2: CGPoint(x: 8.53, y: 89.06)
    )
    bezier10Path.addCurve(
      to: CGPoint(x: 17.76, y: 104.66),
      controlPoint1: CGPoint(x: 8.53, y: 98.01),
      controlPoint2: CGPoint(x: 10.14, y: 104.66)
    )
    bezier10Path.addCurve(
      to: CGPoint(x: 26.2, y: 97.37),
      controlPoint1: CGPoint(x: 21.65, y: 104.66),
      controlPoint2: CGPoint(x: 25.42, y: 102.59)
    )
    bezier10Path.addLine(to: CGPoint(x: 34.94, y: 97.37))
    bezier10Path.addCurve(
      to: CGPoint(x: 17.47, y: 110.94),
      controlPoint1: CGPoint(x: 33.94, y: 106.97),
      controlPoint2: CGPoint(x: 26.87, y: 110.94)
    )
    bezier10Path.addCurve(
      to: CGPoint(x: 0, y: 93.54),
      controlPoint1: CGPoint(x: 6.71, y: 110.94),
      controlPoint2: CGPoint(x: 0, y: 105.77)
    )
    bezier10Path.addCurve(
      to: CGPoint(x: 17.47, y: 76.13),
      controlPoint1: CGPoint(x: 0, y: 81.3),
      controlPoint2: CGPoint(x: 6.71, y: 76.13)
    )
    bezier10Path.addCurve(
      to: CGPoint(x: 34.85, y: 89.52),
      controlPoint1: CGPoint(x: 24.59, y: 76.13),
      controlPoint2: CGPoint(x: 33.65, y: 78.16)
    )
    bezier10Path.addLine(to: CGPoint(x: 26.2, y: 89.52))
    bezier10Path.close()

    // Bezier 11 Drawing
    let bezier11Path = UXBezierPath()
    bezier11Path.move(to: CGPoint(x: 44.54, y: 103.74))
    bezier11Path.addLine(to: CGPoint(x: 53.48, y: 103.74))
    bezier11Path.addCurve(
      to: CGPoint(x: 61.18, y: 93.21),
      controlPoint1: CGPoint(x: 58.78, y: 103.74),
      controlPoint2: CGPoint(x: 61.18, y: 100.18)
    )
    bezier11Path.addCurve(
      to: CGPoint(x: 52.74, y: 83.33),
      controlPoint1: CGPoint(x: 61.18, y: 87.12),
      controlPoint2: CGPoint(x: 58.86, y: 83.33)
    )
    bezier11Path.addLine(to: CGPoint(x: 44.54, y: 83.33))
    bezier11Path.addLine(to: CGPoint(x: 44.54, y: 103.74))
    bezier11Path.close()
    bezier11Path.move(to: CGPoint(x: 36.51, y: 77.06))
    bezier11Path.addLine(to: CGPoint(x: 54.93, y: 77.06))
    bezier11Path.addCurve(
      to: CGPoint(x: 69.46, y: 93.54),
      controlPoint1: CGPoint(x: 65.07, y: 77.06),
      controlPoint2: CGPoint(x: 69.46, y: 83.61)
    )
    bezier11Path.addCurve(
      to: CGPoint(x: 55.64, y: 110.02),
      controlPoint1: CGPoint(x: 69.46, y: 103.46),
      controlPoint2: CGPoint(x: 64.91, y: 110.02)
    )
    bezier11Path.addLine(to: CGPoint(x: 36.51, y: 110.02))
    bezier11Path.addLine(to: CGPoint(x: 36.51, y: 77.06))
    bezier11Path.close()

    // Bezier 12 Drawing
    let bezier12Path = UXBezierPath()
    bezier12Path.move(to: CGPoint(x: 91.77, y: 86.61))
    bezier12Path.addCurve(
      to: CGPoint(x: 84.36, y: 81.86),
      controlPoint1: CGPoint(x: 91.28, y: 82.32),
      controlPoint2: CGPoint(x: 87.59, y: 81.86)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 78.9, y: 85.73),
      controlPoint1: CGPoint(x: 81.05, y: 81.86),
      controlPoint2: CGPoint(x: 78.9, y: 83.52)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 82.29, y: 88.83),
      controlPoint1: CGPoint(x: 78.9, y: 87.49),
      controlPoint2: CGPoint(x: 80.22, y: 88.46)
    )
    bezier12Path.addLine(to: CGPoint(x: 92.35, y: 90.63))
    bezier12Path.addCurve(
      to: CGPoint(x: 101.83, y: 99.86),
      controlPoint1: CGPoint(x: 97.73, y: 91.6),
      controlPoint2: CGPoint(x: 101.83, y: 93.86)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 86.47, y: 110.94),
      controlPoint1: CGPoint(x: 101.83, y: 106),
      controlPoint2: CGPoint(x: 98.11, y: 110.94)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 69.83, y: 99.63),
      controlPoint1: CGPoint(x: 79.27, y: 110.94),
      controlPoint2: CGPoint(x: 69.92, y: 109.93)
    )
    bezier12Path.addLine(to: CGPoint(x: 78.86, y: 99.63))
    bezier12Path.addCurve(
      to: CGPoint(x: 86.47, y: 104.94),
      controlPoint1: CGPoint(x: 78.94, y: 104.15),
      controlPoint2: CGPoint(x: 83, y: 104.94)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 92.81, y: 100.83),
      controlPoint1: CGPoint(x: 90.24, y: 104.94),
      controlPoint2: CGPoint(x: 92.81, y: 103.69)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 87.8, y: 97.04),
      controlPoint1: CGPoint(x: 92.81, y: 98.29),
      controlPoint2: CGPoint(x: 90.99, y: 97.6)
    )
    bezier12Path.addLine(to: CGPoint(x: 80.47, y: 95.8))
    bezier12Path.addCurve(
      to: CGPoint(x: 70.37, y: 86.47),
      controlPoint1: CGPoint(x: 75.34, y: 94.92),
      controlPoint2: CGPoint(x: 70.37, y: 93.21)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 85.03, y: 76.13),
      controlPoint1: CGPoint(x: 70.37, y: 79.13),
      controlPoint2: CGPoint(x: 75.75, y: 76.13)
    )
    bezier12Path.addCurve(
      to: CGPoint(x: 100.67, y: 86.61),
      controlPoint1: CGPoint(x: 91.11, y: 76.13),
      controlPoint2: CGPoint(x: 100.13, y: 77.29)
    )
    bezier12Path.addLine(to: CGPoint(x: 91.77, y: 86.61))
    bezier12Path.close()

    // Bezier 13 Drawing
    let bezier13Path = UXBezierPath()
    bezier13Path.move(to: CGPoint(x: 103.24, y: 77.06))
    bezier13Path.addLine(to: CGPoint(x: 111.27, y: 77.06))
    bezier13Path.addLine(to: CGPoint(x: 111.27, y: 103.46))
    bezier13Path.addLine(to: CGPoint(x: 129.28, y: 103.46))
    bezier13Path.addLine(to: CGPoint(x: 129.28, y: 110.02))
    bezier13Path.addLine(to: CGPoint(x: 103.24, y: 110.02))
    bezier13Path.addLine(to: CGPoint(x: 103.24, y: 77.06))
    bezier13Path.close()

    let path = UXBezierPath()
    path.append(bezierPath)
    path.append(bezier2Path)
    path.append(bezier3Path)
    path.append(bezier4Path)
    path.append(bezier5Path)
    path.append(bezier6Path)
    path.append(bezier7Path)
    path.append(bezier8Path)
    path.append(bezier9Path)
    path.append(bezier10Path)
    path.append(bezier11Path)
    path.append(bezier12Path)
    path.append(bezier13Path)
    path.close()

    #if !os(macOS)
    return path.reversing()
    #else
    return path.reversed
    #endif
  }
}
