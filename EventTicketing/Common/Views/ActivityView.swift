//
//  ActivityViewController.swift
//  EventTicketing
//
//  Created by Quan Tran on 5/26/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct ActivityView: UXViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode

  var activityItems: [Any]
  
  #if !os(macOS)
  var applicationActivities: [UIActivity]?
  var excludedActivityTypes: [UIActivity.ActivityType]?
  var onComplete: (((Result<(types: UIActivity.ActivityType, items: [Any]?), Error>)?) -> Void)?
  #endif

  #if !os(macOS)
  func makeUIViewController(context: Context) -> UIActivityViewController {
    .init(activityItems: activityItems, applicationActivities: applicationActivities)
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    uiViewController.excludedActivityTypes = excludedActivityTypes

    uiViewController.completionWithItemsHandler = { activity, success, items, error in
      presentationMode.wrappedValue.dismiss()
      if let error = error {
        onComplete?(.failure(error))
      } else if let activity = activity, success {
        onComplete?(.success((activity, items)))
      } else if !success {
        onComplete?(nil)
      } else {
        assertionFailure()
      }
    }
  }
  #endif
  
  #if os(macOS)
  func makeNSViewController(context: Context) -> NSViewController {
    let vc = NSViewController()
    vc.view = NSView()
    
    let picker = NSSharingServicePicker(items: activityItems)
    picker.delegate = context.coordinator
    
    DispatchQueue.main.async {
      picker.show(relativeTo: vc.view.bounds, of: vc.view, preferredEdge: .minY)
    }
    
    return vc
  }
  
  func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
  #endif
  
  #if os(macOS)
  func makeCoordinator() -> Coordinator {
    Coordinator(self, presentationMode)
  }
  
  class Coordinator: NSObject, NSSharingServicePickerDelegate {
    let parent: ActivityView
    let presentationMode: Binding<PresentationMode>
    
    init(_ parent: ActivityView, _ presentationMode: Binding<PresentationMode>) {
      self.parent = parent
      self.presentationMode = presentationMode
      super.init()
    }
    
    func sharingServicePicker(
      _ sharingServicePicker: NSSharingServicePicker,
      didChoose service: NSSharingService?
    ) {
      sharingServicePicker.delegate = nil
      presentationMode.wrappedValue.dismiss()
    }
  }
  #endif
}
