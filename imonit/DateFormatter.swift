//
//  DateFormatter.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/17.
//

import Foundation

func dateFormatter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("yMMMMdEEEE")
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func dateTimeFormatter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("jm")
    let dateString = dateFormatter.string(from: date)
    return dateString
}
