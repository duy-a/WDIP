//
//  VehicleForm.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 22/8/25.
//

import SwiftData
import SwiftUI

struct VehicleForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var vehicle: Vehicle? = nil

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
                toolbarContent
            }
            .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive, action: delete)
            }
            .onAppear {
                onStart()
            }
        }
    }
}

#Preview {
    VehicleForm(vehicle: StoreProvider.sampleVehicle)
}

extension VehicleForm {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if vehicle != nil {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete", systemImage: "trash", role: .destructive, action: { isShowingDeleteAlert = true })
                    .tint(.red)
            }
        }

        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .topBarTrailing) {
            Button("Save", systemImage: "checkmark", role: .confirm, action: save)
                .buttonStyle(.glassProminent)
        }
    }
}

extension VehicleForm {
    func onStart() {
        guard let vehicle else { return }

        name = vehicle.name
        selectedIcon = PickerIcon.icon(from: vehicle.icon)
        selectedColor = PickerColor.color(from: vehicle.color)
    }

    func save() {
        if let vehicle {
            vehicle.name = name
            vehicle.icon = selectedIcon.rawValue
            vehicle.color = selectedColor.rawValue
        } else {
            let newVehicle = Vehicle(name: name, icon: selectedIcon.iconString, color: selectedColor.colorString)
            modelContext.insert(newVehicle)
        }

        dismiss()
    }

    func delete() {
        guard let vehicle else { return }
        modelContext.delete(vehicle)
        dismiss()
    }
}
