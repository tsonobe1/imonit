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
    let microtaskTimerMax: CGFloat
    @State private var remainingTime: CGFloat
    
    init(microTask: MicroTask){
        self.microTask = microTask
        // 以下2つはCircleのtrim(カウントダウン)用のプロパティ
        // trimの引数(from, to)は"0.0~1.0"の値を取るため"現在値/最大値"で正規化した値を指定する
        // remainingTimeは現在値, microtaskTimerMaxは最大値
        self.remainingTime = CGFloat(microTask.timer)
        self.microtaskTimerMax = CGFloat(microTask.timer)
    }

    
    var body: some View {
        VStack{
            
            ZStack{
                // Background Circle
                Circle()
                    .stroke(lineWidth: 30)
                    .foregroundColor(.gray)
                    .opacity(0.25)
                
                // Foreground Circle
                Circle()
                // toには正規化した値を指定する
                    .trim(from: 0, to: remainingTime/microtaskTimerMax)
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2434657216, green: 0.6025889516, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0, green: 1, blue: 0.849874258, alpha: 1)),Color(#colorLiteral(red: 0.924164772, green: 0.3744831383, blue: 1, alpha: 1)) ,Color(#colorLiteral(red: 0.2434657216, green: 0.6025889516, blue: 1, alpha: 1))]), center: .center), style: StrokeStyle(lineWidth: 15.0, lineCap : .round, lineJoin: .round))
                // 開始地点を上部に
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeInOut(duration: 1), value: remainingTime)
                
                

                VStack(spacing: 50){
                    // 経過時間
                    VStack(spacing: 10){
                        Text("Elapsed Time")
                            .opacity(0.7)
                        Text("0:00")
                            .font(.title)
                            .bold()
                    }
                    
                    // 残り時間
                    VStack(spacing: 10){
                        Text("Remaining Time")
                            .opacity(0.7)
                        Text(intToMinuteSecond(remainingTime: remainingTime))
                            .font(.title)
                            .bold()
                    }
                }
            }
        
            
            
            Text("\(microTask.timer)")
                .padding()
                .font(.title)
                .onReceive(timer){ _ in
                    if remainingTime > 0 && timerRunning {
                        remainingTime -= 1
                    } else {
                        timerRunning = false
                    }
                }
            
            HStack(spacing:30) {
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
    
    private func intToMinuteSecond(remainingTime: CGFloat) -> String{
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .abbreviated
        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.zeroFormattingBehavior = .pad
        

        return dateFormatter.string(from: TimeInterval(remainingTime))!
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
        
        let newMicroTask = MicroTask(context: viewContext)
        newMicroTask.microTask = "Quis nostrud exercitation ullamco"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 60
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.task = newTask
        
        return NavigationView {
            MicroTaskTimer(microTask: newMicroTask)
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(.light)
        
    }
}
