//
//  FireworksView.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/13/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//
//  https://medium.com/flawless-app-stories/fireworks-a-visual-particles-editor-for-swift-618e76347798

import SwiftUI

struct FireworksView: UXViewControllerRepresentable {
  #if !os(macOS)
  func makeUIViewController(context: Context) -> FireworksViewController {
    .init()
  }

  func updateUIViewController(_ uiViewController: FireworksViewController, context: Context) {}
  #endif

  #if os(macOS)
  func makeNSViewController(context: Context) -> FireworksViewController {
    .init()
  }

  func updateNSViewController(_ nsViewController: FireworksViewController, context: Context) {}
  #endif
}

class FireworksViewController: UXViewController {
  let emitter = CAEmitterLayer()
  let colors: [UXColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow]

  override func viewDidLoad() {
    super.viewDidLoad()

    let particlesLayer = CAEmitterLayer()
    particlesLayer.needsDisplayOnBoundsChange = true

    #if !os(macOS)
    particlesLayer.frame = UIScreen.main.bounds
    view.layer.addSublayer(particlesLayer)
    view.layer.masksToBounds = true
    #else
    particlesLayer.frame = NSScreen.main!.frame
    view.layer = particlesLayer
    view.layer?.masksToBounds = true
    #endif

    particlesLayer.backgroundColor = UXColor.black.cgColor
    particlesLayer.emitterShape = .point
    particlesLayer.emitterPosition = CGPoint(
      x: view.frame.size.width / 2.0,
      y: view.frame.size.height
    )
    particlesLayer.emitterSize = .zero
    particlesLayer.emitterMode = .outline
    particlesLayer.renderMode = .additive

    let parent = CAEmitterCell()
    parent.name = "Parent"
    parent.birthRate = 2.5
    parent.lifetime = 2.5
    parent.velocity = 300.0
    parent.velocityRange = 100.0
    parent.yAcceleration = -100.0
    parent.emissionLongitude = -90.0 * (.pi / 180.0)
    parent.emissionRange = 45.0 * (.pi / 180.0)
    parent.scale = 0.0
    parent.color = UXColor.white.cgColor
    parent.redRange = 1.0
    parent.greenRange = 1.0
    parent.blueRange = 1.0

    let trail = CAEmitterCell()
    trail.contents = Asset.spark.image.cgImage
    trail.name = "Trail"
    trail.birthRate = 45.0
    trail.lifetime = 0.5
    trail.beginTime = 0.01
    trail.duration = 1.7
    trail.velocity = 80.0
    trail.velocityRange = 100.0
    trail.xAcceleration = 100.0
    trail.yAcceleration = 350.0
    trail.emissionLongitude = -360.0 * (.pi / 180.0)
    trail.emissionRange = 22.5 * (.pi / 180.0)
    trail.scale = 0.5
    trail.scaleSpeed = 0.13
    trail.alphaSpeed = -0.7
    trail.color = UXColor.white.cgColor

    let firework = CAEmitterCell()
    firework.contents = Asset.spark.image.cgImage
    firework.name = "Firework"
    firework.birthRate = 20000.0
    firework.lifetime = 15.0
    firework.beginTime = 1.6
    firework.duration = 0.1
    firework.velocity = 190.0
    firework.yAcceleration = 80.0
    firework.emissionRange = 360.0 * (.pi / 180.0)
    firework.spin = 114.6 * (.pi / 180.0)
    firework.scale = 0.1
    firework.scaleSpeed = 0.09
    firework.alphaSpeed = -1.0
    firework.color = UXColor.white.cgColor

    parent.emitterCells = [trail, firework]
    particlesLayer.emitterCells = [parent]
  }
}
