//
//  ContentView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        ParkingMapView()
    }
}

#Preview {
    ContentView()
        .modelContainer(StoreProvider.previewModelContainer)
}
