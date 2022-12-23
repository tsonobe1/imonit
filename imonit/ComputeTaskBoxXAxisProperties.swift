import Foundation


// MARK: 開始時刻、終了時刻の順に並べ替える。
let comparator2 = { (e1: Task, e2: Task) -> Bool in
    if e1.startDate! < e2.startDate! { return true }
    if e1.startDate! > e2.startDate! { return false }
    if e1.endDate! < e2.endDate! { return true }
    if e1.endDate! > e2.endDate! { return false }
    return false
}


func computeTaskBoxXAxisPropertiesOfAllRegion(tasks: [Task]) -> [UUID: (CGFloat, CGFloat)] {
    var taskBoxXAxisPropertiesOfAllRegion: [UUID: (xPositionRatio: CGFloat, widthRatio: CGFloat)] = [:]
    var columnsInRegion: [[Task]] = []
    var lastTaskEnding: Date?
    
    tasks.enumerated().forEach { (index, task) in
        // A: 今回のtaskが、前のtaskと時間が被っていない場合、これまでにpackしたtaskの、x軸上のpropertiesを算出して、辞書にマージする
        if lastTaskEnding != nil && task.startDate! >= lastTaskEnding! {
            // 辞書型のtaskBoxXAxisPropertiesOfAllRegionに、taskBoxXAxisPropertiesOfOneRegionをマージする
            taskBoxXAxisPropertiesOfAllRegion.merge( packTasks(columnsInRegion: columnsInRegion) ){ (current, _) in current }
            columnsInRegion = [] //初期化して次のRegionに備える
            lastTaskEnding = nil //初期化して次のRegionに備える
        }
        
        // B: columnsを順に見て、前のtaskと今のtaskが重ならない場合、colmuns[i]に今のtaskを追加
        // e.g. [ [task1, task10, task11], [task2], [task3]... ] <- このcolumn[task1, task10 ... ]に、taskを追加していく
        var placed = false
        for i in 0..<columnsInRegion.count {
            
            let col = columnsInRegion[i]
            // 前のtaskと今のtaskが重なっていない場合は...
            if !collidesWith( a: col[col.count - 1], b: task ){
                columnsInRegion[i].append(task)
                placed = true
                break
            }
        }
        
        // C taskがどのカラムにも追加されなかった場合、新しいカラムを作成し、そこに今のtaskを追加
        // e.g. [ [task1], [task2], [task3]... ] <- このcolumnsに、column:[taskx]を追加していく
        if !placed {
            columnsInRegion.append([task])
            //            print(columnsInRegion)
        }
        
        // D 今のtaskのendDateが前回のtaskのendDateより大きい場合、lastTaskEndingを今のtaskのendDateに更新
        if lastTaskEnding == nil || task.endDate! > lastTaskEnding! {
            lastTaskEnding = task.endDate
        }
    }
    if !columnsInRegion.isEmpty {
        taskBoxXAxisPropertiesOfAllRegion.merge( packTasks(columnsInRegion: columnsInRegion) ){ (current, _) in current }
    }
    return taskBoxXAxisPropertiesOfAllRegion
}


// 2つのTaskの時間が重なっているかどうかを判定する, 被ってたらtrue
func collidesWith(a: Task, b: Task) -> Bool {
    a.endDate! > b.startDate! && a.startDate! < b.endDate!
}


// taskのx軸上の位置の比率と、x軸上の横幅を、taskのidに紐づけて返す
func packTasks(columnsInRegion: [[Task]]) -> [UUID: (CGFloat, CGFloat)]{
    var taskBoxXAxisPropertiesOfOneRegion: [UUID: (xPositionRatio: CGFloat, widthRatio: CGFloat)] = [:]
    let columnsCount = columnsInRegion.count
    
    for (index, column) in columnsInRegion.enumerated() {
        for task in column {
            let leftRate = CGFloat(index) / CGFloat(columnsCount)
            let widthRate = 100.0 / CGFloat(columnsCount) / 100.0
            taskBoxXAxisPropertiesOfOneRegion[task.id!] = (xPositionRatio: leftRate, widthRatio: widthRate)
        }
    }
    return taskBoxXAxisPropertiesOfOneRegion
}


func getTaskBoxXAxisProperties(tasks: [Task]) -> [UUID: (CGFloat, CGFloat)]{
    let sortedTasks = tasks.sorted(by: comparator2)
    return computeTaskBoxXAxisPropertiesOfAllRegion(tasks: sortedTasks)
}
