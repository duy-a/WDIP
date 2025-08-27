//
//  IconPicker.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 25/7/25.
//

import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: PickerIcon

    let columns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 10) {
            ForEach(PickerIcon.allCases) { icon in
                Button {
                    withAnimation {
                        self.selectedIcon = icon
                    }
                } label: {
                    Label("\(icon.rawValue)", systemImage: icon.rawValue)
                        .labelStyle(.iconOnly)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .clipShape(Circle())
                        .padding(3)
                        .overlay(
                            Circle()
                                .stroke(icon == self.selectedIcon ? .gray : .clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    Form {
        Section {
            IconPicker(selectedIcon: .constant(.car))
        }
    }
}

enum PickerIcon: String, Identifiable, CaseIterable {
    case car
    case convertible = "convertible.side"
    case bus
    case tram
    case truckBox = "truck.box"
    case truckPickup = "truck.pickup.side"
    case scooter
    case bicycle
    case motorcycle
    case sailboat
    case ferry
    case airplane
    case trainSideFrontCar = "train.side.front.car"
    case sparkles
    case flame
    case wind
    case balloon
    case dropDegreesign = "drop.degreesign"
    case flag = "flag.pattern.checkered"
    case dog
    case cat
    case teddybear
    case pawprint
    case bird
    case fish
    case lizard
    case ant
    case ladybug
    case tortoise
    case hare

    var id: String { self.rawValue }

    var iconString: String {
        self.rawValue
    }

    static func icon(from rawValue: String) -> PickerIcon {
        PickerIcon(rawValue: rawValue) ?? .car
    }
}
