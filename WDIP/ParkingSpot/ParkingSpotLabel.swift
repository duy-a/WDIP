//
//  ParkingSpotLabel.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import SwiftUI

struct ParkingSpotLabel: View {
    
    var icon: PickerIcon = .car
    var color: PickerColor = .red
    
    var body: some View {
        Label("Vehicle Icon", systemImage: icon.rawValue)
            .labelStyle(.iconOnly)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(10)
            .background(color.color)
            .clipShape(Circle())
    }
}

#Preview {
    ParkingSpotLabel()
}
