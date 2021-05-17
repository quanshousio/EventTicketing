//
//  CustomerRow.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/14/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct CustomerRow: View {
  @Binding var model: CustomerDetailModel

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(model.customer.name)
          .font(.headline)
          .foregroundColor(Color(.label))
        if let id = model.customer.id {
          Text(id)
            .font(.subheadline)
            .foregroundColor(Color(.secondaryLabel))
        }
      }
      .id(model.id)

      Spacer()

      if !model.customer.verified {
        Image(systemName: "checkmark.circle")
          .foregroundColor(.green)
      } else {
        Image(systemName: "xmark.circle")
          .foregroundColor(.red)
      }
    }
  }
}

struct CustomerTextView: View {
  var title: String
  @Binding var text: String
  
  @State private var selected: Bool = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if !text.isEmpty {
        Text(title).font(.subheadline).bold()
      }
      HStack {
        TextField(title, text: $text) {
          selected = $0
        }
        if !text.isEmpty && selected {
          Button {
            selected = false
            text = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .resizable()
              .frame(width: 14, height: 14)
              .foregroundColor(.init(.systemGray4))
          }
          .transition(.identity)
          .animation(nil)
        }
      }
    }
  }
}

struct CustomerValueView<T>: View {
  var title: String
  @Binding var value: T
  var formatter: Formatter
  
  @State private var selected: Bool = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title).font(.subheadline).bold()
      HStack {
        TextField(title, value: $value, formatter: formatter) {
          selected = $0
        }
      }
    }
  }
}

struct CustomerDatePickerView: View {
  var title: String
  @Binding var selection: Date
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title).font(.subheadline).bold()
      HStack {
        DatePicker(
          title,
          selection: $selection,
          displayedComponents: .date
        ).labelsHidden()
        DatePicker(
          title,
          selection: $selection,
          displayedComponents: .hourAndMinute
        ).labelsHidden()
      }
    }
  }
}
