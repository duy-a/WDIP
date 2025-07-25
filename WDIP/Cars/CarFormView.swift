//
//  CarFormView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import SwiftData
import SwiftUI

struct CarFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var car: Car? = nil

    @State private var name: String = ""
    @State private var icon: String = "car"
    @State private var iconColor: PickerColors = .red

    init(car: Car? = nil) {
        if let car {
            self.car = car
            self._name = State(wrappedValue: car.name)
            self._icon = State(wrappedValue: car.icon)
            self._iconColor = State(wrappedValue: PickerColors(rawValue: car.color)!)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Car Icon", systemImage: icon)
                        .labelStyle(.iconOnly)
                        .frame(width: 60, height: 60)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(iconColor.uiColor)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .center)

                    TextField("Name", text: $name)
                        .font(.title)
                        .padding(7)
                        .fontWeight(.semibold)
                        .background(.gray.opacity(0.15))
                        .foregroundStyle(iconColor.uiColor)
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

                if car != nil {
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
        if let car {
            car.name = name
            car.icon = icon
            car.color = iconColor.rawValue
        } else {
            let newCar = Car(name: name, icon: icon, color: iconColor.rawValue)
            newCar.name = name
            newCar.icon = icon
            newCar.color = iconColor.rawValue

            modelContext.insert(newCar)
        }

        dismiss()
    }

    func delete() {
        modelContext.delete(car!)
        dismiss()
    }
    
}

#Preview {
    CarFormView()
        .modelContainer(for: Car.self, inMemory: true)
}
