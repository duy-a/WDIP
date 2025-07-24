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

    @State private var name: String = ""
    @State private var iconColor: Car.IconColor = .red
    @State private var icon: String = "Icon name"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(systemName: "car")
                        .glassEffect(in: .circle)
                    
                    TextField("Name", text: $name)
                }
                
                Section {
                    HStack {
                        ForEach(Car.IconColor.allCases) { color in
                            Button {
                                withAnimation {
                                    iconColor = color
                                }
                            } label: {
                                Label("\(color.toString) color icon",
                                      systemImage: iconColor == color ? "inset.filled.circle" : "circle.fill")
                                    .labelStyle(.iconOnly)
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(color.uiColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    Text("Icons will be here")
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
                        addCar()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
        }
    }
    
    func addCar() {
        let newCar = Car(name: name, icon: icon, color: iconColor)
        modelContext.insert(newCar)
        dismiss()
    }
}

#Preview {
    CarFormView()
        .modelContainer(for: Car.self, inMemory: true)
}
