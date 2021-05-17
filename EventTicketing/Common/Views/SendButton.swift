//
//  SendButton.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/19/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SendGrid
import SwiftUI
import ToastUI
#if !os(macOS)
import MessageUI
#endif

struct SendButton: View {
  @AppStorage(UserSettings.sendOption) private var sendOption: SendOption = .defaultMail

  @State private var alertItem: AlertItem?
  @State private var toastItem: ToastItem?
  @State private var presentingMailComposeView: Bool = false
  
  #if !os(macOS)
  @State private var mailComposeViewResult: Result<MFMailComposeResult, Error>?
  #endif

  let iconOnly: Bool

  let images: [UXImage]
  let name: String
  let email: String
  let sender: String = "hello@world.com"
  let subject: String = "Hello World Subject"

  private var content: String {
    """
    <!DOCTYPE html>
    <html>
    <head>
    <style> body { color: black; } </style>
    </head>
    <body>
    Hello World!
    </body>
    </html>
    """
  }

  var body: some View {
    Button {
      send()
    } label: {
      if iconOnly {
        Label(L10n.send, systemImage: "mail").labelStyle(IconOnlyLabelStyle())
      } else {
        Label(L10n.send, systemImage: "mail")
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
    .sheet(isPresented: $presentingMailComposeView) {
      #if !os(macOS)
      let attachments = images
        .compactMap { $0.jpegData(compressionQuality: 10) }
        .map { ($0, "jpeg", "ticket.jpeg") }
      MailComposeView(
        result: $mailComposeViewResult,
        recipients: [email],
        subject: subject,
        messageBody: (content, true),
        attachments: attachments
      )
      #endif
    }
  }
  
  #if os(macOS)
  private func jpegDataFrom(image: NSImage) -> Data? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else { return nil }
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [:])
    else { return nil }
    return jpegData
  }
  #endif

  private func send() {
    switch sendOption {
    case .defaultMail: sendByMail()
    case .sendGrid: sendBySendGrid()
    }
  }

  private func sendByMail() {
    #if !os(macOS)
    if MFMailComposeViewController.canSendMail() {
      presentingMailComposeView = true
    } else {
      toastItem = ToastItem(message: L10n.deviceCannotSendMail, type: .error)
    }
    #else
    toastItem = ToastItem(message: L10n.deviceCannotSendMail, type: .error)
    #endif
  }

  private func sendBySendGrid() {
    guard let sgApiKey = ProcessInfo.processInfo.environment["SG_API_KEY"] else {
      print("[SendGrid] Failed to retrieve API key, check your environment variables")
      toastItem = ToastItem(message: L10n.SendGrid.apiKeyNotFound, type: .error)
      return
    }

    let personalization = Personalization(recipients: email)
    let contents = Content.emailBody(
      plain: "ticket",
      html: content
    )
    let email = Email(
      personalizations: [personalization],
      from: .init(email: sender),
      content: contents,
      subject: subject
    )

    let attachments: [Attachment] = images.compactMap {
      #if !os(macOS)
      guard let imageData = $0.jpegData(compressionQuality: 10) else { return nil }
      #else
      guard let imageData = jpegDataFrom(image: $0) else { return nil }
      #endif
      let attachment = Attachment(
        filename: "ticket.jpeg",
        content: imageData,
        disposition: .inline,
        type: .jpeg,
        contentID: "ticket"
      )
      return attachment
    }
    email.parameters.attachments = attachments

    Session.shared.authentication = Authentication.apiKey(sgApiKey)

    do {
      try Session.shared.send(request: email) { result in
        switch result {
        case let .success(response):
          print("[SendGrid] Response code: \(response.statusCode)")
          toastItem = ToastItem(message: L10n.SendGrid.sendSuccess, type: .success)
        case let .failure(error):
          print("[SendGrid] Error: \(error)")
          toastItem = ToastItem(
            message: L10n.SendGrid.sendFailed(error.localizedDescription),
            type: .error
          )
        }
      }
    } catch {
      print("[SendGrid] Failed to send the email: \(error.localizedDescription)")
      toastItem = ToastItem(
        message: L10n.SendGrid.sendFailed(error.localizedDescription),
        type: .error
      )
    }
  }
}
