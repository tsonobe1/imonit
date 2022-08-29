//
//  MicroTaskTimer.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/14.
//

import SwiftUI
import Foundation

struct MicroTaskTimer: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var microTask: MicroTask
    @State private var timerRunning = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var remainingTime: CGFloat
    private let microtaskTimerMax: CGFloat

    init(microTask: MicroTask) {
        self.microTask = microTask
        // 以下2つはCircleのtrim(カウントダウン)用のプロパティ
        // trimの引数(from, to)は"0.0~1.0"の値を取るため"現在値/最大値"で正規化した値を指定する
        // remainingTimeは現在値, microtaskTimerMaxは最大値
        self.remainingTime = CGFloat(microTask.timer)
        self.microtaskTimerMax = CGFloat(microTask.timer)
    }

    // Circleサイズに対して相対的なCGFloatで文字サイズを調整する
    @State var circleSize: CGFloat = CGFloat(0)

    var body: some View {
        VStack {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(lineWidth: 30)
                    .foregroundColor(.secondary)
                    .opacity(0.25)
                    .background(
                        GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                circleSize = geometry.size.width
                            }
                            return Color.clear
                        }
                    )

                // Foreground Circle

                if remainingTime >= 0 {
                    Circle()
                        // toには正規化した値を指定する
                        .trim(from: 0, to: remainingTime / microtaskTimerMax)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2434657216, green: 0.6025889516, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0, green: 1, blue: 0.849874258, alpha: 1)), Color(#colorLiteral(red: 0.924164772, green: 0.3744831383, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.2434657216, green: 0.6025889516, blue: 1, alpha: 1))]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 15.0, lineCap: .round, lineJoin: .round)
                        )
                        // 開始地点を上部に
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.easeInOut(duration: 1), value: remainingTime)
                }
                // 設定したタイマーを過ぎた場合
                else {
                    Circle()
                        .trim(from: 1 + remainingTime / microtaskTimerMax, to: 1)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0.8618306135, blue: 0, alpha: 0.8470588235)), Color(#colorLiteral(red: 1, green: 0.5946068037, blue: 0, alpha: 0.8470588235)), Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.8470588235)), Color(#colorLiteral(red: 1, green: 0.8618306135, blue: 0, alpha: 0.8470588235))]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 15.0, lineCap: .round, lineJoin: .round)
                        )
                        // 開始地点を上部に
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.easeInOut(duration: 1), value: remainingTime)
                }

                // TODO: Action Button

                VStack(spacing: 30) {
                    // 残り時間
                    VStack(spacing: 10) {
                        Text(remainingTime <= -1 ? "Extra Time" : "Remaining Time")
                            .opacity(0.7)
                        HStack(alignment: .lastTextBaseline) {
                            /*
                             DateComponentsFormatteraのzeroFormattingBehavior=.padに
                             -1から-59の値を入れるとマイナスがつかないStringを返すが、
                             -60以降になるとマイナスがついたStringを返す。
                             バグが仕様か不明だが、上記を考慮した上でTextにマイナス表記を付ける
                             */
                            Text(remainingTime <= -1 && remainingTime >= -59 ? "-\(timeSeparate(timerTime: remainingTime))" : timeSeparate(timerTime: remainingTime))
                                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: circleSize * 0.15, weight: .light)))
                            Text("\\").bold()
                                .foregroundColor(.secondary)
                            Text(timeSeparate(timerTime: microtaskTimerMax))
                                .bold()
                                .foregroundColor(.secondary)
                        }
                    }
                    if remainingTime <= -1 {
                        VStack(spacing: 15) {
                            Text("Elapsed Time")
                                .opacity(0.7)
                            HStack(alignment: .lastTextBaseline) {
                                Text(timeSeparate(timerTime: microtaskTimerMax - remainingTime))
                                    .font(Font(UIFont.monospacedDigitSystemFont(ofSize: circleSize * 0.15, weight: .light)))
                            }
                        }.transition(.opacity)
                    }
                }
            }

            Text("\(microTask.timer)")
                .padding()
                .font(.title)
                .onReceive(timer) { _ in
                    withAnimation {
                        if timerRunning {
                            remainingTime -= 1
                        } else {
                            timerRunning = false
                        }
                    }
                }

            // TODO: circleをタップすると開始or一時停止　左右で異なるアクション
            HStack(spacing: 30) {
                Button("Start") {
                    timerRunning = true
                }

                Button("Reset") {
                    remainingTime = microtaskTimerMax
                    timerRunning = false
                }.foregroundColor(.red)
            }
        }
    }

    // CGFloat -> String XX:XX
    private func timeSeparate(timerTime: CGFloat) -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .positional
        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.zeroFormattingBehavior = .pad
        // XX:XX表記のStringを返す
        return dateFormatter.string(from: TimeInterval(timerTime))!
    }
}

struct MicroTaskTimer_Previews: PreviewProvider {
    static var previews: some View {

        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let newTask = Task(context: viewContext)
        newTask.task = "Quis nostrud exercitation ullamco"
        newTask.isDone = false
        newTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newTask.createdAt = Date()
        newTask.id = UUID()
        newTask.startDate = Date()
        newTask.endDate = Date()
        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"

        let newMicroTask = MicroTask(context: viewContext)
        newMicroTask.microTask = "Quis nostrud exercitation ullamco"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 5
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.satisfactionPredict = 5
        newMicroTask.satisfactionPredict = 5
        newMicroTask.task = newTask

        return NavigationView {
            MicroTaskTimer(microTask: newMicroTask)
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(.dark)

    }
}
