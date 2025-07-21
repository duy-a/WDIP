//
//  Item.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
