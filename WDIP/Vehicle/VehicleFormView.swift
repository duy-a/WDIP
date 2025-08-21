//
//  VehicleFormView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import SwiftData
import SwiftUI

struct VehicleFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var vehicle: Vehicle? = nil

    @State private var name: String = ""
    @State private var icon: String = "car"
    @State private var iconColor: PickerColor = .red

    init(vehicle: Vehicle? = nil) {
        if let vehicle {
            self.vehicle = vehicle
            self._name = State(wrappedValue: vehicle.name)
            self._icon = State(wrappedValue: vehicle.icon)
            self._iconColor = State(wrappedValue: PickerColor(rawValue: vehicle.color)!)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Vehicle Icon", systemImage: icon)
                        .labelStyle(.iconOnly)
                        .frame(width: 60, height: 60)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(iconColor.color)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .center)

                    TextField("Name", text: $name)
                        .font(.title)
                        .padding(7)
                        .fontWeight(.semibold)
                        .background(.gray.opacity(0.15))
                        .foregroundStyle(iconColor.color)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                        .padding(.top, -15)
                }
                .listRowSeparator(.hidden)

                Section {
                    ColorPicker(selectedColor: $iconColor)
                }

                Section {
                    IconPicker(selectedIcon: $icon)
                }

                if vehicle != nil {
                    Section {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .fontWeight(.semibold)
                                .labelStyle(.titleOnly)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
        }
    }

    func save() {
        if let vehicle {
            vehicle.name = name
            vehicle.icon = icon
            vehicle.color = iconColor.rawValue
        } else {
            let vehicle = Vehicle(name: name, icon: icon, color: iconColor.rawValue)
            vehicle.name = name
            vehicle.icon = icon
            vehicle.color = iconColor.rawValue

            modelContext.insert(vehicle)
        }

        dismiss()
    }

    func delete() {
        modelContext.delete(vehicle!)
        dismiss()
    }
    
}

#Preview {
    VehicleFormView()
        .modelContainer(for: Vehicle.self, inMemory: true)
}
