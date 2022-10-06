//
//  ToIdentifyTapPositionRect.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/10/05.
//

import SwiftUI

struct RectsToIdentifyTappedPosition: View {
    @ObservedObject var newTaskBox: NewTaskBoxData
    
    var scrollViewHeight: CGFloat
    var aMinuteHeight: CGFloat {
        scrollViewHeight / 1_440
    }
    var magnifyBy: Double
    var selectedDate: Date
    
    // timelinerをTapしたときに新規作成するTaskBoxの、TopとBottomを算出する
    // Tapしたときに遷移するTaskAddSheetのDatePickerに代入する、TaskのStartとEndのDateを算出する
    /**
     Calculate **the CGFloat of the  top and bottom of a new TaskBox** and **the Date of the start and end time of a new task** when tapped timeline.
     */
    fileprivate func calcNewTaskPositionAndDate() {
        
        switch magnifyBy {
        case 1:
            // 選択したAreaを12で割ることで、hour(0h~23h)に変換する。小数点以下は切り捨て = hourのみ取得
            newTaskBox.selectedArea =  floor(newTaskBox.selectedArea / 12)
            newTaskBox.minute = 0
            // hourに変換した後に、*60をして分単位に
            newTaskBox.top = aMinuteHeight * CGFloat((newTaskBox.selectedArea) * 60)
            // + 60で　1h分のboxにする
            newTaskBox.bottom = aMinuteHeight * CGFloat((newTaskBox.selectedArea) * 60) + 30
            newTaskBox.forXMinutes = 60
        case 2:
            newTaskBox.selectedArea =  newTaskBox.selectedArea / 12
            // 10倍にして、1の位が5未満だったら0に、5以上だったら5を代入する
            // その値に6をかけて分単位にする
            newTaskBox.minute = Int((newTaskBox.selectedArea * Double(10)).truncatingRemainder(dividingBy: 10.0))
            if newTaskBox.minute >=  5 {
                newTaskBox.minute = 5
            }else {
                newTaskBox.minute = 0
            }
            newTaskBox.minute *= 6
            // Pathに渡すためのCGFloat
            newTaskBox.top = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute)
            newTaskBox.bottom = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute) + 30
            // TaskAddSheetのDatePickerに渡す
            newTaskBox.forXMinutes = 30
        case 5:
            newTaskBox.selectedArea =  newTaskBox.selectedArea / 12
            newTaskBox.minute = Int((newTaskBox.selectedArea * Double(100)).truncatingRemainder(dividingBy: 100.0))
            if 25..<50 ~= newTaskBox.minute {
                newTaskBox.minute = 25
            }else if 50..<75 ~= newTaskBox.minute {
                newTaskBox.minute = 50
            }else if 75..<100 ~= newTaskBox.minute {
                newTaskBox.minute = 75
            }else{
                newTaskBox.minute = 0
            }
            newTaskBox.minute = newTaskBox.minute * 6 / 10
            newTaskBox.top = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute)
            newTaskBox.bottom = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute) + 75
            newTaskBox.forXMinutes = 30
        case 10:
            newTaskBox.selectedArea =  newTaskBox.selectedArea / 12
            newTaskBox.minute = Int((newTaskBox.selectedArea * Double(100)).truncatingRemainder(dividingBy: 100.0))
            if 25..<50 ~= newTaskBox.minute {
                newTaskBox.minute = 25
            }else if 50..<75 ~= newTaskBox.minute {
                newTaskBox.minute = 50
            }else if 75..<100 ~= newTaskBox.minute {
                newTaskBox.minute = 75
            }else{
                newTaskBox.minute = 0
            }
            newTaskBox.minute = newTaskBox.minute * 6 / 10
            newTaskBox.top = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute)
            newTaskBox.bottom = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute) + 75
            newTaskBox.forXMinutes = 15
        case 30:
            newTaskBox.selectedArea =  newTaskBox.selectedArea / 12
            newTaskBox.minute = Int((newTaskBox.selectedArea * Double(100)).truncatingRemainder(dividingBy: 100.0))
            if 25..<50 ~= newTaskBox.minute {
                newTaskBox.minute = 25
            }else if 50..<75 ~= newTaskBox.minute {
                newTaskBox.minute = 50
            }else if 75..<100 ~= newTaskBox.minute {
                newTaskBox.minute = 75
            }else{
                newTaskBox.minute = 0
            }
            newTaskBox.minute = newTaskBox.minute * 6 / 10
            newTaskBox.top = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute)
            newTaskBox.bottom = aMinuteHeight * CGFloat(Int(newTaskBox.selectedArea) * 60 + newTaskBox.minute) + 225
            newTaskBox.forXMinutes = 15
        default:
            print("message")
        }
    }
    
    var body: some View {
        // ScrollViewに透明のRectを敷き詰めることで、Tapした位置のRectの順番を割り出し、プログラム的にtoScrollできるようにする
        VStack(spacing: 0) {
            ForEach(0..<288, id: \.self) { obj in
                Rectangle()
                    .stroke(.clear)
                    .frame(height: 30 * magnifyBy / 12, alignment: .top)
                    .id(obj)
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture()
                            .onEnded{ _ in
                                withAnimation {
                                    newTaskBox.isActive.toggle()
                                }
                                
                                newTaskBox.selectedArea = Double(obj)
                                calcNewTaskPositionAndDate()
                                
                                newTaskBox.startDate = newTaskBox.greCal.date(
                                    from: DateComponents(
                                        year: newTaskBox.greCal.component(.year, from: selectedDate),
                                        month:  newTaskBox.greCal.component(.month, from: selectedDate),
                                        day: newTaskBox.greCal.component(.day, from: selectedDate),
                                        hour: Int(newTaskBox.selectedArea),
                                        minute: newTaskBox.minute
                                    )
                                ) ?? Date()
                                
                                newTaskBox.endDate = newTaskBox.greCal.date(
                                    from: DateComponents(
                                        year: newTaskBox.greCal.component(.year, from: selectedDate),
                                        month:  newTaskBox.greCal.component(.month, from: selectedDate),
                                        day: newTaskBox.greCal.component(.day, from: selectedDate),
                                        hour: Int(newTaskBox.selectedArea),
                                        minute: newTaskBox.minute + newTaskBox.forXMinutes
                                    )
                                ) ?? Date()
                            }
                    )
            }
        }
    }
}

