//
//  WeeklyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/28.
//

import SwiftUI

struct WeeklyCalender: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var tasks: FetchedResults<Task>
    init(selectedDate: Date) {
        _tasks = FetchRequest(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.startDate, ascending: true)],
            predicate: NSPredicate(format: "startDate >= %@ && endDate <= %@", Calendar.current.startOfDay(for: selectedDate) as CVarArg, Calendar.current.startOfDay(for: selectedDate + 86_400) as CVarArg)
        )
    }
    
    @State private var scrollViewHeight: CGFloat = CGFloat(0)
    
    
    @State private var timelineDividerWidth: CGFloat = CGFloat(0)
    
    @State private var magnifyBy: Double = 1.0
    @State private var lastMagnificationValue: Double = 1.0
    @State private var taskBlockheight: CGFloat = 0
    
    @State var lead: Int  = 0// 😜
    @State var top: Int = 0// 🎉
    @State var trail: Int = 0// 🧴
    @State var bottom: Int = 0// 💛
    
    @State private var isNavigation = false
    
    @State var selectedItem = Task()
    
    func isEnougEight(scrollViewHeight: CGFloat, startDate: Date, endDate: Date) -> (flag :Bool, sum :CGFloat) {
        let flag = (scrollViewHeight / 1_440 * dateToMinute(date: endDate)) - (scrollViewHeight / 1_440 * dateToMinute(date: startDate)) > 70
        let sum = scrollViewHeight / 1_440 * dateToMinute(date: endDate) - scrollViewHeight / 1_440 * dateToMinute(date: startDate)
        return (flag, sum)
        
    }

    
    var body: some View {
        
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
                                Text("\(String(format: "%02d", i)):00")
                                    .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                                    .opacity(0.5)
                                
                                // Divider
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.4))
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
                            .frame(height: 1.5 * 20 * magnifyBy, alignment: .top)
                            .frame(minHeight: 30, maxHeight: 1_125)
                            
                            // 拡大率に応じてXX:30, XX:15, XX:45の表示を追加
                            switch magnifyBy {
                            case 2...4:
                                ColonDelimitedTimeDivider(hour: i, time: 30, parentScrollViewHeight: scrollViewHeight)
                            case 4...50:
                                ColonDelimitedTimeDivider(hour: i, time: 30, parentScrollViewHeight: scrollViewHeight)
                                ColonDelimitedTimeDivider(hour: i, time: 15, parentScrollViewHeight: scrollViewHeight)
                                ColonDelimitedTimeDivider(hour: i, time: 45, parentScrollViewHeight: scrollViewHeight)
                            default:
                                EmptyView()
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                // MARK: ScrollViewの高さ取得と上乗せするコンテンツ
                .overlay(
                    ZStack(alignment: .topTrailing) {
                        NavigationLink(destination: TaskDetail(task: selectedItem), isActive: self.$isNavigation) {
                            EmptyView()
                        }
                        // Coredataからfetchしたdataをforで回して配置していく
                        ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                            // Task Title
                            
                            VStack(alignment: .leading) {
                                Text(task.task!)
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .bold()
                                // TODO: checkのsumの値に応じて、MicroTaskIntoWeeklyCalenderViewの下部を徐々にフェードインしていく
                                let _ = print(isEnougEight(scrollViewHeight: scrollViewHeight, startDate: task.startDate!, endDate: task.endDate!).sum)
                                if isEnougEight(scrollViewHeight: scrollViewHeight, startDate: task.startDate!, endDate: task.endDate!).flag {
                                    MicroTaskIntoWeeklyCalender(withChild: task)
                                }
                            }
                            // 余白を入れつつTaskのタイトルを表示する
                            .offset(x: 10, y: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!))
                            .frame(width: timelineDividerWidth, alignment: .leading)
                            .zIndex(1) // Pathより上に表示
                            
                            //                        MicroTaskDetailOnWeeklyCalender(
                            //                            withChild: task,
                            //                            scrollViewHeight: $scrollViewHeight,
                            //                            timelineDividerWidth: $timelineDividerWidth
                            //                        )
                            
                            
                            // Task Rectangle
                            Path { path in
                                path.move(to: CGPoint(x: UIScreen.main.bounds.maxX - timelineDividerWidth, y: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!)))
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.maxX, y: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!)))
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.maxX, y: scrollViewHeight / 1_440 * dateToMinute(date: task.endDate!)))
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.maxX - timelineDividerWidth, y: scrollViewHeight / 1_440 * dateToMinute(date: task.endDate!)))
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.maxX - timelineDividerWidth, y: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!)))
                            }
                            .fill(.mint)
                            .opacity(0.35)
                            .onTapGesture {
                                selectedItem = task
                                isNavigation.toggle()
                                
                            }
                            .simultaneousGesture(
                                LongPressGesture()
                                    .onEnded { _ in
                                        print("Loooong")
                                    }
                            )
                            .highPriorityGesture(
                                TapGesture(count: 2)
                                    .onEnded { _ in
                                        print("Double tap")
                                        // TODO: expand + scrollTo
//                                        magnifyBy = 30
                                    }
                            )
                            // TODO: tap(指を話さなくても)した時点で、TaskのTitleをnavigationtitleに表示する（拡大率が特定の場合のみ）
                            
                            
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

        
        // MARK: magnificationGestureの拡大率を利用してScrollViewをピンチイン・アウトする
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let changeRate = value / lastMagnificationValue
                    if magnifyBy > 30.0 {
                        magnifyBy = 30.0
                    } else if magnifyBy < 1.0 {
                        magnifyBy = 1.0
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
                .opacity(0.5)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.4))
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
        
        return WeeklyCalender(selectedDate: Date())
    }
}


