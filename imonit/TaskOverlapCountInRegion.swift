//
//  TaskOverlapCountInRegion.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/12/11.
//

import Foundation
import SwiftUI

// Task EntityをStartDateとEndDateに分割するための構造体
struct TimeMoment {
    var time: Date
    var type: TimeType
    var index: Int
    var id: UUID

    enum TimeType: Comparable {
        case START
        case END

        // 比較演算子を使用可能にする
        static func < (lhs: TimeType, rhs: TimeType) -> Bool {
            switch (lhs, rhs) {
                case (.START, .END):
                    return true
                default:
                    return false
            }
        }
    }
}


// MARK: TaskをSTART, ENDの2つに分割する
func splitTasksIntoStartAndEndDates(tasks: FetchedResults<Task>) -> [TimeMoment]{
    var timeMoments = [TimeMoment]()
    for (index, task) in tasks.enumerated() {
        timeMoments.append(TimeMoment(time: task.startDate!, type: .START, index: index, id: task.id!))
        timeMoments.append(TimeMoment(time: task.endDate!, type: .END, index: index, id: task.id!))
    }
    return timeMoments
}


// MARK: 3つのキーでソートする
let comparator = { (a: TimeMoment, b: TimeMoment) -> Bool in
    // もし1つめと2つめのtimeが異なるなら、値が小さい方を返す
    if a.time != b.time {
        return a.time < b.time
    }
    // もし1つめと2つめのtypeが異なるなら、STARTの方を返す
    if a.type != b.type {
        return a.type < b.type
    } else {
        return a.index < b.index
    }
}

// MARK: taskが他のTaskと重なっている数を、task.idに紐づけて返す
func getOverlapCount(splitedTasks: [TimeMoment]) -> [UUID: Int] {
    // OverlapしているRegionごとにArrayを作成する
    var currentOverlap = Int.zero
    var maxOverlap = Int.zero
    var regions = [TimeMoment]()
    // イベント毎にオーバーラップ数を格納する辞書を作成する
    var taskOverlapCounts: [UUID: Int] = [:]
    
    for event in splitedTasks {
        regions.append(event)
        // イベントの種類に応じてオーバーラップ数を増減
        if event.type == .START {
            currentOverlap += 1
        } else {
            currentOverlap -= 1
        }
        // 最大オーバーラップ数を更新
        maxOverlap = max(currentOverlap, maxOverlap)
        
        // オーバーラップ数が0になった場合は、dictに[task.id : maxOverlap]を追加していく
        if currentOverlap == 0 {
            for i in regions {
                taskOverlapCounts[i.id] = maxOverlap
            }
            regions.removeAll()
            maxOverlap = 0
        }
    }
    return taskOverlapCounts
}


// MARK: 上記の処理をまとめる
func getOverlapCountWithTaskID(tasks: FetchedResults<Task>) -> [UUID: Int] {
    var splitedTasks = splitTasksIntoStartAndEndDates(tasks: tasks)
    splitedTasks.sort(by: comparator)
    return getOverlapCount(splitedTasks: splitedTasks)
}
