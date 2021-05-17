//
//  SettingsView.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/10/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

#if !os(macOS)
struct SettingsView: View {
  @AppStorage(UserSettings.sendOption)
  private var sendOption: SendOption = .defaultMail

  @AppStorage(UserSettings.verifyTicketAutomatically)
  private var verifyTicketAutomatically: Bool = false

  @AppStorage(UserSettings.alwaysOnScanner)
  private var alwaysOnScanner: Bool = false

  private var version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
  private var build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String

  var body: some View {
    Form {
      Section(header: Text(L10n.language)) {
        Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
          HStack {
            Text(L10n.language)
            Spacer()
            if let code = Bundle.main.preferredLocalizations.first,
               let lang = Locale.current.localizedString(forLanguageCode: code)
            {
              Text(lang).foregroundColor(.init(.secondaryLabel))
            }
            Image(systemName: "link").foregroundColor(.init(UIColor.systemGray2))
          }
          .foregroundColor(.init(.label))
        }
      }

      Section(header: Text(L10n.order)) {
        Picker(L10n.sendOption, selection: $sendOption) {
          ForEach(SendOption.allCases) { option in
            Text(option.localized).tag(option)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
      }

      Section(header: Text(L10n.scanner)) {
        Toggle(L10n.alwaysOnScanner, isOn: $alwaysOnScanner)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))

        Toggle(L10n.verifyTicketAutomatically, isOn: $verifyTicketAutomatically)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .disabled(true)
      }

      Section(header: Text(L10n.about)) {
        SettingsMenuItem(title: L10n.version, description: "\(version) build \(build)")
        Link(destination: URL(string: "https://quanshousio.com")!) {
          SettingsMenuItem(title: "Quan Tran", description: L10n.About.quanshousio)
        }
        Link(destination: URL(string: "https://www.facebook.com/cdslthemovement")!) {
          SettingsMenuItem(title: "CDSL", description: L10n.About.cdsl)
        }
      }

      Section(header: Text(L10n.extras)) {
        NavigationLink(destination: FireworksView().ignoresSafeArea()) {
          SettingsMenuItem(title: L10n.fireworks, description: nil)
        }
      }
    }
    .navigationTitle(L10n.settings)
  }
}
#endif

#if os(macOS)
struct SettingsView: View {
  @AppStorage(UserSettings.sendOption)
  private var sendOption: SendOption = .defaultMail
  
  @AppStorage(UserSettings.verifyTicketAutomatically)
  private var verifyTicketAutomatically: Bool = false
  
  @AppStorage(UserSettings.alwaysOnScanner)
  private var alwaysOnScanner: Bool = false
  
  private var version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
  private var build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
  
  private var generalView: some View {
    List {
      HStack {
        Text(L10n.language)
        Spacer()
        if let code = Bundle.main.preferredLocalizations.first,
           let lang = Locale.current.localizedString(forLanguageCode: code)
        {
          Text(lang).foregroundColor(.init(.secondaryLabel))
        }
        Image(systemName: "link").foregroundColor(.init(.systemGray2))
      }
      .foregroundColor(.init(.label))
      
      HStack {
        Text(L10n.sendOption)
        Spacer()
        Picker("", selection: $sendOption) {
          ForEach(SendOption.allCases) { option in
            Text(option.localized).tag(option)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .fixedSize()
      }
      
      HStack {
        Text(L10n.alwaysOnScanner)
        Spacer()
        Toggle("", isOn: $alwaysOnScanner)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
      }
      
      HStack {
        Text(L10n.verifyTicketAutomatically)
        Spacer()
        Toggle("", isOn: $verifyTicketAutomatically)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .disabled(true)
      }
    }
  }
  
  private var aboutView: some View {
    List {
      Section(header: Text(L10n.about)) {
        SettingsMenuItem(title: L10n.version, description: "\(version) build \(build)")
        Link(destination: URL(string: "https://quanshousio.com")!) {
          SettingsMenuItem(title: "Quan Tran", description: L10n.About.quanshousio)
            .foregroundColor(.init(NSColor.cdsl))
        }
        Link(destination: URL(string: "https://www.facebook.com/cdslthemovement")!) {
          SettingsMenuItem(title: "CDSL", description: L10n.About.cdsl)
            .foregroundColor(.init(NSColor.cdsl))
        }
      }
      Section(header: Text(L10n.extras)) {
        NavigationLink(destination: FireworksView().ignoresSafeArea()) {
          SettingsMenuItem(title: L10n.fireworks, description: nil)
        }
      }
    }
  }
  
  var body: some View {
    TabView {
      generalView
        .tabItem {
          Label("General", systemImage: "gearshape.2")
        }
      aboutView
        .tabItem {
          Label(L10n.about, systemImage: "person")
        }
    }
  }
}
#endif

struct SettingsMenuItem: View {
  var title: String
  var description: String?
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title).bold().lineLimit(1)
      if let description = description {
        Text(description).lineLimit(20).font(.caption)
      }
    }
  }
}
