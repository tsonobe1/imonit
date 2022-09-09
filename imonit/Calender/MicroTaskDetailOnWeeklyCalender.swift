//
//  MicroTaskDetailOnWeeklyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/06.
//

import SwiftUI

struct MicroTaskDetailOnWeeklyCalender: View {
    @Environment(\.editMode) private var editMode
    @Binding var scrollViewHeight: CGFloat
    @Binding var timelineDividerWidth: CGFloat
    
    // MARK: 親Viewで選択したTaskを使い、MicroTasksをFetchする
    @ObservedObject var task: Task
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task, scrollViewHeight: Binding<CGFloat>, timelineDividerWidth: Binding<CGFloat>) {
        // showingAddMicroTaskTextFieldは、Addをタップした時にTaskのDateやDetailを隠すのに使う
        self.task = task
        self._scrollViewHeight = scrollViewHeight
        self._timelineDividerWidth = timelineDividerWidth
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
    var body: some View {
        VStack(spacing: 0) {
            ForEach(microTasks) { microTask in
                HStack(alignment: .top) {
                    let _ = print("scrollViewHeight: \(scrollViewHeight)")
                    RoundedRectangle(cornerRadius: 40)
                        .frame(width: 8, height: scrollViewHeight / 1_440 * (CGFloat(microTask.timer / 60)), alignment: .top)
                        .foregroundColor(.mint)
                        .opacity(0.6)
                        .fixedSize()

                    HStack(alignment: .center, spacing: 5) {
                    Text(microTask.microTask!)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)
                        .opacity(0.8)
                    
                    
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .frame(height: 1)
                        .opacity(0.5)
                    
                    Text("\(microTask.timer / 60) m")
                        .opacity(0.8)
                        .font(.caption)
                        .fixedSize()
                        .padding(.trailing)
                    }
                    
                }
//                .padding(.horizontal)
                .frame(
                    width: timelineDividerWidth,
                    height: scrollViewHeight / 1_440 * (CGFloat(microTask.timer / 60)),
                    alignment: .topLeading
                )
                .shadow(color: Color.black.opacity(0.9), radius: 20, x: 5, y: 10)
            }
//            .background(
//                Rectangle()
//                    .stroke(.primary, lineWidth: 1)
//                    .opacity(0.3)
//            )

        }
        .offset(
            //            x: 10,
            y: ((scrollViewHeight / 1_440) * dateToMinute(date: task.startDate!))
        )
        .zIndex(2)
    }
    
    func caluculateTimeInterval(startDate: Date, endDate: Date) -> CGFloat {
        let timeInterval = endDate.timeIntervalSince(startDate)
        //        print("👉 TimeInterval : \(timeInterval / 60)")
        return CGFloat(timeInterval / 60)
    }
    
    func dateToMinute(date: Date) -> CGFloat {
        //        print("dateToMinuteが何度も実行されてしまう問題を解決したい")
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        //        print("🫲 Convert Minute : \((hour * 60) + minute)")
        return CGFloat((hour * 60) + minute)
    }
}

