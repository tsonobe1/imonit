//
//  DailyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/28.
//

import SwiftUI

// 🖕When tapped at DailyCalender ScrollView
class NewTaskBoxData: ObservableObject {
    @Published var isActive = false
    
    @Published var selectedArea = Double.zero
    @Published var top = CGFloat.zero
    @Published var bottom = CGFloat.zero
    
    var greCal = Calendar(identifier: .gregorian)
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var minute = Int.zero
    @Published var forXMinutes = Int.zero
}

// TODO: DispatchQueue.main.asyncを解決しないとCPUが100%になる
//class DailyCalenderBasicGeometry: ObservableObject {
//    @Published var scrollViewHeight = CGFloat.zero
//    @Published var timelineDividerWidth = CGFloat.zero
//    @Published var magnifyBy = Double.zero
//    var aMinuteHeight: CGFloat {
//        scrollViewHeight / 1_440
//    }
//}

class WhenScrollingToTaskBox: ObservableObject {
    // For "toSctroll" When Double Tap Gesture
    @Published var scrollTarget: Int?
    // Fade in and out of ScrollView and task title
    @Published  var cheatFadeInOut: Bool = false
    enum FadeInOutState {
        case empty
        case first
        case second
    }
    @Published  var fadeState = FadeInOutState.empty
    @Published  var selectedText: String?
}

