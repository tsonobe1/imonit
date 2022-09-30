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
    
    // For Navigation When Tapped Task Box
    @State private var isNavigation = false
    @State var selectedItem = Task()
    
    // For "toSctroll" When Double Tap Gesture
    @State private var scrollTarget: Int?
    @State private var taskBoxheight: CGFloat = 0
    
    // For FadeIn-Out Which ScrollView And Task Title
    @State private var cheatFadeInOut: Bool = false
    enum FadeInOutState {
        case empty
        case first
        case second
    }
    @State private var fadeState = FadeInOutState.empty
    @State private var selectedText: String?

    
    // 🖕 Pinch in When Double Tap Gesture
    fileprivate func findOrderOfTaskBoxUpperSide(_ task: FetchedResults<Task>.Element) {
        let taskBoxHeight = scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!)
        let compartmentalizedOrder = taskBoxHeight / (30 * magnifyBy / 12)
        let roundDown = Int(floor(compartmentalizedOrder))
        scrollTarget = roundDown
    }
    fileprivate func pinchInAndToSctrollDoubleTap(_ task: FetchedResults<Task>.Element) -> _EndedGesture<TapGesture> {
        TapGesture(count: 2)
            .onEnded { _ in
                if magnifyBy != 30 {
                    // ScrollViewの拡大率を30にして拡大 -> Scrollが上辺に戻る
                    magnifyBy = 30
                    cheatFadeInOut = true // Scrollのopacity操作をしておかしな挙動を隠す(誤魔化し用フェードイン・アウト)
                    // View中央にTask名を表示
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        fadeState = .first
                        selectedText = task.task
                    }
                    // 0.2秒後にダブルタップしたtaskBoxまでスクロール
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            findOrderOfTaskBoxUpperSide(task)
                        }
                        // 0.1秒後の更に0.3秒後にScrollのopacityを戻す
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                cheatFadeInOut = false
                            }
                        }
                    }
                    // 0.8秒後にView中央にTask名を消す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(Animation.easeInOut) {
                            fadeState = .second
                        }
                    }
                } else {
                    // ダブルタップ時にmagnifByが30だった場合
                    findOrderOfTaskBoxUpperSide(task)
                }
            }
    }
    
    // 🖕Long pressed
    @State private var isActiveVirtualTaskBox = false
    fileprivate func enableVirtualTaskBox(_ task: FetchedResults<Task>.Element) -> _EndedGesture<LongPressGesture> {
        return LongPressGesture()
            .onEnded { _ in
                selectedItem = task
                withAnimation {
                    isActiveVirtualTaskBox.toggle()
                    // 触覚フィードバック
                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                    impactHeavy.impactOccurred()
                }
            }
    }
    
    
    var body: some View {
        ZStack {
            ScrollViewReader { (scrollviewProxy: ScrollViewProxy) in
                ScrollView {
                    // MARK: Compartmentalization of ScrollView to programmatically scrollable
                    // ScrollViewに透明のRectを敷き詰めることで、Tapした位置のRectの順番を割り出し、プログラム的にtoScrollできるようにする
                    VStack(spacing: 0) {
                        ForEach(0..<288, id: \.self) { obj in
                            ZStack {
                                Rectangle()
                                    .stroke(.blue)
                                    .frame(height: 30 * magnifyBy / 12, alignment: .top)
                                    .id(obj)
                            }
                        }
                    }
                    // scrollTargetが更新された時 = TackBoxがDouble tapされた時の処理
                    .onChange(of: scrollTarget) { target in
                        if let target = target {
                            scrollTarget = nil
                            print("scrollTargetの変更を感知しました, target: \(target)")
                            withAnimation {
                                scrollviewProxy.scrollTo(target, anchor: .top)
                            }
                        }
                    }
                    .overlay(
                        // MARK: Timeline 00:00~23:00
                        // ScrollViewのコンテンツ同士のスペースを0にするためだけのvStack
                        // spacing:0のVStackを置かないと、overrideするコンテンツの位置がずれる
                        VStack(spacing: 0) {
                            ForEach(0..<24) { i in
                                ZStack(alignment: .topLeading) {
                                    // XX:XXとDivider
                                    HStack {
                                        // 一桁の数値の先頭に0を付ける
                                        Text("\(String(format: "%02d", i)):00")
                                        // 数字のweightを固定化してcomputed propertyが無限ループに陥らないようにする
                                            .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                                            .opacity(0.8)
                                        
                                        // Divider
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.secondary.opacity(0.3))
                                            .coordinateSpace(name: "timelineDivider")
                                        // Eventのブロックの横幅とdividerの長さを一致させるために取得しておく
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
                                        ColonDelimitedTimeDivider(hour: i, time: 30, scrollViewHeight: scrollViewHeight)
                                    case 4...50:
                                        ColonDelimitedTimeDivider(hour: i, time: 30, scrollViewHeight: scrollViewHeight)
                                        ColonDelimitedTimeDivider(hour: i, time: 15, scrollViewHeight: scrollViewHeight)
                                        ColonDelimitedTimeDivider(hour: i, time: 45, scrollViewHeight: scrollViewHeight)
                                    default:
                                        EmptyView()
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                        }
                            .overlay(
                                // MARK: TaskBox to be added on top of ScrollView
                                // ScrollViewの高さ取得 + 上乗せするTask Boxs
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink(destination: TaskDetail(task: selectedItem), isActive: self.$isNavigation) {
                                        EmptyView()
                                    }
                                    // Coredataからfetchしたtasksをforで回して配置していく
                                    ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                                        // 🐦 Task Title & Detail
                                        Group {
                                            // 🧱 Tack Box
                                            TaskBoxPath(
                                                radius: 5,
                                                top: scrollViewHeight / 1_440 * dateToMinute(date: task.startDate!),
                                                bottom: scrollViewHeight / 1_440 * dateToMinute(date: task.endDate!),
                                                leading: UIScreen.main.bounds.maxX - timelineDividerWidth,
                                                traling: UIScreen.main.bounds.maxX
                                            )
                                            .fill(Color.orange)
                                            .opacity(0.35)
                                            
                                            // 📛 Task, MicroTask
                                            TaskOnBox(
                                                withChild: task,
                                                scrollViewHeight: $scrollViewHeight,
                                                timelineDividerWidth: $timelineDividerWidth,
                                                magnifyBy: $magnifyBy
                                            )
                                        }
                                        .onTapGesture {
                                            selectedItem = task
                                            isNavigation.toggle()
                                        }
                                        .simultaneousGesture(
                                            enableVirtualTaskBox(task)
                                        )
                                        .highPriorityGesture(
                                            pinchInAndToSctrollDoubleTap(task)
                                        )
                                    }
                                    
                                    // MARK: Long pressed Task Box
                                    if isActiveVirtualTaskBox {
                                        // Longpress後の値変更用TaskBox
                                        VirtualTaskBox(
                                            scrollViewHeight: scrollViewHeight,
                                            timelineDividerWidth: timelineDividerWidth,
                                            selectedItem: selectedItem,
                                            isActiveVirtualTaskBox: $isActiveVirtualTaskBox,
                                            magnifyBy: $magnifyBy
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
                                // MARK: Current Time Bar
                                    .overlay(
                                        CurrentTimeBar(scrollViewHeight: scrollViewHeight),
                                        alignment: .topLeading
                                    )
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
            //            .gesture(
            //                MagnificationGesture()
            //                    .onChanged { value in
            //                        let changeRate = value / lastMagnificationValue
            //                        if magnifyBy > 30.0 {
            //                            magnifyBy = 30.0
            //                        } else if magnifyBy < 1.0 {
            //                            magnifyBy = 1.0
            //                        } else {
            //                            magnifyBy *= changeRate
            //                        }
            //                        lastMagnificationValue = value
            //                        print(magnifyBy)
            //                    }
            //                    .onEnded { _ in
            //                        lastMagnificationValue = 1.0
            //                    }
            //            )
            .toolbar {
                // MARK: 拡大率が30じゃなくなった & scrollTarget(int)がtaskの範囲から外れたら、Text("")にする
                ToolbarItem(placement: .principal) {
                    if fadeState == .second  && magnifyBy == 30{
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
            // 一時的に画面中央にTask名を表示する
            if fadeState == .first {
                if let wrappedText = selectedText {
                    Text(String(wrappedText))
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                        .padding()
                }
            }
            // Floating button
            VStack {  // --- 1
                Spacer()
                HStack { // --- 2
                    Spacer()
                    Button(action: {
                        withAnimation(.linear){
                            switch magnifyBy {
                            case 1:
                                magnifyBy = 2
                            case 2:
                                magnifyBy = 5
                            case 5:
                                magnifyBy = 10
                            default:
                                magnifyBy = 1
                            }
                        }
                    }, label: {
                        Text("× \(Int(magnifyBy))")
                            .foregroundColor(.primary)
                            .font(.system(size: 16)) // --- 4
                            .frame(width: 54, height: 54)
                            .background(
                                Circle()
                                    .fill(Color.secondary)
                                    .opacity(0.5)
                            )
                            .cornerRadius(30.0)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0)) // --- 5
                    })
                }
            }
        }
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
