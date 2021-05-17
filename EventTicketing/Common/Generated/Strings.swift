// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// About
  internal static let about = L10n.tr("Localizable", "about")
  /// Always-on Scanner
  internal static let alwaysOnScanner = L10n.tr("Localizable", "alwaysOnScanner")
  /// To give app permissions tap on "Change Settings" button
  internal static let askChangePermissionSettings = L10n.tr("Localizable", "askChangePermissionSettings")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// Change Settings
  internal static let changeSettings = L10n.tr("Localizable", "changeSettings")
  /// Created at
  internal static let createdAt = L10n.tr("Localizable", "createdAt")
  /// Customers
  internal static let customers = L10n.tr("Localizable", "customers")
  /// Database
  internal static let database = L10n.tr("Localizable", "database")
  /// Default Mail
  internal static let defaultMail = L10n.tr("Localizable", "defaultMail")
  /// Delete
  internal static let delete = L10n.tr("Localizable", "delete")
  /// Your device can not send mail using Mail application
  internal static let deviceCannotSendMail = L10n.tr("Localizable", "deviceCannotSendMail")
  /// Done
  internal static let done = L10n.tr("Localizable", "done")
  /// Edit
  internal static let edit = L10n.tr("Localizable", "edit")
  /// Email
  internal static let email = L10n.tr("Localizable", "email")
  /// Error
  internal static let error = L10n.tr("Localizable", "error")
  /// Extras
  internal static let extras = L10n.tr("Localizable", "extras")
  /// Fireworks
  internal static let fireworks = L10n.tr("Localizable", "fireworks")
  /// Identification
  internal static let identification = L10n.tr("Localizable", "identification")
  /// Language
  internal static let language = L10n.tr("Localizable", "language")
  /// Loading...
  internal static let loading = L10n.tr("Localizable", "loading")
  /// Name
  internal static let name = L10n.tr("Localizable", "name")
  /// Order
  internal static let order = L10n.tr("Localizable", "order")
  /// Personal Information
  internal static let personalInformation = L10n.tr("Localizable", "personalInformation")
  /// Phone
  internal static let phone = L10n.tr("Localizable", "phone")
  /// Quantity
  internal static let quantity = L10n.tr("Localizable", "quantity")
  /// Save
  internal static let save = L10n.tr("Localizable", "save")
  /// Scan Ticket
  internal static let scanner = L10n.tr("Localizable", "scanner")
  /// Search...
  internal static let search = L10n.tr("Localizable", "search")
  /// Send
  internal static let send = L10n.tr("Localizable", "send")
  /// SendGrid
  internal static let sendGrid = L10n.tr("Localizable", "sendGrid")
  /// Send ticket option
  internal static let sendOption = L10n.tr("Localizable", "sendOption")
  /// Sent
  internal static let sent = L10n.tr("Localizable", "sent")
  /// Sent at
  internal static let sentAt = L10n.tr("Localizable", "sentAt")
  /// Settings
  internal static let settings = L10n.tr("Localizable", "settings")
  /// Share
  internal static let share = L10n.tr("Localizable", "share")
  /// Success
  internal static let success = L10n.tr("Localizable", "success")
  /// Ticket
  internal static let ticket = L10n.tr("Localizable", "ticket")
  /// Updated at
  internal static let updatedAt = L10n.tr("Localizable", "updatedAt")
  /// Verification
  internal static let verification = L10n.tr("Localizable", "verification")
  /// Verified
  internal static let verified = L10n.tr("Localizable", "verified")
  /// Verified at
  internal static let verifiedAt = L10n.tr("Localizable", "verifiedAt")
  /// Verify
  internal static let verify = L10n.tr("Localizable", "verify")
  /// Verify ticket automatically
  internal static let verifyTicketAutomatically = L10n.tr("Localizable", "verifyTicketAutomatically")
  /// Version
  internal static let version = L10n.tr("Localizable", "version")

  internal enum About {
    /// @cdslthemovement - An art collective based in Hanoi, Vietnam
    internal static let cdsl = L10n.tr("Localizable", "about.cdsl")
    /// @quanshousio - doing stuffs xD
    internal static let quanshousio = L10n.tr("Localizable", "about.quanshousio")
  }

  internal enum Camera {
    /// Failed to initialize the camera session
    internal static let failedToInitialize = L10n.tr("Localizable", "camera.failedToInitialize")
    /// Failed to interrupt the camera session
    internal static let failedToInterrupt = L10n.tr("Localizable", "camera.failedToInterrupt")
    /// Failed to resume the camera session
    internal static let failedToResume = L10n.tr("Localizable", "camera.failedToResume")
  }

  internal enum SendGrid {
    /// Failed to retrieve SendGrid API key
    internal static let apiKeyNotFound = L10n.tr("Localizable", "sendGrid.apiKeyNotFound")
    /// Failed to send the ticket: %@
    internal static func sendFailed(_ p1: Any) -> String {
      return L10n.tr("Localizable", "sendGrid.sendFailed", String(describing: p1))
    }
    /// Ticket has been successfully sent
    internal static let sendSuccess = L10n.tr("Localizable", "sendGrid.sendSuccess")
  }

  internal enum Ticket {
    /// Ticket has already been verified
    internal static let alreadyVerified = L10n.tr("Localizable", "ticket.alreadyVerified")
    /// Failed to buy the ticket. Please contact the developer for more help
    internal static let buyFailed = L10n.tr("Localizable", "ticket.buyFailed")
    /// Ticket is not valid
    internal static let notValid = L10n.tr("Localizable", "ticket.notValid")
    /// Failed to save the ticket to the Photo Library: %@
    internal static func saveFailed(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ticket.saveFailed", String(describing: p1))
    }
    /// Ticket has been saved to the Photo Library
    internal static let saveSuccess = L10n.tr("Localizable", "ticket.saveSuccess")
    /// Failed to verify the ticket. Please try again
    internal static let verifyFailed = L10n.tr("Localizable", "ticket.verifyFailed")
    /// Ticket has been successfully verified
    internal static let verifySuccess = L10n.tr("Localizable", "ticket.verifySuccess")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
