//
//  OrdersView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct OrdersView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Orders")) {
                    OrderRow(orderName: "Order #1234", status: "Preparing")
                    OrderRow(orderName: "Order #5678", status: "Ready for Pickup")
                }
                
                Section(header: Text("Past Orders")) {
                    OrderRow(orderName: "Order #91011", status: "Completed")
                }
            }
            .navigationTitle("Orders")
        }
    }
}


