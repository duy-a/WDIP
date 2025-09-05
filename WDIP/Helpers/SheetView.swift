//
//  SheetView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 5/9/25.
//

import Foundation
import SwiftUI

struct SheetView: Identifiable {
    let id = UUID()
    let view: AnyView

    init<V: View>(view: V) {
        self.view = AnyView(view)
    }
}
