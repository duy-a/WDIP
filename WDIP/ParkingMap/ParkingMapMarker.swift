//
//  ParkingMapMarker.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 17/9/25.
//

import SwiftUI

struct ParkingMapMarker: View {
    var actionName: String
    var icon: String
    var color: Color
    var action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(actionName, systemImage: icon, action: action)
                .buttonStyle(.glassProminent)
                .tint(color)

            Label("Parking Location Indicator", systemImage: "arrowtriangle.down.fill")
                .foregroundStyle(color)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }
}
