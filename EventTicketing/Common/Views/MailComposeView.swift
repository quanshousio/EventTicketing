//
//  MailComposeView.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/10/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import Foundation
import MessageUI
import SwiftUI

struct MailComposeView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentation
  @Binding var result: Result<MFMailComposeResult, Error>?

  var recipients: [String]? = nil
  var subject: String? = nil
  var messageBody: (String, Bool)? = nil
  var attachments: [(Data, String, String)]? = nil

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?

    init(
      presentation: Binding<PresentationMode>,
      result: Binding<Result<MFMailComposeResult, Error>?>
    ) {
      _presentation = presentation
      _result = result
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      guard error == nil else {
        self.result = .failure(error!)
        return
      }
      self.result = .success(result)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(presentation: presentation, result: $result)
  }

  func makeUIViewController(context: Context) -> MFMailComposeViewController {
    let viewController = MFMailComposeViewController()

    viewController.mailComposeDelegate = context.coordinator
    viewController.setToRecipients(recipients)
    if let subject = subject {
      viewController.setSubject(subject)
    }
    if let messageBody = messageBody {
      viewController.setMessageBody(messageBody.0, isHTML: messageBody.1)
    }
    if let attachments = attachments {
      attachments.forEach { attachment in
        viewController.addAttachmentData(
          attachment.0,
          mimeType: attachment.1,
          fileName: attachment.2
        )
      }
    }

    return viewController
  }

  func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
