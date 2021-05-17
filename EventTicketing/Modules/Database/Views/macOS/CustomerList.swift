//
//  CustomerList.swift
//  EventTicketing
//
//  Created by Quan Tran on 12/24/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//

import SwiftUI

struct CustomerList: View {
  @ObservedObject private var model = CustomerListModel()
  
  @State private var selection: Set<String> = []
  @State private var searchText: String = ""
  @State private var presentingDetailView: Bool = false
  
  var body: some View {
    NavigationView {
      List(selection: $selection) {
        let arr =
          Array(zip(
            model.customers.orderedKeys,
            model.customers.orderedValues.map(\.customer.name)
          ))
          .filter { searchText.isEmpty ? true : $1.localizedStandardContains(searchText) }
        ForEach(arr, id: \.0) { id, _ in
          NavigationLink(destination: CustomerDetail(model: $model.customers[unchecked: id])) {
            CustomerRow(model: $model.customers[unchecked: id])
              .frame(maxHeight: 30)
          }
        }
        .onDeleteCommand {
          model.remove(ids: Array(selection))
        }
      }
    }
    .navigationTitle(L10n.customers)
    .toolbar {
//      ToolbarItem(placement: .navigationBarTrailing) {
//        editButton
//      }
//      ToolbarItem(placement: .navigationBarLeading) {
//        deleteButton
//      }
    }
  }
}
