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
    
    var body: some View {
        ZStack(alignment: .top) {
            TaskBoxShape(
                radius: 5,
                top: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + changedUpperSidePosition + changedPosition,
                bottom: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + changedLowerSidePosition + changedPosition,
                leading: UIScreen.main.bounds.maxX - timelineDividerWidth,
                traling: UIScreen.main.bounds.maxX
            )
            .fill(.orange)
            .opacity(0.5)
            .gesture(
                // Position
                DragGesture()
                    .onChanged { value in
                        // ドラッグ中の処理
                        if magnifyBy <= 3.0 {
                            changedPosition = (ceil(value.translation.height * 2 / 10) * 5)
                            changedDate = Int(ceil(value.translation.height * 2 / 10) * 10 / magnifyBy)
                        } else if magnifyBy <= 5 {
                            changedPosition = (ceil(value.translation.height / 5) * 5 * 2.5)
                            changedDate = Int(ceil(value.translation.height / 5) * 5 / magnifyBy * 5)
                        } else {
                            changedPosition = (floor(value.translation.height) / 10) * 10
                            changedDate = Int((floor(value.translation.height) / 10) * 10 * 2 / magnifyBy)
                        }
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
                    Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: changedStartDate + changedDate, to: selectedItem.startDate!)!))
                        .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                        .opacity(1)
                        .background(
                            Rectangle()
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
                .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + changedUpperSidePosition - 6 + changedPosition)
                
                // 🕛 EndDateの時間軸
                HStack(alignment: .center) {
                    Text(dateTimeFormatter(date: Calendar.current.date(byAdding: .minute, value: changedEndDate + changedDate, to: selectedItem.endDate!)!))
                        .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                        .opacity(1)
                        .background(
                            Rectangle()
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
                    .opacity(0.6)
                    .frame(width: 120, height: 20)
                    .offset(y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.startDate!) + changedUpperSidePosition - 20)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // ドラッグ中の処理
                                if magnifyBy <= 3.0 {
                                    changedUpperSidePosition = (ceil(value.translation.height * 2 / 10) * 5)
                                    changedStartDate = Int(ceil(value.translation.height * 2 / 10) * 10 / magnifyBy)
                                } else if magnifyBy <= 5 {
                                    changedUpperSidePosition = (ceil(value.translation.height / 5) * 5 * 2.5)
                                    changedStartDate = Int(ceil(value.translation.height / 5) * 5 / magnifyBy * 5)
                                } else {
                                    changedUpperSidePosition = (floor(value.translation.height) / 10) * 10
                                    changedStartDate = Int((floor(value.translation.height) / 10) * 10 * 2 / magnifyBy)
                                }
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
            }
            // 🤐 EndDateの移動バー
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary)
                    .opacity(0.6)
                    .frame(width: 120, height: 20)
                    .offset(x: UIScreen.main.bounds.maxX - timelineDividerWidth, y: scrollViewHeight / 1_440 * dateToMinute(date: selectedItem.endDate!) + changedLowerSidePosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if magnifyBy <= 3.0 {
                                    changedLowerSidePosition = (ceil(value.translation.height * 2 / 10) * 5)
                                    changedEndDate = Int(ceil(value.translation.height * 2 / 10) * 10 / magnifyBy)
                                } else if magnifyBy <= 5 {
                                    changedLowerSidePosition = (ceil(value.translation.height / 5) * 5 * 2.5)
                                    changedEndDate = Int(ceil(value.translation.height / 5) * 5 / magnifyBy * 5)
                                } else {
                                    changedLowerSidePosition = (floor(value.translation.height) / 10) * 10
                                    changedEndDate = Int((floor(value.translation.height) / 10) * 10 * 2 / magnifyBy)
                                }
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
                Spacer()
            }
        }
        .zIndex(5)
    }
}
