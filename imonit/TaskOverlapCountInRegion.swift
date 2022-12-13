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
    var overlap: Int = 0
//    var maxOverlap: Int = 0
    
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
        return a.type > b.type
    } else {
        return a.index < b.index
    }
}

// MARK: taskが他のTaskと重なっている数を、task.idに紐づけて返す
func getOverlapCount(splitedTasks: [TimeMoment]) -> [UUID: (maxOverlap: Int, xAxisOrder: Int)]{
    // イベント毎にオーバーラップ数を格納する辞書を作成する
    var taskOverlapCounts: [UUID: (maxOverlap: Int, xAxisOrder: Int)] = [:]
    var currentOverlap = 0
    var isHasBeenMinusCurrentOverlap = false
    var maxOverlap = 0
    var regions = [TimeMoment]()
    
    
    for event in splitedTasks {
        // イベントの種類に応じてオーバーラップ数を増減
        if event.type == .START {
            currentOverlap += 1
        } else {
            currentOverlap -= 1
//            isHasBeenMinusCurrentOverlap = true
        }
        // 最大オーバーラップ数を更新
        maxOverlap = max(currentOverlap, maxOverlap)
        
        if event.type == .START {
            regions.append(
                TimeMoment(
                    time: event.time,
                    type: event.type,
                    index: event.index,
                    id: event.id,
                    overlap: currentOverlap
                )
            )
        }
        
        // オーバーラップ数が0になった場合は、dictに[task.id : (maxOverlap, xOrder)]を追加していく
        if currentOverlap == 0 {
            let maxOverlapWhenStartType = maxOverlap
            
            for region in regions{
                    // taskのidをkeyとして、そのTaskのmaxOverlapと、x軸上の左から何番目に配置すべきかを引き出せるdict
                    taskOverlapCounts[region.id] = (
                        // 自身のTaskが所属するRegionのmaxOverlap
                        maxOverlap: maxOverlapWhenStartType,
                        // x軸上で、左から何番目に配置されるべきかを示したInt
                        xAxisOrder: region.overlap
                    )
                regions.removeAll()
                maxOverlap = 0
            }
        }
    }
    return taskOverlapCounts
}


// MARK: 上記の処理をまとめる
func getOverlapCountAndXAxisWithTaskID(tasks: FetchedResults<Task>) -> [UUID: (maxOverlap: Int, xAxisOrder: Int)] {
    var splitedTasks = splitTasksIntoStartAndEndDates(tasks: tasks)
    splitedTasks.sort(by: comparator)
    let overlapCountWithTaskID = getOverlapCount(splitedTasks: splitedTasks)
    return overlapCountWithTaskID
}

