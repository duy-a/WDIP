//
//  ParkingSpotLabel.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import SwiftUI

struct ParkingSpotLabel: View {
    
    var icon: PickerIcons = .car
    var color: PickerColors = .red
    
    var body: some View {
        Label("Vehicle Icon", systemImage: icon.rawValue)
            .labelStyle(.iconOnly)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(10)
            .background(color.uiColor)
            .clipShape(Circle())
    }
}

#Preview {
    ParkingSpotLabel()
}
