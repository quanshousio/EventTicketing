//
//  CustomerList.swift
//  EventTicketing
//
//  Created by Quan Tran on 12/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftlySearch
import SwiftUI

struct CustomerList: View {
  @ObservedObject private var model = CustomerListModel()

  @State private var selection: Set<String> = []
  @State private var editMode: EditMode = .inactive
  @State private var searchText: String = ""
  @State private var presentingDetailView: Bool = false

  @ViewBuilder private var deleteButton: some View {
    if editMode == .active {
      Button {
        if !selection.isEmpty {
          model.remove(ids: Array(selection))
        }
      } label: {
        Label(L10n.delete, systemImage: "trash")
      }
    } else {
      EmptyView()
    }
  }

  private var editButton: some View {
    Button {
      withAnimation {
        editMode = editMode == .inactive ? .active : .inactive
        selection = []
      }
    } label: {
      editMode == .inactive ? L10n.edit.text : L10n.done.text
    }
  }

  var body: some View {
    List(selection: $selection) {
      let arr =
        Array(zip(model.customers.orderedKeys, model.customers.orderedValues.map(\.customer.name)))
          .filter { searchText.isEmpty ? true : $1.localizedStandardContains(searchText) }
      ForEach(arr, id: \.0) { id, _ in
        // BUG: Lots of already deleted keys being called for initialization
        // Maybe due to ForEach(_, id: \.0) doesn't delete the id immediately
        // BUG: Edit the customer will trigger view redraw once in the beginning
        CustomerRowWrapper(model: $model.customers[unchecked: id])
      }
      .onDelete {
        model.remove(atOffsets: $0)
      }
    }
    .animation(.default)
    .environment(\.editMode, $editMode)
    .navigationTitle(L10n.customers)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        editButton
      }
      ToolbarItem(placement: .navigationBarLeading) {
        deleteButton
      }
    }
    .listStyle(InsetGroupedListStyle())
    .navigationBarSearch($searchText, placeholder: L10n.search)
  }
}

struct CustomerRowWrapper: View {
  @Environment(\.presentationMode) private var presentationMode

  @Binding var model: CustomerDetailModel
  @State private var presentingDetailView: Bool = false

  var body: some View {
    Button {
      presentingDetailView = true
    } label: {
      CustomerRow(model: $model)
    }
    .sheet(isPresented: $presentingDetailView) {
      NavigationView {
        CustomerDetail(model: $model)
          .navigationTitle(model.customer.name)
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button {
                presentingDetailView = false
              } label: {
                L10n.done.text.bold()
              }
            }
          }
      }
    }
  }
}
