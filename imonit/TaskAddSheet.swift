//
//  TaskAddSheet.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI

struct TaskAddSheet: View {
    // Task Model
    @Environment(\.managedObjectContext) private var viewContext
    @State private var task = ""
    @State private var detail = ""
    @State private var id = UUID()
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    // MicroTask
    @State private var microTask = ""
    @State private var microTaskTouple: [(String, Int16)] = []
    
    // timer
    @State var minutes = 10
    
    var minutesSelection: [Int] {
        get{
            var minuitsArray: [Int] = []
            for i in stride(from: 0, to: 65, by: 5){
                minuitsArray.append(i)
            }
            minuitsArray.removeFirst()
            return minuitsArray
        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Form {
                    Section(header: Text("Task").bold().font(.body)){
                        TextField("Task Title", text: $task)
                        TextField("Task Detail", text: $detail)
                        DatePicker("Starts", selection: $startDate)
                        DatePicker("Ends", selection: $endDate)
                    }.textCase(nil)
                    
                    
                    Section(header: Text("Micro Tasks").bold().font(.body)){
                        HStack{
                            TextField("Micro Task", text:$microTask)
                            Picker(selection: $minutes, label:Text("Select")){
                                // 5 ~ 60 by 5
                                ForEach(minutesSelection, id: \.self) { i in
                                    Text("\(i) min").tag(i)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }
                        Button("Add") {
                            addMicroTask()
                        }.disabled(microTask.isEmpty)
                        
                    }.textCase(nil)
                    
                    
                    List{
                        ForEach(0..<microTaskTouple.count, id: \.self){ index in
                            HStack{
                                Text("\(index)")
                                Text(microTaskTouple[index].0)
                                Text("\(microTaskTouple[index].1)")
                            }
                        }
                    }
                    .listStyle(.automatic)
                    
                    
                    
                }
                .navigationTitle("Add Task")
                Button("Add") {
                    addTask()
                }
                
            }
        }
    }
    
    private func addMicroTask(){
        microTaskTouple.append((microTask, Int16(minutes)))
        microTask = ""
        minutes = 10
    }
    
    private func addTask() {
        withAnimation {
            print(task)
            
            let newTask = Task(context: viewContext)
            newTask.createdAt = Date()
            newTask.task = task
            newTask.detail = detail
            newTask.id = UUID()
            newTask.isDone = false
            newTask.startDate = startDate
            newTask.endDate = endDate
            
            if !microTaskTouple.isEmpty{
                for (index, i) in microTaskTouple.enumerated() {
                    let newMicroTasks = MicroTask(context: viewContext)
                    newMicroTasks.microTask = i.0
                    newMicroTasks.timer = i.1
                    newMicroTasks.order = Int16(index)
                    newMicroTasks.createdAt = Date()
                    newMicroTasks.id = UUID()
                    newMicroTasks.isDone = false
                    newMicroTasks.task = newTask
                }
            }
            
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TaskAddSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskAddSheet()
    }
}
