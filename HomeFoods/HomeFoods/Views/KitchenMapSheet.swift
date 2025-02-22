//
//  KitchenMapSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/22/25.
//

import SwiftUI
import MapKit

struct KitchenMapSheet: View {
    let kitchen: Kitchen
    @Binding var isPresented: Bool
    @State private var region: MKCoordinateRegion
    
    init(kitchen: Kitchen, isPresented: Binding<Bool>) {
        self.kitchen = kitchen
        self._isPresented = isPresented
        
        let coordinate = CLLocationCoordinate2D(
            latitude: kitchen.location.latitude,
            longitude: kitchen.location.longitude
        )
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: [
                MapAnnotationPoint(coordinate: CLLocationCoordinate2D(
                    latitude: kitchen.location.latitude,
                    longitude: kitchen.location.longitude
                ))
            ]) { point in
                MapMarker(coordinate: point.coordinate, tint: .red)
            }
            .navigationTitle(kitchen.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}
