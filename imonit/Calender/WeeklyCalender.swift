//
//  WeeklyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/28.
//

import SwiftUI

struct WeeklyCalender: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.startDate, ascending: true)],
        predicate: NSPredicate(format: "startDate >= %@ && endDate <= %@", Calendar.current.startOfDay(for: Date()) as CVarArg, Calendar.current.startOfDay(for: Date() + 86_400) as CVarArg),
        animation: .default
    )
    var tasks: FetchedResults<Task>

    @State private var selectedDate: Date = Date()
    
    @State private var scrollViewHeight: CGFloat = CGFloat(0)
    @State private var timelineDividerWidth: CGFloat = CGFloat(0)

    @State private var magnifyBy: Double = 1.0
    @State private var lastMagnificationValue: Double = 1.0

    var body: some View {

        ZStack(alignment: .top) {

            // MARK: 背景の時間軸を表示するScrollView
            ScrollView(.vertical, showsIndicators: false) {
                // ScrollViewのコンテンツ同士のスペースを0にするためだけのvStack
                // spacing:0のVStackを置かないと、overrideするコンテンツの位置がずれる
                VStack(spacing: 0) {
                    ForEach(0..<24) { i in
                        ZStack(alignment: .topLeading) {
                            // XX:XXとDivider
                            HStack {
                                // 一桁の数値の先頭に0を付ける
                                //                                Text("\(timelineDividerWidth)")
                                Text("\(String(format: "%02d", i)):00")
                                    .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))                                    .opacity(0.6)

                                // Divider
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .coordinateSpace(name: "timelineDivider")
                                    // Eventのブロックの横幅とdividerの長さを一致させるために必要
                                    .overlay(
                                            GeometryReader { proxy -> Color in
                                                DispatchQueue.main.async {
                                                    timelineDividerWidth = proxy.frame(in: .named("timelineDivider")).size.width
                                                }
                                                return Color.clear
                                            }
                                    )
                            }
                            // ズレ修正
                            .offset(y: -7)
                            // 1h分の列幅
                            .frame(height: 2 * 20 * magnifyBy, alignment: .top)
                            .frame(minHeight: 40, maxHeight: 1_200)

                            // 拡大率に応じてXX:30, XX:15, XX:45の表示を追加
                            switch magnifyBy {
                            case 2...4:
                                ColonDelimitedTimeDivider(hour: i, time: 30, parentScrollViewHeight: scrollViewHeight)
                            case 4...35:
                                ColonDelimitedTimeDivider(hour: i, time: 30, parentScrollViewHeight: scrollViewHeight)
                                ColonDelimitedTimeDivider(hour: i, time: 15, parentScrollViewHeight: scrollViewHeight)
                                ColonDelimitedTimeDivider(hour: i, time: 45, parentScrollViewHeight: scrollViewHeight)
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
                // MARK: ScrollViewの高さ取得と上乗せするコンテンツ
                .overlay(
                    ZStack(alignment: .topTrailing) {

                        // Eventの配置
                        // Coredataからfetchしたdataをforで回して配置していく
                        // 以下サンプル
                        ForEach(tasks) { task in
                            VStack(spacing: 0) {
                                NavigationLink(destination: TaskDetail(task: task)) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(
                                        width: timelineDividerWidth,
                                        height: scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!)
                                        
                                    )
                                    .foregroundColor(.mint.opacity(0.8))
                                    .overlay(
                                        NavigationLink(destination: TaskDetail(task: task)) {
                                            Group {
                                                VStack {
                                                    Text("\(task.task!)")
                                                }
                                            }
                                            .foregroundColor(.primary)
                                            .font(.headline)
                                        }
                                    )
                                }
                            }
                            .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!))
                        }
                        // ScrollViewの(コンテンツを含めた)高さをGeometryReaderで取得
                        // この高さを1440(24h)で割って標準化した値を使うことで、
                        // EventやXX:15などの時間表示を、ScrollViewの上に配置しやすくする
                        GeometryReader { proxy -> Color in
                            DispatchQueue.main.async {
                                scrollViewHeight = proxy.frame(in: .global).size.height
                            }
                            return Color.clear
                        }
                    }
                )
            }
        }

        // MARK: magnificationGestureの拡大率を利用してScrollViewをピンチイン・アウトする
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let maxScale: CGFloat = 20.0
                    let minScale: CGFloat = 1.0

                    let changeRate = value / lastMagnificationValue
                    if magnifyBy > maxScale {
                        magnifyBy = maxScale
                    } else if magnifyBy < minScale {
                        magnifyBy = minScale
                    } else {
                        magnifyBy *= changeRate
                    }
                    lastMagnificationValue = value
                }
                .onEnded { _ in
                    lastMagnificationValue = 1.0
                }
        )
    }

    func dateToMinute(date: Date) -> CGFloat {
//        print("dateToMinuteが何度も実行されてしまう問題を解決したい")
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
//        print("🫲 Convert Minute : \((hour * 60) + minute)")
        return CGFloat((hour * 60) + minute)
    }

    func caluculateTimeInterval(startDate: Date, endDate: Date) -> CGFloat {
        let timeInterval = endDate.timeIntervalSince(startDate)
//        print("👉 TimeInterval : \(timeInterval / 60)")
        return CGFloat(timeInterval / 60)
    }
}

// Colon-delimited time display
private struct ColonDelimitedTimeDivider: View {
    var hour: Int
    var time: Int
    var parentScrollViewHeight: CGFloat

    var body: some View {
        HStack {
            Text("\(String(format: "%02d", hour)):\(time)")
                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                .opacity(0.6)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .offset(y: -7 + (parentScrollViewHeight / 1_440 * CGFloat(time)))
        .transition(.opacity)
    }
}

struct WeeklyCalender_Previews: PreviewProvider {
    static var previews: some View {
        let result: PersistenceController = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // task
        let newTask = Task(context: viewContext)
        newTask.task = "Quis nostrud exercitation ullamco"
        newTask.isDone = false
        newTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newTask.createdAt = Date()
        newTask.id = UUID()
        newTask.startDate = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!
        newTask.endDate = Calendar.current.date(bySettingHour: 11, minute: 00, second: 0, of: Date())!
        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"

        // micro task
        let newMicroTask = MicroTask(context: viewContext)
        newMicroTask.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 10
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.satisfactionPredict = 5
        newMicroTask.satisfactionPredict = 5
        newMicroTask.task = newTask

        let newMicroTask2 = MicroTask(context: viewContext)
        newMicroTask2.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask2.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask2.id = UUID()
        newMicroTask2.isDone = false
        newMicroTask2.timer = 10
        newMicroTask2.createdAt = Date()
        newMicroTask2.order = 0
        newMicroTask2.satisfactionPredict = 5
        newMicroTask2.satisfactionPredict = 5
        newMicroTask2.task = newTask

        // task2
        let newTask2 = Task(context: viewContext)
        newTask2.task = "Quis2 nostrud exercitation ullamco"
        newTask2.isDone = false
        newTask2.detail = "Lorem2 ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newTask2.createdAt = Date()
        newTask2.id = UUID()
        newTask2.startDate = Calendar.current.date(bySettingHour: 14, minute: 45, second: 0, of: Date())!
        newTask2.endDate = Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!
        newTask2.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask2.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"

        return WeeklyCalender()
    }
}
