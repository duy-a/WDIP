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
    @State private var selectedCar: Car? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(cars) { car in
                    Button {
                        selectedCar = car
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: car.icon)
                                .foregroundColor(PickerColors.getUIColor(color: car.color))

                            Text(car.name)

                            Spacer()

                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Your Cars")
            .sheet(isPresented: $isPresentedCarForm) {
                CarFormView()
            }
            .sheet(item: $selectedCar) { car in
                CarFormView(car: car)
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
