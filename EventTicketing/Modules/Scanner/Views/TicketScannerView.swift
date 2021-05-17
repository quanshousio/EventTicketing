//
//  CodeScannerView.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/31/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import AVFoundation
import Resolver
import SwiftUI

struct TicketScannerView: UXViewControllerRepresentable {
  @Binding var isRunning: Bool
  @Binding var customer: Customer?

  #if !os(macOS)
  func makeUIViewController(context: Context) -> CameraViewController {
    let controller = CameraViewController()
    controller.metadataObjectTypes = [.qr]
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    if isRunning {
      uiViewController.enableCaptureConnection()
    } else {
      uiViewController.disableCaptureConnection()
    }
  }
  #endif

  #if os(macOS)
  func makeNSViewController(context: Context) -> CameraViewController {
    let controller = CameraViewController()
    controller.metadataObjectTypes = [.qr]
    controller.delegate = context.coordinator
    return controller
  }

  func updateNSViewController(_ nsViewController: CameraViewController, context: Context) {
    if isRunning {
      nsViewController.enableCaptureConnection()
    } else {
      nsViewController.disableCaptureConnection()
    }
  }
  #endif

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

// MARK: - Coordinator

extension TicketScannerView {
  class Coordinator: NSObject, CameraViewControllerDelegate {
    let parent: TicketScannerView

    @Injected private var repository: CustomerRepository

    init(_ parent: TicketScannerView) {
      self.parent = parent
      super.init()
    }

    func cameraDidFindStringFromMetadataObject(
      _ cameraViewController: CameraViewController,
      string: String
    ) {
      guard parent.customer == nil else { return } // TicketDetailView is presenting

      if let customer = repository.customers.first(where: { $0.id == string }) {
        parent.customer = customer
      } else {
        parent.customer = Customer(id: nil)
      }
    }
  }
}
