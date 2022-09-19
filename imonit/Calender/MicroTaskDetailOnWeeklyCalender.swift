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
    @Binding var magnifyBy: Double
    
    // MARK: 親Viewで選択したTaskを使い、MicroTasksをFetchする
    @ObservedObject var task: Task
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task, scrollViewHeight: Binding<CGFloat>, timelineDividerWidth: Binding<CGFloat>, magnifyBy: Binding<Double>) {
        // showingAddMicroTaskTextFieldは、Addをタップした時にTaskのDateやDetailを隠すのに使う
        self.task = task
        self._scrollViewHeight = scrollViewHeight
        self._timelineDividerWidth = timelineDividerWidth
        self._magnifyBy = magnifyBy
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
        if magnifyBy == 30 {
            // pinch inの時はMicroTaskをすべて表示
            VStack(spacing: 0) {
                ForEach(microTasks) { microTask in
                    HStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 40)
                            .frame(width: 8, height: scrollViewHeight / 1_440 * (CGFloat(microTask.timer / 60)), alignment: .top)
                            .foregroundColor(.orange)
                            .opacity(0.6)
                            .fixedSize()
                        
                        HStack(alignment: .center, spacing: 5) {
                            Text(microTask.microTask!)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .layoutPriority(1)
                                .opacity(1)
                            
                            Group {
                                Line()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                    .frame(height: 1)
                                    .opacity(0.5)
                                
                                Text("\(microTask.timer / 60) m")
                                    .opacity(1)
                                    .font(.caption)
                                    .fixedSize()
                                    .padding(.trailing)
                            }
                        }
                    }
                    .frame(
                        width: timelineDividerWidth,
                        height: scrollViewHeight / 1_440 * (CGFloat(microTask.timer / 60)),
                        alignment: .topLeading
                    )
                }
            }
            .offset(y: ((scrollViewHeight / 1_440) * dateToMinute(date: task.startDate!)))
            .zIndex(2)
        } else {
            // pinch out時はTask名だけを表示
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 40)
                        .frame(
                            width: 4,
                            height: scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!),
                            alignment: .topLeading
                        )
                        .foregroundColor(.orange)
                        .opacity(0.6)
                        .fixedSize()
                    
                    HStack(alignment: .top) {
                        Text(task.task!)
                            .font(.subheadline)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        Text("\(task.microTasks!.count) micro tasks")
                            .font(.subheadline)
                            .minimumScaleFactor(0.5)
                            .padding(.trailing, 5)
                    }
                }
            }
            .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!))
            .frame(
                width: timelineDividerWidth,
                height: scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!),
                alignment: .topLeading
            )
        }
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
