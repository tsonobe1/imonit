//
//  VirtualTaskBox.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/29.
//

import SwiftUI

struct VirtualTaskBox: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var ScrollViewItSelfHeight: CGFloat
    var scrollViewHeight: CGFloat
    var scrollViewWidth: CGFloat
    var timelineDividerWidth: CGFloat
    let selectedItem: Task
    let selectedDate: Date
    @Binding var isActiveVirtualTaskBox: Bool
    @Binding var isMovingVirtualTaskBox: Bool
    @Binding var magnifyBy: Double
    
    @State private var diffUpperSidePosition = CGFloat.zero
    @State private var diffStartDateAsMinutes = Int.zero
    @State private var diffLowerSidePosition = CGFloat.zero
    @State private var diffEndDateAsMinutes = Int.zero
    @State private var diffPosition = CGFloat.zero
    
    @State private var diffDateAsMinutes = Int.zero
    @State private var diffLeftPosition = CGFloat.zero
    @State private var diffRightPosition = CGFloat.zero
    
    @State private var isOnOutsideTop = false
    @State private var isOnOutsideBottom = false
    @State private var isOnOutsideLeft = false
    @State private var isOnOutsideRight = false
    
    @State private var modifiedStartDate = Date()
    @State private var modifiedEndDate = Date()
    @State private var startDayIsSame = true
    @State private var endDayIsSame = true
    
    var isNotAcceptTaskBoxDragChanges: Bool {
        !startDayIsSame || !endDayIsSame || isOnOutsideLeft || isOnOutsideRight
    }
    
    // 移動したPosition(CGFloat) = aと、移動した時間(分) = bを返す
    func floorWithMultiple(_ movePosition: CGFloat, _ positionsMultiple: CGFloat, _ datesMultiple: Double) -> (movedPosition: CGFloat, movedMinute: Int) {
        let x = movePosition / positionsMultiple
        let y = floor(x)
        let a = y * positionsMultiple
        let b = Int(y * datesMultiple)
        return (a, b)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            let _ = print("isNotAcceptTaskBoxDragChanges: \(isNotAcceptTaskBoxDragChanges)")
            TaskBoxShape(
                radius: 5,
                top: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + diffUpperSidePosition + diffPosition,
                bottom: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + diffLowerSidePosition + diffPosition,
                leading: scrollViewWidth - timelineDividerWidth + diffLeftPosition,
                traling: scrollViewWidth + diffRightPosition
            )
            .fill(isNotAcceptTaskBoxDragChanges ? .gray : .orange)
            .opacity(0.5)
            // Box移動時に拡大率に応じたバイブレーションを起こす
            .onChange(of: modifiedStartDate){ value in
                switch magnifyBy {
                case 1.0:
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                case 2.0:
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                case 5.0:
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                case 10.0, 30.0:
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                default:
                    print("impact default")
                }
            }
            .gesture(
                // Position
                DragGesture()
                    .onChanged { value in
                        isMovingVirtualTaskBox = true
                        var movePosition: CGFloat = CGFloat.zero
                        movePosition = value.translation.height
                        
                        // 拡大率に応じた値で切り捨てされた移動量と移動時間(分)を、flooredに入れる
                        var floored = floorWithMultiple(movePosition, 7.5, 15)
                        switch magnifyBy {
                        case 1.0: floored = floorWithMultiple(movePosition, 7.5, 15)
                        case 2.0: floored = floorWithMultiple(movePosition, 15, 15)
                        case 2.5: floored = floorWithMultiple(movePosition, 18.87, 15)
                        case 5.0: floored = floorWithMultiple(movePosition, 12.5, 5)
                        case 10.0: floored = floorWithMultiple(movePosition, 5, 1)
                        case 30.0: floored = floorWithMultiple(movePosition, 15, 1)
                        default: print("What?")
                        }
                        diffPosition = floored.movedPosition
                        diffDateAsMinutes = floored.movedMinute
                        diffLeftPosition = value.translation.width
                        diffRightPosition = value.translation.width

                        modifiedStartDate = Calendar.current.date(byAdding: .minute, value: diffDateAsMinutes, to: selectedItem.startDate!)!
                        modifiedEndDate = Calendar.current.date(byAdding: .minute, value: diffDateAsMinutes, to: selectedItem.endDate!)!
                        startDayIsSame = selectedDate.isSameDay(otherDay: modifiedStartDate)
                        endDayIsSame = selectedDate.isSameDay(otherDay: modifiedEndDate)
                    }
                    .onEnded { _ in
                        if isNotAcceptTaskBoxDragChanges{
                            diffPosition = CGFloat.zero
                            diffDateAsMinutes = Int.zero
                            isActiveVirtualTaskBox.toggle()
                            isMovingVirtualTaskBox.toggle()
                        } else {
                            do {
                                selectedItem.startDate = modifiedStartDate
                                selectedItem.endDate = modifiedEndDate
                                try viewContext.save()
                                
                                diffPosition = CGFloat.zero
                                diffDateAsMinutes = Int.zero
                                isActiveVirtualTaskBox.toggle()
                                isMovingVirtualTaskBox.toggle()
                            } catch let error as NSError {
                                print("\(error), \(error.userInfo)")
                            }
                        }
                    }
            )
            // ScrollView(Contentを含まない)の4辺にある程度近づくと、フラグを立てる用のGesture
            // simultaneousGestureにすることで、TaskBoxを移動するためのDragGestureと同時に機能させる
            .simultaneousGesture(
                DragGesture(coordinateSpace: .named("parentSpace"))
                    .onChanged{ value in
                        if value.location.y <= 30.0 {
                            isOnOutsideTop = true
                        }else if value.location.y > 30.0 {
                            isOnOutsideTop = false
                        }
                        
                        if value.location.y >= ScrollViewItSelfHeight - 30.0{
                            isOnOutsideBottom = true
                        }else if value.location.y < ScrollViewItSelfHeight - 30.0 {
                            isOnOutsideBottom = false
                        }
                        
                        if value.location.x <= 30.0 {
                            isOnOutsideLeft = true
                        }else if value.location.x > 30.0 {
                            isOnOutsideLeft = false
                        }
                        
                        if value.location.x >= scrollViewWidth - 30.0{
                            isOnOutsideRight = true
                        }else if value.location.x < scrollViewWidth - 30.0 {
                            isOnOutsideRight = false
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        withAnimation {
                            isActiveVirtualTaskBox.toggle()
                        }
                    }
            )
            Group {
                // 🕛 StartDateの時間軸
                HStack(alignment: .center) {
                    ZStack {
                        Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: diffStartDateAsMinutes + diffDateAsMinutes - 30, to: selectedItem.startDate!)!))
                            .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                            .opacity(1)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.6)
                            )
                            .offset(y: -15.0 * magnifyBy)
                        
                        Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: diffStartDateAsMinutes + diffDateAsMinutes, to: selectedItem.startDate!)!))
                            .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                            .opacity(1)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.6)
                            )
                    }
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [5]))
                        .fill(.red)
                        .frame(height: 1)
                        .opacity(0.6)
                }
                .foregroundColor(.red)
                .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + diffUpperSidePosition - 6 + diffPosition)
                
                // 🕛 EndDateの時間軸
                HStack(alignment: .center) {
                    Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: diffEndDateAsMinutes + diffDateAsMinutes, to: selectedItem.endDate!)!))
                        .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                        .opacity(1)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.ultraThinMaterial)
                                .opacity(0.6)
                        )
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [5]))
                        .fill(.red)
                        .frame(height: 1)
                        .opacity(0.6)
                }
                .foregroundColor(.red)
                .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + diffLowerSidePosition - 7 + diffPosition)
            }
            
            // 🤐 StartDateの移動バー
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondary)
                .opacity(1)
                .frame(width: 30, height: 30)
                .offset(
                    x: timelineDividerWidth + diffRightPosition,
                    y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + diffUpperSidePosition - 30 + diffPosition
                )
                .gesture(
                    DragGesture(coordinateSpace: .named("scroll")) // Scroll View
                        .onChanged { value in
                            var floored = floorWithMultiple(value.translation.height, 7.5, 15)
                            switch magnifyBy {
                            case 1.0: floored = floorWithMultiple(value.translation.height, 7.5, 15)
                            case 2.0: floored = floorWithMultiple(value.translation.height, 15, 15)
                            case 2.5: floored = floorWithMultiple(value.translation.height, 18.87, 15)
                            case 5.0: floored = floorWithMultiple(value.translation.height, 12.5, 5)
                            case 10.0: floored = floorWithMultiple(value.translation.height, 5, 1)
                            case 30.0: floored = floorWithMultiple(value.translation.height, 15, 1)
                            default:
                                print("What?")
                            }
                            diffUpperSidePosition = floored.movedPosition
                            diffStartDateAsMinutes = floored.movedMinute
                            
                            modifiedStartDate = Calendar.current.date(byAdding: .minute, value: diffStartDateAsMinutes, to: selectedItem.startDate!)!
                            startDayIsSame = selectedDate.isSameDay(otherDay: modifiedStartDate)
                        }
                        .onEnded { _ in
                            if !startDayIsSame {
                                diffUpperSidePosition = CGFloat.zero
                                diffStartDateAsMinutes = Int.zero
                                isActiveVirtualTaskBox.toggle()
                            } else {
                            do {
                                print("startDate: \(selectedItem.startDate!)")
                                let modifiedDate = Calendar.current.date(byAdding: .minute, value: diffStartDateAsMinutes, to: selectedItem.startDate!)!
                                // StartDateの移動バーを、EndDateの移動バーより下に持ってった場合は、.saveしない
                                if selectedItem.endDate! > modifiedDate {
                                    selectedItem.startDate = modifiedDate
                                    try viewContext.save()
                                }

                                diffUpperSidePosition = CGFloat.zero
                                diffStartDateAsMinutes = Int.zero
                                isActiveVirtualTaskBox.toggle()
                            } catch let error as NSError {
                                print("\(error), \(error.userInfo)")
                            }
                            }
                        }
                )
            // scrollView上でDragGestureがしやすくなる
                .simultaneousGesture(
                    LongPressGesture()
                        .onEnded { _ in
                        }
                )
            // 🤐 EndDateの移動バー
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondary)
                .opacity(0.6)
                .frame(width: 30, height: 30)
                .offset(
                    x: scrollViewWidth - timelineDividerWidth + diffLeftPosition,
                    y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + diffLowerSidePosition + diffPosition
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // ドラッグ中の処理
                            var floored = floorWithMultiple(value.translation.height, 7.5, 15)
                            switch magnifyBy {
                            case 1.0: floored = floorWithMultiple(value.translation.height, 7.5, 15)
                            case 2.0: floored = floorWithMultiple(value.translation.height, 15, 15)
                            case 2.5: floored = floorWithMultiple(value.translation.height, 18.87, 15)
                            case 5.0: floored = floorWithMultiple(value.translation.height, 12.5, 5)
                            case 10.0: floored = floorWithMultiple(value.translation.height, 5, 1)
                            case 30.0: floored = floorWithMultiple(value.translation.height, 15, 1)
                            default:
                                print("What?")
                            }
                            diffLowerSidePosition = floored.movedPosition
                            diffEndDateAsMinutes = floored.movedMinute
                            
                            modifiedStartDate = Calendar.current.date(byAdding: .minute, value: diffEndDateAsMinutes, to: selectedItem.endDate!)!
                            endDayIsSame = selectedDate.isSameDay(otherDay: modifiedStartDate)
                        }
                        .onEnded { _ in
                            if !endDayIsSame {
                                diffLowerSidePosition = CGFloat.zero
                                diffEndDateAsMinutes = Int.zero
                                isActiveVirtualTaskBox.toggle()
                            } else {
                            do {
                                print("startDate: \(selectedItem.endDate!)")
                                let modifiedDate = Calendar.current.date(byAdding: .minute, value: diffEndDateAsMinutes, to: selectedItem.endDate!)!
                                // EndDateの移動バーを、StartDateの移動バーより上に持ってった場合は、.saveしない
                                if selectedItem.startDate! < modifiedDate {
                                    selectedItem.endDate = modifiedDate
                                    try viewContext.save()
                                }
                                diffLowerSidePosition = CGFloat.zero
                                diffEndDateAsMinutes = Int.zero
                                isActiveVirtualTaskBox.toggle()
                            } catch let error as NSError {
                                print("\(error), \(error.userInfo)")
                            }
                        }
                        }
                )
            // scrollView上でDragGestureがしやすくなる
                .simultaneousGesture(
                    LongPressGesture()
                        .onEnded { _ in
                        }
                )
        }
        .zIndex(5)
    }
}
