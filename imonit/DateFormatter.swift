//
//  DateFormatter.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/17.
//

import Foundation
import SwiftUI

func dateFormatter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("yMMMMdEEEE")
    let dateString = dateFormatter.string(from: date)
//    print("😊 DateString : \(dateString)")
    return dateString
}

func dateTimeFormatter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("Hm")
//    dateFormatter.timeStyle = .short
    let dateTimeString = dateFormatter.string(from: date)
//    print("😡 DateTimeString : \(dateTimeString)")
    return dateTimeString
}

func dateTimeFormatterColon() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("Hm")
    return dateFormatter
}

func convertToMinutes(date: Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let hour = calendar.component(.hour, from: date)
    let minute = calendar.component(.minute, from: date)
    return hour * 60 + minute
}

func dateToMinute(date: Date) -> CGFloat {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minute = calendar.component(.minute, from: date)
    return CGFloat((hour * 60) + minute)
}

func caluculateTimeInterval(startDate: Date, endDate: Date) -> CGFloat {
    let timeInterval = endDate.timeIntervalSince(startDate)
    return CGFloat(timeInterval / 60)
}
