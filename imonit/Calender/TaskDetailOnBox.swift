//
//  MicroTaskDetailOnWeeklyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/06.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct TaskDetailOnBox: View {
    @Environment(\.editMode) private var editMode
    var scrollViewHeight: CGFloat
    @Binding var timelineDividerWidth: CGFloat
    @Binding var magnifyBy: Double
    
    // MARK: 親Viewで選択したTaskを使い、MicroTasksをFetchする
    @ObservedObject var task: Task
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task, scrollViewHeight: CGFloat, timelineDividerWidth: Binding<CGFloat>, magnifyBy: Binding<Double>) {
        // showingAddMicroTaskTextFieldは、Addをタップした時にTaskのDateやDetailを隠すのに使う
        self.task = task
        self.scrollViewHeight = scrollViewHeight
        self._timelineDividerWidth = timelineDividerWidth
        self._magnifyBy = magnifyBy
        _microTasks = FetchRequest(
            entity: MicroTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \MicroTask.order, ascending: true)],
            predicate: NSPredicate(format: "task == %@", task)
        )
    }
    
//    // MicroTaskのListの下部に表示
//    private var totalTime: Int {
//        var total = 0
//        for minute in microTasks {
//            total += Int(minute.timer / 60)
//        }
//        return total
//    }
    
    @State private var taskTitleHeight: CGFloat = CGFloat.zero
    @State private var microTasksTitleHeight: CGFloat = CGFloat.zero
    
    var body: some View {
        // MARK: pinch in時
        if magnifyBy >= 10 {
            VStack(spacing: 0) {
                ForEach(microTasks) { microTask in
                    VStack {
                        HStack(alignment: .top) {
                            // Color Border
                            RoundedRectangle(cornerRadius: 40)
                            // microTaskのtimer分の長さのColor Border
                                .frame(width: 5, height: scrollViewHeight / 1_440 * CGFloat(microTask.timer / 60), alignment: .top)
                                .foregroundColor(.blue)
                                .opacity(0.8)
                                .fixedSize()
                            
                            // MicroTaskTitle ...... min
                            GeometryReader { metrics in
                                HStack(alignment: .center, spacing: 0) {
                                    Text(microTask.microTask!)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .minimumScaleFactor(0.6)
                                        .frame(width: metrics.size.width * 0.75, alignment: .leading)
                                        .opacity(1)
                                    
//                                    Spacer()
                                    
                                    Text("\(microTask.timer / 60)m")
                                        .font(.caption)
                                        .minimumScaleFactor(0.6)
                                        .frame(width: metrics.size.width * 0.20, alignment: .trailing)
                                        .opacity(1)
                                    
                                    Spacer()
                                }
                                .overlay(
                                    // bar
                                    Rectangle()
                                        .offset(y: 0)
                                        .frame(width: timelineDividerWidth, height: 0.8)
                                        .foregroundColor(.primary)
                                        .colorInvert()
                                        .opacity(0.9),
                                    alignment: .topTrailing
                                )
                                .frame(width: timelineDividerWidth - 8)
                                
                            }
                            .padding(.trailing, 10)
                        }
                        .frame(
                            height: scrollViewHeight / 1_440 * (CGFloat(microTask.timer / 60)),
                            alignment: .topLeading
                        )
                    }
                }
            }
        } else {
            // MARK: pinch out時
            HStack(alignment: .top) {
                // Left Color Border
                RoundedRectangle(cornerRadius: 40)
                    .frame(
                        width: 5,
                        height: scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!)
                        //                        alignment: .topLeading
                    )
                    .foregroundColor(.blue)
                    .opacity(0.8)
                    .fixedSize()
                
                VStack {
                    ZStack(alignment: .top) {
                        // TaskTitle
                        HStack(alignment: .top) {
                            Text(task.task!)
                                .bold()
                                .font(.subheadline)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        // TaskTitleの高さ。ZStackで配置したMicroTasksがかぶらないようにズラすのに使う
                        .background(
                            GeometryReader { proxy -> Color in
                                DispatchQueue.main.async {
                                    taskTitleHeight = proxy.frame(in: .local).size.height
                                }
                                return Color.clear
                            }
                        )
                        
                        // MicroTasks
                        ScrollView {
                            VStack {
                                // MicroTasks
                                ForEach(microTasks) { microTask in
                                    HStack(alignment: .center) {
                                        RoundedRectangle(cornerRadius: 40)
                                            .frame(width: 4, alignment: .top)
                                            .foregroundColor(.blue)
                                            .opacity(0.6)
                                            .fixedSize()
                                        
                                        HStack(alignment: .center, spacing: 5) {
                                            Text(microTask.microTask!)
                                                .font(.caption)
                                                .multilineTextAlignment(.leading)
                                                .layoutPriority(1)
                                                .opacity(1)
                                            
                                            Line()
                                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                                .frame(height: 1)
                                                .opacity(0.5)
                                            
                                            Text("\(microTask.timer / 60)m")
                                                .opacity(1)
                                                .font(.caption)
                                                .fixedSize()
                                                .padding(.trailing)
                                        }
                                    }
                                }
                                // mask避けるためのスペース
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 5)
                            }
                        }
                        
                        // 上から順にMicroTasksを表示をするにあたり、TaskBoxから見切れそうな部分をフェードアウトする
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors:
                                                    [Color.black,
                                                     Color.black,
                                                     Color.black,
                                                     Color.black,
                                                     Color.black,
                                                     Color.black,
                                                     Color.black.opacity(0)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        // frameのheightを超えた部分のmictoTask名が見切れるように.cornerRadiusを指定
                        //                            .cornerRadius(8)
                        // MicroTaskのScrollViewとTaskTitleをZStackで置いているため、Tasktitleとかぶらないようにズラす
                        // ZStackを使っている理由　→　TaskTitleの".minimumScaleFactor(0.5)"を使いたいため
                        .padding(.vertical, 5)
                        .offset(y: taskTitleHeight)
                        // .offSetでTaskTitle分をy方向にずらしているため、何もしないとTaskBoxからMicroTasksがTaskTitle分はみ出してしまう
                        // はみ出さないように、frameを指定している。 TaskBox - TaskTitleHeight
                        // MicroTaskがない場合は、「 - TaskTitleHeight 」でRuntime issueが起きてしまう
                        // MagnifyByが小さい場合、TaskTitleHeightがTaskBoxを上回ってしまうため。
                        // なので、microtaskがなければ、「 - TaskTitleHeight 」をしないように三項演算子で条件分岐してる
                        // absにしないとInvalid frame dimension (negative or non-finite).になる
                        .frame(height: task.microTasks!.count == 0 ? scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!) : abs(scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!) - taskTitleHeight), alignment: .top)
                        
                    }
                }
            }
            
        }
    }
}


