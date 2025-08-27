//
//  ColorPicker.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 25/7/25.
//

import SwiftUI

struct ColorPicker: View {
    @Binding var selectedColor: PickerColor

    let columns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 10) {
            ForEach(PickerColor.allCases) { color in
                Button {
                    withAnimation {
                        self.selectedColor = color
                    }
                } label: {
                    Label("\(color.rawValue) color icon",
                          systemImage: self.selectedColor == color ? "inset.filled.circle" : "circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(color.color)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    Form {
        Section {
            ColorPicker(selectedColor: .constant(.blue))
        }
    }
}

enum PickerColor: String, CaseIterable, Identifiable {
    case red, orange, yellow, green, blue, indigo, purple, brown, cyan, mint, pink, teal

    var id: String { self.rawValue }

    var color: Color {
        switch self {
            case .red: return .red
            case .orange: return .orange
            case .yellow: return .yellow
            case .green: return .green
            case .blue: return .blue
            case .indigo: return .indigo
            case .purple: return .purple
            case .brown: return .brown
            case .cyan: return .cyan
            case .mint: return .mint
            case .pink: return .pink
            case .teal: return .teal
        }
    }
    
    var colorString: String {
        self.rawValue
    }

    static func color(from rawValue: String) -> Color {
        PickerColor(rawValue: rawValue)?.color ?? .primary
    }

    static func color(from rawValue: String) -> PickerColor {
        PickerColor(rawValue: rawValue) ?? .red
    }
}
