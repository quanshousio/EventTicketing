//
//  SaveButton.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/19/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Photos
import SwiftUI
import ToastUI

struct SaveButton: View {
  let iconOnly: Bool
  let images: [UXImage]

  @State private var alertItem: AlertItem?
  @State private var toastItem: ToastItem?

  var body: some View {
    Button {
      save()
    } label: {
      if iconOnly {
        Label(L10n.save, systemImage: "square.and.arrow.down").labelStyle(IconOnlyLabelStyle())
      } else {
        Label(L10n.save, systemImage: "square.and.arrow.down")
      }
    }
    .toast(item: $toastItem, dismissAfter: 1.5) { item in
      switch item.type {
      case .success:
        ToastView(item.message)
          .toastViewStyle(SuccessToastViewStyle())
      case .error:
        ToastView(item.message)
          .toastViewStyle(ErrorToastViewStyle())
      default:
        EmptyView()
      }
    }
    .alert(item: $alertItem) { item in
      if let primaryButton = item.primaryButton, let secondaryButton = item.secondaryButton {
        return Alert(
          title: item.title,
          message: item.message,
          primaryButton: primaryButton,
          secondaryButton: secondaryButton
        )
      } else {
        return Alert(title: item.title, message: item.message, dismissButton: item.dismissButton)
      }
    }
  }

  private func save() {
    PHPhotoLibrary.requestAuthorization { [self] status in
      DispatchQueue.main.async {
        if status == .authorized {
          PHPhotoLibrary.shared().performChanges {
            images.forEach { image in
              PHAssetCreationRequest.creationRequestForAsset(from: image)
            }
          } completionHandler: { success, error in
            if let error = error {
              toastItem = ToastItem(
                message: L10n.Ticket.saveFailed(error.localizedDescription),
                type: .error
              )
            } else if success {
              toastItem = ToastItem(message: L10n.Ticket.saveSuccess, type: .success)
            }
          }
        } else {
          let usageDescription = Bundle.main
            .object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") as! String
          #if !os(macOS)
          let primaryButton = Alert.Button.default(Text(L10n.changeSettings)) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
          alertItem = AlertItem(
            title: usageDescription.text,
            message: L10n.askChangePermissionSettings.text,
            primaryButton: primaryButton
          )
          #else
          alertItem = AlertItem(
            title: usageDescription.text,
            message: L10n.askChangePermissionSettings.text
          )
          #endif
        }
      }
    }
  }
}
