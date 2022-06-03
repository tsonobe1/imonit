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
    
    //    var minutesSelection: [Int] {
    //        get{
    //            var minuitsArray: [Int] = []
    //            for i in stride(from: 0, to: 62, by: 2){
    //                minuitsArray.append(i)
    //            }
    //            minuitsArray.removeFirst()
    //            return minuitsArray
    //        }
    //    }
    
    @State private var showingAlert = false
    
    
    
    
    var body: some View {
        NavigationView{
            VStack{
                Form {
                    // MARK: Form - Task
                    Section(header: Text("Task")){
                        TextField("Task Title", text: $task)
                        TextField("Task Detail", text: $detail)
                        DatePicker("Starts", selection: $startDate)
                        DatePicker("Ends", selection: $endDate)
                    }
                    .textCase(nil)
                    
                    
                    // MARK: Form - Micro Task
                    Section(header: HStack{
                        Text("Micro Tasks")
                        Spacer()
                        // help message
                        Button(action: {
                            showingAlert.toggle()
                        }){
                            Text(Image(systemName: "questionmark.circle"))
                            
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("What is Micro Task"),
                                  message: Text("Break tasks into smaller microtasks to make them easier to act on."))
                        }
                    },footer: HStack{
                        Button(action: {
                            addMicroTask()
                        }){
                            Spacer()
                            Text("Add micro tasks")
                                .font(.callout)
                                .padding(.top,5)
                            Spacer()
                        }
                        .disabled(microTask.isEmpty)
                    }){
                        HStack{
                            TextField("Micro Task Title", text: $microTask)
                            Picker(selection: $minutes, label:Text("Select")){
                                Spacer()
                                ForEach(1..<60, id: \.self) { i in
                                    Text("\(i) min").tag(i)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }
                        
                        //.multilineTextAlignment(.center)
                    }
                    .textCase(nil)
                    
                    // MARK: List - Micro Task
                    List{
                        Section(header:
                                    EditButton()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .overlay(Text("Header"), alignment: .leading)
                        ){
                            // If microtasks are not added.
                            if microTaskTouple.count == 0 {
                                Text("No Item").foregroundColor(Color.secondary)
                            } else {
                                ForEach(0..<microTaskTouple.count, id: \.self){ index in
                                    HStack{
                                        Text("\(index+1) : ").font(.caption)
                                        Text(microTaskTouple[index].0)
                                        Spacer()
                                        Text("\(microTaskTouple[index].1) min").font(.caption)
                                    }
                                }
                                .onMove(perform: rowReplace)
                                .onDelete(perform: rowRemove)
                            }
                        }
                        .textCase(nil)
                    }
                }
                .navigationTitle("Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel"){
                        dismiss()
//                        showingAddSheet = false
                    },
                    trailing: Button("Add") {
                        addTask()
                    }
                        .disabled(task.isEmpty)
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
    }
}
