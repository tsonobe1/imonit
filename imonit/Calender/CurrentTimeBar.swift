//
//  CurrentTimeBar.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/29.
//

import SwiftUI

struct CurrentTimeBar: View {
    var scrollViewHeight: CGFloat
    @State var nowDate = Date()
    @State var dateText = ""
    
    var body: some View {
        Group {
            HStack {
                Text("\(dateText)")
                    .bold()
                    .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                    .foregroundColor(.red)
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(.red.opacity(1))
            }
            .offset(y: -7 + (scrollViewHeight / 1_440 * CGFloat(convertToMinutes(date: nowDate))))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.nowDate = Date()
                    dateText = "\(dateTimeFormatterColon().string(from: nowDate))"
                }
            }
        }
    }
}

