//
//  MicroTaskIntoWeeklyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/04.
//

import SwiftUI

struct MicroTaskIntoWeeklyCalender: View {
    @Environment(\.editMode) private var editMode
    @Binding var scrollViewHeight: CGFloat

    // MARK: 親Viewで選択したTaskを使い、MicroTasksをFetchする
    @ObservedObject var task: Task
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task, scrollViewHeight: Binding<CGFloat>) {
        // showingAddMicroTaskTextFieldは、Addをタップした時にTaskのDateやDetailを隠すのに使う
        self.task = task
        self._scrollViewHeight = scrollViewHeight
        _microTasks = FetchRequest(
            entity: MicroTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \MicroTask.order, ascending: true)],
            predicate: NSPredicate(format: "task == %@", task)
        )
    }

    // MicroTaskのListの下部に表示
    private var totalTime: Int {
        var total = 0
        for minute in microTasks {
            total += Int(minute.timer / 60)
        }
        return total
    }

    @State private var textHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(microTasks) { microTask in
                HStack(alignment: .center, spacing: 10) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 3)
                        .foregroundColor(.mint)
                        .opacity(0.7)
                        .fixedSize()

                    Text(microTask.microTask!)
//                        .font(.caption)
                        .font(.system(size: 100))
                        .foregroundColor(.primary)
                        .opacity(0.9)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)

                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .frame(height: 1)
                        .opacity(0.6)

                    Text("\(microTask.timer / 60) m")
                        .opacity(0.9)
                        .fixedSize()
                        .padding(.trailing)
                        .padding(.trailing)
                }
            }
        }
        .frame(height: scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!), alignment: .top)
    }
    func caluculateTimeInterval(startDate: Date, endDate: Date) -> CGFloat {
        let timeInterval = endDate.timeIntervalSince(startDate)
        //        print("👉 TimeInterval : \(timeInterval / 60)")
        return CGFloat(timeInterval / 60)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

//struct MicroTaskIntoWeeklyCalender_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let result = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//
//        let newTask = Task(context: viewContext)
//        newTask.task = "Quis nostrud exercitation ullamco"
//        newTask.isDone = false
//        newTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
//        newTask.createdAt = Date()
//        newTask.id = UUID()
//        newTask.startDate = Date()
//        newTask.endDate = Date()
//        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
//        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"
//
//        let newMicroTask = MicroTask(context: viewContext)
//        newMicroTask.microTask = "Lorem ipsum dolor sit amet, continer add edit sed do eiusmod tempor incididunt ut"
//        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
//        newMicroTask.id = UUID()
//        newMicroTask.isDone = false
//        newMicroTask.timer = 600
//        newMicroTask.createdAt = Date()
//        newMicroTask.order = 0
//        newMicroTask.satisfactionPredict = 5
//        newMicroTask.satisfactionPredict = 5
//        newMicroTask.task = newTask
//
//        return MicroTaskIntoWeeklyCalender(withChild: newTask,)
//    }
//}
