//
//  NewTaskBoxOnCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/10/07.
//

import SwiftUI

struct NewTaskBoxOnCalender: View {
    @ObservedObject var newTaskBox: NewTaskBoxData
    var timelineDividerWidth: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if newTaskBox.isActive {
                TaskBoxShape(
                    radius: 5,
                    top: newTaskBox.top,
                    bottom: newTaskBox.bottom,
                    leading: UIScreen.main.bounds.maxX - timelineDividerWidth,
                    traling: UIScreen.main.bounds.maxX
                )
                .fill(.green)
                .opacity(0.5)
                
                Text("New Task")
                    .offset(x: UIScreen.main.bounds.maxX - timelineDividerWidth + 5, y: newTaskBox.top + 5)
                
            }
        }
        .fullScreenCover(isPresented: $newTaskBox.isActive) {
            TaskAddSheet(startDate: $newTaskBox.startDate, endDate: $newTaskBox.endDate)
        }
        
    }
}

