//
//  CarListView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import SwiftData
import SwiftUI

struct CarListView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCarTracking: Car

    @Query(sort: \Car.name)
    private var cars: [Car]

    @State private var isPresentedCarForm: Bool = false
    @State private var selectedCarInfo: Car? = nil

    var body: some View {
        NavigationStack {
            Group {
                if cars.count <= 0 {
                    CarListEmptyView {
                        isPresentedCarForm = true
                    }
                } else {
                    List {
                        ForEach(cars) { car in
                            HStack {
                                Button {
                                    selectedCarTracking = car
                                    dismiss()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: car.icon)
                                            .foregroundColor(PickerColors.getUIColor(color: car.color))

                                        Text(car.name)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    selectedCarInfo = car
                                } label: {
                                    Label("Car information", systemImage: "info.circle")
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Cars")
            .sheet(isPresented: $isPresentedCarForm) {
                CarFormView()
            }
            .sheet(item: $selectedCarInfo) { car in
                CarFormView(car: car)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close Car list", systemImage: "xmark")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentedCarForm = true
                    } label: {
                        Label("Add new car", systemImage: "plus")
                    }
                }
            }
            .onAppear {}
        }
    }
}

#Preview {
    let newCar = Car()
    CarListView(selectedCarTracking: .constant(newCar))
        .modelContainer(for: Car.self, inMemory: true)
}
