//
//  ThemeColors.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import SwiftUI

struct ThemeColors {
    @Environment(\.colorScheme) var colorScheme
    
    private var lightBackgroundColor: Color = Color(red: 0.03, green: 0.08, blue: 0.15)
    private var darkBackgroundColor: Color = Color(red: 0.7, green: 0.85, blue: 0.95)
    
    var appBackgroundColor: Color {
        colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor
    }
}
