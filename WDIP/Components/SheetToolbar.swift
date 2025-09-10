//
//  SheetToolbar.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 9/9/25.
//

import SwiftUI

struct SheetToolbar<Items: ToolbarContent>: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    var title: String
    var items: Items

    init(title: String, @ToolbarContentBuilder items: () -> Items) {
        self.title = title
        self.items = items()
    }

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .close) {
                        dismiss()
                    }
                }

                items
            }
    }
}

struct BasicSheetToolbar: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    var title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .close) {
                        dismiss()
                    }
                }
            }
    }
}

extension View {
    func sheetToolbar<Actions: ToolbarContent>(_ title: String,
                                               @ToolbarContentBuilder items: () -> Actions) -> some View
    {
        modifier(SheetToolbar(title: title, items: items))
    }

    func sheetToolbar(_ title: String) -> some View {
        modifier(BasicSheetToolbar(title: title))
    }
}