struct DailyCalender: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var tasks: FetchedResults<Task>
    var selectedDate: Date
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _tasks = FetchRequest(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.startDate, ascending: true)],
            predicate: NSPredicate(format: "startDate >= %@ && endDate <= %@", Calendar.current.startOfDay(for: selectedDate) as CVarArg, Calendar.current.startOfDay(for: selectedDate + 86_400) as CVarArg)
        )
    }
    
    // Observable Objects
    @StateObject private var newTaskBox = NewTaskBoxData()
    @StateObject private var toSctollBox = WhenScrollingToTaskBox()
    
    // DailyCalenderBasicGeometry
    @State private var magnifyBy: Double = 1.0 //
    @State private var scrollViewHeight: CGFloat = CGFloat(0) //
    @State private var timelineDividerWidth: CGFloat = CGFloat(0) // Get at Vertical24hTimeline //
    var aMinuteHeight: CGFloat { //
        scrollViewHeight / 1_440
    }
    
    // For Navigation When Tapped Task Box
    @State private var isNavigation = false // Navigation
    @State var selectedItem = Task() // Navigation
    
    // 🖕Long pressed at TaskBox
    @State private var isActiveVirtualTaskBox = false
    

    var body: some View {
        // 📜 => Scroll Contents
        // 🎁 => Task Box
        ZStack {
            ScrollViewReader { (scrollviewProxy: ScrollViewProxy) in
                ScrollView {
                    // 📜 MARK: Compartmentalize to allow programmatic scrolling
                    RectsToIdentifyTappedPosition(
                        newTaskBox: newTaskBox,
                        scrollViewHeight: scrollViewHeight,
                        magnifyBy: magnifyBy,
                        selectedDate: selectedDate
                    )
                    .overlay(
                        // 🎁 MARK: Add a TaskBox for new tasks when we tap the daily calender
                        NewTaskBoxOnCalender(
                            newTaskBox: newTaskBox,
                            timelineDividerWidth: timelineDividerWidth
                        ),
                        alignment: .topLeading
                    )
                    // scrollTargetが更新された時 = 既存のTackBoxがDouble tapされた時の処理
                    .onChange(of: toSctollBox.scrollTarget) { target in
                        if let target = target {
                            toSctollBox.scrollTarget = nil
                            print("scrollTargetの変更を感知しました, target: \(target)")
                            withAnimation {
                                scrollviewProxy.scrollTo(target, anchor: .top)
                            }
                        }
                    }
                    .overlay(
                        // 📜 MARK: Timeline 00:00~23:00
                        Vertical24hTimeline(
                            timelineDividerWidth: $timelineDividerWidth,
                            scrollViewHeight: scrollViewHeight,
                            magnifyBy: magnifyBy
                        )
                        .overlay(
                            // 📜 MARK: TaskBox to be added on top of ScrollView
                            // ScrollViewの高さ取得 + 上乗せするTask Boxs
                            ZStack(alignment: .topTrailing) {
                                NavigationLink(destination: TaskDetail(task: selectedItem), isActive: self.$isNavigation) {
                                    EmptyView()
                                }
                                // Coredataからfetchしたtasksをforで回して配置していく
                                ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                                    // 🎁 MARK: Task Box
                                    TaskBoxOnCalender(
                                        task: task,
                                        toSctollBox: toSctollBox,
                                        scrollViewHeight: $scrollViewHeight, // GEO
                                        timelineDividerWidth: $timelineDividerWidth, // GEO
                                        magnifyBy: $magnifyBy, // GEO
                                        selectedItem: $selectedItem, // Nav
                                        isNavigation: $isNavigation, // Nav
                                        isActiveVirtualTaskBox: $isActiveVirtualTaskBox
                                    )
                                }
                                
                                // 🎁 MARK: Long pressed Task Box
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
                            // 💡MARK: Current Time Bar
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
                .opacity(toSctollBox.cheatFadeInOut ? 0 : 1)
            }
            .toolbar {
                // MARK: 拡大率が30じゃなくなった & scrollTarget(int)がtaskの範囲から外れたら、Text("")にする
                ToolbarItem(placement: .principal) {
                    if toSctollBox.fadeState == .second  && magnifyBy == 30{
                        Text(toSctollBox.selectedText!)
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
            if toSctollBox.fadeState == .first {
                if let wrappedText = toSctollBox.selectedText {
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
                    }
                    )
                }
            }
        }
    }
}


//struct DailyCalender_Previews: PreviewProvider {
//    static var previews: some View {
//        let result: PersistenceController = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//        // task
//        let newTask = Task(context: viewContext)
//        newTask.task = "Quis nostrud exercitation ullamco"
//        newTask.isDone = false
//        newTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
//        newTask.createdAt = Date()
//        newTask.id = UUID()
//        newTask.startDate = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!
//        newTask.endDate = Calendar.current.date(bySettingHour: 11, minute: 00, second: 0, of: Date())!
//        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
//        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"
//
//        // micro task
//        let newMicroTask = MicroTask(context: viewContext)
//        newMicroTask.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
//        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
//        newMicroTask.id = UUID()
//        newMicroTask.isDone = false
//        newMicroTask.timer = 10
//        newMicroTask.createdAt = Date()
//        newMicroTask.order = 0
//        newMicroTask.satisfactionPredict = 5
//        newMicroTask.satisfactionPredict = 5
//        newMicroTask.task = newTask
//
//        let newMicroTask2 = MicroTask(context: viewContext)
//        newMicroTask2.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
//        newMicroTask2.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
//        newMicroTask2.id = UUID()
//        newMicroTask2.isDone = false
//        newMicroTask2.timer = 10
//        newMicroTask2.createdAt = Date()
//        newMicroTask2.order = 0
//        newMicroTask2.satisfactionPredict = 5
//        newMicroTask2.satisfactionPredict = 5
//        newMicroTask2.task = newTask
//
//        // task2
//        let newTask2 = Task(context: viewContext)
//        newTask2.task = "Quis2 nostrud exercitation ullamco"
//        newTask2.isDone = false
//        newTask2.detail = "Lorem2 ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
//        newTask2.createdAt = Date()
//        newTask2.id = UUID()
//        newTask2.startDate = Calendar.current.date(bySettingHour: 14, minute: 45, second: 0, of: Date())!
//        newTask2.endDate = Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!
//        newTask2.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
//        newTask2.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"
//
//        return DailyCalender(selectedDate: Date())
//    }
//}
