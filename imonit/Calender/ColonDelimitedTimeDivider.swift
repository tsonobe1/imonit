//
//  ColonDelimitedTimeDivider.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/29.
//

import SwiftUI

struct ColonDelimitedTimeDivider: View {
    var hour: Int
    var time: Int
    var scrollViewHeight: CGFloat
    
    var body: some View {
        HStack {
            Text("\(String(format: "%02d", hour)):\(time)")
                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)))
                .opacity(0.4)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.3))
        }
        .offset(y: -7 + (scrollViewHeight / 1_440 * CGFloat(time)))
        .transition(.opacity)
    }
}

