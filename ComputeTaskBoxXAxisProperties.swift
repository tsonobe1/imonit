import Foundation

// MARK: Model
// CoreDataのEntityの再現
struct Task1 {
    var name: String
    var startDate: Date
    var endDate: Date
    var id: UUID
}

// MARK: データセットを作る
func makeDataSet() -> [Task1]{
    var tasks = [Task1]()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = "2022-12-06"
    let date = dateFormatter.date(from: dateString)!
    
    // Data Set
    let startDate1 = date
    let endDate1 = Calendar.current.date(byAdding: .minute, value: 50, to: startDate1)!
    let startDate2 = Calendar.current.date(byAdding: .minute, value: 0, to: startDate1)!
    let endDate2 = Calendar.current.date(byAdding: .minute, value: 100, to: startDate1)!
    let startDate3 = Calendar.current.date(byAdding: .minute, value: 30, to: startDate1)!
    let endDate3 = Calendar.current.date(byAdding: .minute, value: 150, to: startDate1)!
    let startDate4 = Calendar.current.date(byAdding: .minute, value: 300, to: startDate1)!
    let endDate4 = Calendar.current.date(byAdding: .minute, value: 550, to: startDate1)!
    let startDate5 = Calendar.current.date(byAdding: .minute, value: 350, to: startDate1)!
    let endDate5 = Calendar.current.date(byAdding: .minute, value: 400, to: startDate1)!
    let startDate6 = Calendar.current.date(byAdding: .minute, value: 600, to: startDate1)!
    let endDate6 = Calendar.current.date(byAdding: .minute, value: 700, to: startDate1)!
    let startDate7 = Calendar.current.date(byAdding: .minute, value: 800, to: startDate1)!
    let endDate7 = Calendar.current.date(byAdding: .minute, value: 900, to: startDate1)!
    let startDate8 = Calendar.current.date(byAdding: .minute, value: 1000, to: startDate1)!
    let endDate8 = Calendar.current.date(byAdding: .minute, value: 1500, to: startDate1)!
    let startDate9 = Calendar.current.date(byAdding: .minute, value: 1000, to: startDate1)!
    let endDate9 = Calendar.current.date(byAdding: .minute, value: 1500, to: startDate1)!
    let startDate10 = Calendar.current.date(byAdding: .minute, value: 50, to: startDate1)!
    let endDate10 = Calendar.current.date(byAdding: .minute, value: 150, to: startDate1)!
    
    tasks.append(Task1(name: "Task 1", startDate: startDate1, endDate: endDate1, id: UUID()))
    tasks.append(Task1(name: "Task 2", startDate: startDate2, endDate: endDate2, id: UUID()))
    tasks.append(Task1(name: "Task 3", startDate: startDate3, endDate: endDate3, id: UUID()))
    tasks.append(Task1(name: "Task 4", startDate: startDate4, endDate: endDate4, id: UUID()))
    tasks.append(Task1(name: "Task 5", startDate: startDate5, endDate: endDate5, id: UUID()))
    tasks.append(Task1(name: "Task 6", startDate: startDate6, endDate: endDate6, id: UUID()))
    tasks.append(Task1(name: "Task 7", startDate: startDate7, endDate: endDate7, id: UUID()))
    tasks.append(Task1(name: "Task 8", startDate: startDate8, endDate: endDate8, id: UUID()))
    tasks.append(Task1(name: "Task 9", startDate: startDate9, endDate: endDate9, id: UUID()))
    tasks.append(Task1(name: "Task 10", startDate: startDate10, endDate: endDate10, id: UUID()))
    
    
    
    return tasks
}
var tasks: [Task1] = makeDataSet()

// MARK: 開始時刻、終了時刻の順に並べ替える。
let comparator2 = { (e1: Task1, e2: Task1) -> Bool in
    if e1.startDate < e2.startDate { return true }
    if e1.startDate > e2.startDate { return false }
    if e1.endDate < e2.endDate { return true }
    if e1.endDate > e2.endDate { return false }
    return false
}

//tasks.sort(by: comparator)


func computeTaskBoxXAxisPropertiesOfAllRegion(tasks: [Task1]) -> [UUID: (CGFloat, CGFloat)] {
    var taskBoxXAxisPropertiesOfAllRegion: [UUID: (xxPositionRatio: CGFloat, widthRatio: CGFloat)] = [:]
    var columnsInRegion: [[Task1]] = []
    var lastTaskEnding: Date?

    tasks.enumerated().forEach { (index, task) in
        // A: 今回のtaskが、前のtaskと時間が被っていない場合、これまでにpackしたtaskの、x軸上のpropertiesを算出して、辞書にマージする
        if lastTaskEnding != nil && task.startDate >= lastTaskEnding! {
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
            print(columnsInRegion)
        }
        
        // D 今のtaskのendDateが前回のtaskのendDateより大きい場合、lastTaskEndingを今のtaskのendDateに更新
        if lastTaskEnding == nil || task.endDate > lastTaskEnding! {
            lastTaskEnding = task.endDate
        }
    }
    if !columnsInRegion.isEmpty {
        taskBoxXAxisPropertiesOfAllRegion.merge( packTasks(columnsInRegion: columnsInRegion) ){ (current, _) in current }
    }
    return taskBoxXAxisPropertiesOfAllRegion
}

// 2つのTaskの時間が重なっているかどうかを判定する, 被ってたらtrue
func collidesWith(a: Task1, b: Task1) -> Bool {
    a.endDate > b.startDate && a.startDate < b.endDate
}

// taskのx軸上の位置の比率と、x軸上の横幅を、taskのidに紐づけて返す
func packTasks(columnsInRegion: [[Task1]]) -> [UUID: (CGFloat, CGFloat)]{
    var taskBoxXAxisPropertiesOfOneRegion: [UUID: (xPositionRatio: CGFloat, widthRatio: CGFloat)] = [:]
    
    let columnsCount = columnsInRegion.count
    print("---------------------------")
    for (index, column) in columnsInRegion.enumerated() {
        for task in column {
            let leftRate = CGFloat(index) / CGFloat(columnsCount)
            let widthRate = 100.0 / CGFloat(columnsCount) / 100.0
            taskBoxXAxisPropertiesOfOneRegion[task.id] = (xPositionRatio: leftRate, widthRatio: widthRate)
        }
    }
    return taskBoxXAxisPropertiesOfOneRegion
}

func getTaskBoxXAxisProperties() -> [UUID: (CGFloat, CGFloat)]{
    var tasks = makeDataSet()
    tasks.sort(by: comparator2)
    return computeTaskBoxXAxisPropertiesOfAllRegion(tasks: tasks)
}
