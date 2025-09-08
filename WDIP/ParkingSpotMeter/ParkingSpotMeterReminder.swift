//
//  ParkingSpotMeterReminder.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 8/9/25.
//

import SwiftUI

extension ParkingSpotMeter {
    @ViewBuilder
    var meterReminder: some View {
        Section {
            Toggle("Remind me", systemImage: "bell", isOn: $toggleReminder)
            Label("Time", systemImage: "alarm")
        }
    }
}
