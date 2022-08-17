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
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    
    
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
    
    var body: some View {
        NavigationView{
            VStack{
                Form {
                    // MARK: Form - Task
                    Section(header: Text("Task"),
                            footer: Text(startDate >= endDate ? "Ends should be set to a date and time later than Starts." : "")
                        .font(.footnote)
                    ){
                        TextField("Task Title", text: $task)
                        TextField("Task Detail", text: $detail)
                        DatePicker("Starts", selection: $startDate)
                        DatePicker("Ends", selection: $endDate)
                    }
                    .textCase(nil)
                }
                .navigationTitle("Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel"){
                        dismiss()
                    },
                    trailing: Button("Add") {
                        addTask()
                    }
                    .disabled(task.isEmpty || startDate >= endDate)
                )
            }
        }
    }
    
    private func rowRemove(offsets: IndexSet) {
        microTaskTouple.remove(atOffsets: offsets)
    }
    
    private func rowReplace(_ from: IndexSet, _ to: Int) {
        microTaskTouple.move(fromOffsets: from, toOffset: to)
    }
    
    private func addMicroTask(){
        microTaskTouple.append((microTask, Int16(minutes)))
        microTask = ""
        minutes = 10
    }
    
    private func addTask() {
        withAnimation {
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
                    newMicroTasks.order = Int16(index+1)
                    newMicroTasks.createdAt = Date()
                    newMicroTasks.id = UUID()
                    newMicroTasks.isDone = false
                    newMicroTasks.task = newTask
                }
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        dismiss()
    }
}

struct TaskAddSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskAddSheet()
            .preferredColorScheme(.dark)
    }
}
