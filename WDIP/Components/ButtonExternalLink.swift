//
//  ButtonExternalLink.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 17/9/25.
//

import SwiftUI

struct ButtonExternalLink: View {
    @Environment(\.openURL) private var openURL

    var title: String
    var systemImage: String = ""
    var link: String

    var body: some View {
        Button {
            openURL(URL(string: link)!)
        } label: {
            Label {
                HStack {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            } icon: {
                Image(systemName: systemImage)
            }
        }
        .buttonStyle(.plain)
    }
}
