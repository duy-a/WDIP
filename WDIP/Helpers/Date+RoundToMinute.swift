//
//  Date+RoundToMinute.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 9/9/25.
//

import Foundation

extension Date {
    var roundedToNearestMinute: Date {
        let timeInterval = self.timeIntervalSinceReferenceDate
        let rounded = (timeInterval / 60).rounded() * 60
        return Date(timeIntervalSinceReferenceDate: rounded)
    }
}
