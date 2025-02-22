//
//  KitchenEditForm.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/22/25.
//

import SwiftUI
import MapKit

struct KitchenEditForm: View {
    @Binding var editedName: String
    @Binding var editedDescription: String
    @Binding var editedCuisine: String
    @Binding var editedAddress: String?
    @Binding var showAddressSelection: Bool
    @Binding var mapAnnotation: MapAnnotationPoint?
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Kitchen Name", text: $editedName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Cuisine Type", text: $editedCuisine)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Description", text: $editedDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading) {
                Text("Kitchen Address:")
                    .font(.headline)
                
                Text(editedAddress ?? "No address set")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                
                Button("Change Address") {
                    showAddressSelection = true
                }
                .foregroundColor(.blue)
                
                if let annotation = mapAnnotation {
                    Map(coordinateRegion: $region, annotationItems: [annotation]) { point in
                        MapMarker(coordinate: point.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
}
