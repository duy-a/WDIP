//
//  VehicleForm.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftData
import SwiftUI

struct VehicleForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var vehicle: Vehicle? = nil
    var onDelete: (() -> Void)? = nil

    @State private var name: String = ""

    @State private var selectedIcon: PickerIcon = .car
    @State private var selectedColor: PickerColor = .red

    @State private var isShowingDeleteAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Vehicle Icon", systemImage: selectedIcon.iconString)
                        .labelStyle(.iconOnly)
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .padding(5)
                        .glassEffect(in: .circle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(5)

                    TextField("Vehicle Name", text: $name)
                        .font(.title)
                        .padding(5)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .glassEffect()
                }
                .foregroundStyle(selectedColor.color)
                .listRowSeparator(.hidden)

                Section {
                    ColorPicker(selectedColor: $selectedColor)
                }

                Section {
                    IconPicker(selectedIcon: $selectedIcon)
                }
            }
            .sheetToolbar("Vehicle Info") {
                if vehicle != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            isShowingDeleteAlert = true
                        }
                        .tint(.red)
                    }
                }

                ToolbarSpacer(.fixed, placement: .topBarTrailing)

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", systemImage: "checkmark", role: .confirm, action: saveVehicle)
                }
            }
            .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive, action: deleteVehicle)
            }
            .onAppear {
                presetFormValues()
            }
        }
    }
}

extension VehicleForm {
    func presetFormValues() {
        guard let vehicle else { return }

        name = vehicle.name
        selectedIcon = PickerIcon.icon(from: vehicle.icon)
        selectedColor = PickerColor.color(from: vehicle.color)
    }

    func saveVehicle() {
        if let vehicle {
            vehicle.name = name
            vehicle.icon = selectedIcon.iconString
            vehicle.color = selectedColor.colorString
        } else {
            let newVehicle = Vehicle()
            newVehicle.name = name
            newVehicle.icon = selectedIcon.iconString
            newVehicle.color = selectedColor.colorString

            modelContext.insert(newVehicle)
        }

        dismiss()
    }

    func deleteVehicle() {
        guard let vehicle else { return }
        modelContext.delete(vehicle)
        onDelete?()
        dismiss()
    }
}
