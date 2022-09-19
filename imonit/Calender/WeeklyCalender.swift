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
    
    // For ScrollView Magnify Rate
    @State private var magnifyBy: Double = 1.0
    @State private var lastMagnificationValue: Double = 1.0
    
    // For Navigation When Tapped Task Block
    @State private var isNavigation = false
    @State var selectedItem = Task()
    
    // For "toSctroll" When Double Tap Gesture
    @State private var scrollTarget: Int?
    @State private var taskBlockheight: CGFloat = 0
    
    // For FadeIn-Out Which ScrollView And Task Title
    @State private var cheatFadeInOut: Bool = false
    enum FadeInOutState {
        case empty
        case first
        case second
    }
    @State private var fadeState = FadeInOutState.empty
    @State private var selectedText: String?
    
    //
    @State var lead: Int  = 0
    @State var top: Int = 0
    @State var trail: Int = 0
    @State var bottom: Int = 0
    
    func isEnougEight(scrollViewHeight: CGFloat, startDate: Date, endDate: Date) -> (flag: Bool, sum: CGFloat) {
        let flag = (scrollViewHeight / 1_440 * dateToMinute(date: endDate)) - (scrollViewHeight / 1_440 * dateToMinute(date: startDate)) > 70
        let sum = scrollViewHeight / 1_440 * dateToMinute(date: endDate) - scrollViewHeight / 1_440 * dateToMinute(date: startDate)
        return (flag, sum)
        
    }
    
    
    var body: some View {
        ZStack {
            // MARK: toScrollの移動先を設けるためのView
            ScrollViewReader { (scrollviewProxy2: ScrollViewProxy) in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<144, id: \.self) { obj in
                            ZStack {
                                Rectangle()
                                    .stroke(.clear)
                                    .frame(height: 30 * magnifyBy / 6, alignment: .top)
                                    .id(obj)
                            }
                        }
                    }
                    .onChange(of: scrollTarget) { target in
                        if let target = target {
                            scrollTarget = nil
                            print("scrollTargetの変更を感知しました, target: \(target)")
                            withAnimation {
                                scrollviewProxy2.scrollTo(target, anchor: .top)
                            }
                        }
                    }
                    // overlay
                    .overlay(
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
                                    .frame(height: 30 * magnifyBy, alignment: .top)
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
                                        // 🐦 Task Title
                                        if magnifyBy == 30 {
                                            MicroTaskDetailOnWeeklyCalender(
                                                withChild: task,
                                                scrollViewHeight: $scrollViewHeight,
                                                timelineDividerWidth: $timelineDividerWidth
                                            )
                                        } else {
                                            VStack(alignment: .leading) {
                                                HStack(alignment: .top) {
                                                    RoundedRectangle(cornerRadius: 40)
                                                        .frame(
                                                            width: 4,
                                                            height: scrollViewHeight / 1_440 * caluculateTimeInterval(startDate: task.startDate!, endDate: task.endDate!),
                                                            alignment: .topLeading
                                                        )
                                                        .foregroundColor(.mint)
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
                                            .zIndex(1) // Pathより上に表示
                                        }
                                        
                                        // ⬜️ Tack BLocks
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
                                            // MARK: 🖕 Pinch in When Double Tap Gesture
                                            TapGesture(count: 2)
                                                .onEnded { _ in
                                                    print("Double tap")
                                                    
                                                    if magnifyBy != 30 {
                                                        magnifyBy = 30
                                                        // tap時にmagnifyが30じゃなかった場合、スクロールのバグを隠すための誤魔化し用フェードアウト・イン
                                                        cheatFadeInOut = true
                                                        
                                                        //
                                                        //
                                                        // 💬 スクロールを隠している間にView前景にタスク名を表示するためのFlag (enum)
                                                        //
                                                        //
                                                        withAnimation(Animation.easeInOut(duration: 0.1)) {
                                                            fadeState = .first
                                                            selectedText = task.task // fadeState = .second時にnavigationにタイトルを表示する用
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                            withAnimation(Animation.easeInOut) {
                                                                fadeState = .second // 前景のタスク名をフェードアウトしてnavigationにタイトルを表示
                                                            }
                                                        }
                                                        
                                                        //
                                                        //
                                                        // 🫥 magnifyByによる拡大でScrollViewがTopに戻ってからtoScrollで移動するのでアニメーションが狂う
                                                        // 🫥 そのため、スクロールの間(asyncAfter)、opacityを0にして隠している
                                                        //
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                            let taskBlockHeight = scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!)
                                                            let banme = taskBlockHeight / (30 * magnifyBy / 6)
                                                            let intBanme = Int(floor(banme))
                                                            withAnimation {
                                                                scrollTarget = intBanme
                                                            }
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                withAnimation {
                                                                    cheatFadeInOut = false
                                                                }
                                                            }
                                                        }
                                                        // magnifyByが30だった場合、ScrollViewのフェードイン・アウトはしない
                                                    } else {
                                                        let taskBlockHeight = scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!)
                                                        let banme = taskBlockHeight / (30 * magnifyBy / 6)
                                                        let intBanme = Int(floor(banme))
                                                        scrollTarget = intBanme
                                                    }
                                                }
                                        )
                                        
                                        
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
                    )
                }
                .coordinateSpace(name: "scroll")
                .transaction { transaction in
                    transaction.animation = nil
                }
                .opacity(cheatFadeInOut ? 0 : 1)
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
            .toolbar {
                // TODO: 拡大率が30じゃなくなった & scrollTarget(int)がtaskの範囲から外れたら、Text("")にする
                ToolbarItem(placement: .principal) {
                    if fadeState == .second {
                        Text(selectedText!)
                            .font(.footnote)
                            .bold()
                            .lineLimit(1)
                            .transition(.opacity)
                    } else {
                        Text("")
                    }
                }
            }
            if fadeState == .first {
                if let wrappedText = selectedText {
                    Text(String(wrappedText))
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                        .padding()
                }
            }
        }
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
