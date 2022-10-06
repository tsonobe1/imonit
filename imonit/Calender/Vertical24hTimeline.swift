//
//  Vertical24hTimeline.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/10/06.
//

import SwiftUI

struct Vertical24hTimeline: View {
    @Binding var timelineDividerWidth: CGFloat
    var scrollViewHeight: CGFloat
    var magnifyBy: Double
    
    var body: some View {
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
            }
        }
    }
}
