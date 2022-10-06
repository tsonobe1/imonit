//
//  TaskBoxOnCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/10/07.
//

import SwiftUI

struct TaskBoxOnCalender: View {
    var task: Task
    @ObservedObject var toSctollBox: WhenScrollingToTaskBox
    
    @Binding var scrollViewHeight: CGFloat
    @Binding var timelineDividerWidth: CGFloat
    @Binding var magnifyBy: Double
    
    @Binding var selectedItem: Task
    @Binding var isNavigation: Bool
    @Binding var isActiveVirtualTaskBox: Bool
    var aMinuteHeight: CGFloat {
        scrollViewHeight / 1_440
    }
    
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
    // 🖕 Pinch in When Double Tap Gesture
    fileprivate func findOrderOfTaskBoxUpperSide(_ task: FetchedResults<Task>.Element) {
        let taskBoxHeight = aMinuteHeight * dateToMinute(date: task.startDate!)
        let compartmentalizedOrder = taskBoxHeight / (30 * magnifyBy / 12)
        let roundDown = Int(floor(compartmentalizedOrder))
        toSctollBox.scrollTarget = roundDown
    }
    fileprivate func pinchInAndToSctrollDoubleTap(_ task: FetchedResults<Task>.Element) -> _EndedGesture<TapGesture> {
        TapGesture(count: 2)
            .onEnded { _ in
                if magnifyBy != 30 {
                    // ScrollViewの拡大率を30にして拡大 -> Scrollが上辺に戻る
                    magnifyBy = 30
                    toSctollBox.cheatFadeInOut = true // Scrollのopacity操作をしておかしな挙動を隠す(誤魔化し用フェードイン・アウト)
                    // View中央にTask名を表示
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        toSctollBox.fadeState = .first
                        toSctollBox.selectedText = task.task
                    }
                    // 0.2秒後にダブルタップしたtaskBoxまでスクロール
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            findOrderOfTaskBoxUpperSide(task)
                        }
                        // 0.1秒後の更に0.3秒後にScrollのopacityを戻す
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                toSctollBox.cheatFadeInOut = false
                            }
                        }
                    }
                    // 0.8秒後にView中央にTask名を消す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(Animation.easeInOut) {
                            toSctollBox.fadeState = .second
                        }
                    }
                } else {
                    // ダブルタップ時にmagnifByが30だった場合
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        findOrderOfTaskBoxUpperSide(task)
                    }
                    }

                }
            }
    }

    var body: some View {
        Group {
            // 🧱 Tack Box Shape
            TaskBoxShape(
                radius: 5,
                top: aMinuteHeight * dateToMinute(date: task.startDate!),
                bottom: aMinuteHeight * dateToMinute(date: task.endDate!),
                leading: UIScreen.main.bounds.maxX - timelineDividerWidth,
                traling: UIScreen.main.bounds.maxX
            )
            .fill(Color.orange)
            .opacity(0.35)
            
            // 📛 Task, MicroTask Details
            TaskDetailOnBox(
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
}
