//
//  Date+RoundToMinute.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import Foundation

extension Date {
    var roundedDownToMinute: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)!
    }
}
