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
    print("😊 DateString : \(dateString)")
    return dateString
}

func dateTimeFormatter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("jm")
    let dateTimeString = dateFormatter.string(from: date)
    print("😡 DateTimeString : \(dateTimeString)")
    return dateTimeString
}
