//
//  CarListView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import SwiftData
import SwiftUI

struct CarListView: View {
    @Query(sort: \Car.name)
    private var cars: [Car]

    @State private var isPresentedCarForm: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cars) { car in
                    VStack {
                        Text(car.name)
                        Text(car.icon)
                        Text(car.color)
                    }
                }
            }
            .navigationTitle("Your Cars")
            .sheet(isPresented: $isPresentedCarForm) {
                CarFormView()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentedCarForm = true
                    } label: {
                        Label("Add new car", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    CarListView()
        .modelContainer(for: Car.self, inMemory: true)
}
