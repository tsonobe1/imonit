//
//  VirtualTaskBox.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/29.
//

import SwiftUI

struct VirtualTaskBox: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var scrollViewHeight: CGFloat
    var scrollViewWidth: CGFloat
    var timelineDividerWidth: CGFloat
    let selectedItem: Task
    @Binding var isActiveVirtualTaskBox: Bool
    @Binding var magnifyBy: Double
    
    @State private var changedUpperSidePosition = CGFloat.zero
    @State private var changedStartDate = Int.zero
    @State private var changedLowerSidePosition = CGFloat.zero
    @State private var changedEndDate = Int.zero
    @State private var changedPosition = CGFloat.zero
    @State private var changedDate = Int.zero
    @State private var changedLeading = CGFloat.zero
    @State private var changedTraling = CGFloat.zero
    
    func clamp<T: Comparable>(value: T, lowerLimit: T, upperLimit: T) -> T {
        if value < lowerLimit {
            return lowerLimit
        }
        if value > upperLimit {
            return upperLimit
        }
        return value
    }
    
    func floorWithMultiple(_ movePosition: CGFloat, _ positionsMultiple: CGFloat, _ datesMultiple: Double) -> (movedPosition: CGFloat, movedMinute: Int) {
        let x = movePosition / positionsMultiple
        let y = floor(x)
        let a = y * positionsMultiple
        let b = Int(y * datesMultiple)
        return (a, b)
    }

    var body: some View {
        ZStack(alignment: .top) {
            TaskBoxShape(
                radius: 5,
                top: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + changedUpperSidePosition + changedPosition,
                bottom: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + changedLowerSidePosition + changedPosition,
                leading: scrollViewWidth - timelineDividerWidth + changedLeading,
                traling: scrollViewWidth + changedTraling
            )
            .fill(.orange)
            .opacity(0.5)
            .gesture(
                // Position
                DragGesture()
                    .onChanged { value in
                        // ドラッグ中の処理
                        var floored = floorWithMultiple(value.translation.height, 7.5, 15)
                        switch magnifyBy {
                        case 1.0: floored = floorWithMultiple(value.translation.height, 7.5, 15)
                        case 2.0: floored = floorWithMultiple(value.translation.height, 15, 15)
                        case 5.0: floored = floorWithMultiple(value.translation.height, 12.5, 5)
                        case 10.0: floored = floorWithMultiple(value.translation.height, 5, 1)
                        case 30.0: floored = floorWithMultiple(value.translation.height, 15, 1)
                        default:
                            print("What?")
                        }
                        changedPosition = floored.movedPosition
                        changedDate = floored.movedMinute
                        changedLeading = value.translation.width
                        changedTraling = value.translation.width
                    }
                    .onEnded { _ in
                        do {
                            let modifiedStartDate = Calendar.current.date(byAdding: .minute, value: changedDate, to: selectedItem.startDate!)!
                            let modifiedEndDate = Calendar.current.date(byAdding: .minute, value: changedDate, to: selectedItem.endDate!)!
                            selectedItem.startDate = modifiedStartDate
                            selectedItem.endDate = modifiedEndDate
                            try viewContext.save()
                            changedPosition = CGFloat.zero
                            changedDate = Int.zero
                            withAnimation {
                                isActiveVirtualTaskBox.toggle()
                            }
                        } catch let error as NSError {
                            print("\(error), \(error.userInfo)")
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
                    Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: changedStartDate + changedDate - 30, to: selectedItem.startDate!)!))
                        .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                        .opacity(1)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.ultraThinMaterial)
                                .opacity(0.6)
                        )
                        .offset(y: -15.0 * magnifyBy)
                    
                    Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: changedStartDate + changedDate, to: selectedItem.startDate!)!))
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
                .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + changedUpperSidePosition - 6 + changedPosition)
                
                // 🕛 EndDateの時間軸
                HStack(alignment: .center) {
                    Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: changedEndDate + changedDate, to: selectedItem.endDate!)!))
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
                .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + changedLowerSidePosition - 7 + changedPosition)
            }
            
            // 🤐 StartDateの移動バー
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary)
                    .opacity(1)
                    .frame(width: 30, height: 30)
                    .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + changedUpperSidePosition - 30)
                    .gesture(
                        DragGesture(coordinateSpace: .named("scroll")) // Scroll View
                            .onChanged { value in
                                var floored = floorWithMultiple(value.translation.height, 7.5, 15)
                                switch magnifyBy {
                                case 1.0: floored = floorWithMultiple(value.translation.height, 7.5, 15)
                                case 2.0: floored = floorWithMultiple(value.translation.height, 15, 15)
                                case 5.0: floored = floorWithMultiple(value.translation.height, 12.5, 5)
                                case 10.0: floored = floorWithMultiple(value.translation.height, 5, 1)
                                case 30.0: floored = floorWithMultiple(value.translation.height, 15, 1)
                                default:
                                    print("What?")
                                }
                                changedUpperSidePosition = floored.movedPosition
                                changedStartDate = floored.movedMinute
                            }
                            .onEnded { _ in
                                do {
                                    print("startDate: \(selectedItem.startDate!)")
                                    let modifiedDate = Calendar.current.date(byAdding: .minute, value: changedStartDate, to: selectedItem.startDate!)!
                                    selectedItem.startDate = modifiedDate
                                    try viewContext.save()
                                    changedUpperSidePosition = CGFloat.zero
                                    changedStartDate = Int.zero
                                    withAnimation {
                                        isActiveVirtualTaskBox.toggle()
                                    }
                                } catch let error as NSError {
                                    print("\(error), \(error.userInfo)")
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
            // 🤐 EndDateの移動バー
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary)
                    .opacity(0.6)
                    .frame(width: 30, height: 30)
                    .offset(x: scrollViewWidth - timelineDividerWidth, y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + changedLowerSidePosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // ドラッグ中の処理
                                var floored = floorWithMultiple(value.translation.height, 7.5, 15)
                                switch magnifyBy {
                                case 1.0: floored = floorWithMultiple(value.translation.height, 7.5, 15)
                                case 2.0: floored = floorWithMultiple(value.translation.height, 15, 15)
                                case 5.0: floored = floorWithMultiple(value.translation.height, 12.5, 5)
                                case 10.0: floored = floorWithMultiple(value.translation.height, 5, 1)
                                case 30.0: floored = floorWithMultiple(value.translation.height, 15, 1)
                                default:
                                    print("What?")
                                }
                                changedLowerSidePosition = floored.movedPosition
                                changedEndDate = floored.movedMinute
                            }
                            .onEnded { _ in
                                do {
                                    print("startDate: \(selectedItem.endDate!)")
                                    let modifiedDate = Calendar.current.date(byAdding: .minute, value: changedEndDate, to: selectedItem.endDate!)!
                                    selectedItem.endDate = modifiedDate
                                    try viewContext.save()
                                    changedLowerSidePosition = CGFloat.zero
                                    changedEndDate = Int.zero
                                    withAnimation {
                                        isActiveVirtualTaskBox.toggle()
                                    }
                                } catch let error as NSError {
                                    print("\(error), \(error.userInfo)")
                                }
                            }
                    )
                // scrollView上でDragGestureがしやすくなる
                    .simultaneousGesture(
                        LongPressGesture()
                            .onEnded { _ in
                            }
                    )
                Spacer()
            }
        }
        .zIndex(5)
    }
}
