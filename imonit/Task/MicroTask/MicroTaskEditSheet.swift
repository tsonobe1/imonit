//
//  MicroTaskEditSheet.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/17.
//

import SwiftUI

struct MicroTaskEditSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var microTask: MicroTask

    // for text field
    @State private var microTaskTitle: String
    @State private var detail: String
    @State private var timer: Int16
    
    init(microTask: MicroTask) {
        self.microTask = microTask
        _microTaskTitle = State(initialValue: microTask.microTask ?? "")
        _detail = State(initialValue: microTask.detail ?? "")
        _timer = State(initialValue: microTask.timer )
    }
    
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    // MARK: Form - Task
                    Section(header: Text("MicroTask")){
                        TextField("Task Title", text: $microTaskTitle)
                        TextEditor(text: $detail)
                        HStack(alignment: .lastTextBaseline){
                            Text("Timer")
                            Spacer()
                            Picker(selection: $timer, label:Text("Select")){
                                ForEach(1..<61, id: \.self) { i in
                                    Text("\(i) minute").tag(i)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .textCase(nil)
                }
                .navigationTitle("Edit MicroTask")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel"){
                        dismiss()
                    },
                    trailing: Button("Save") {
                        updateMicroTask()
                        
                    }
                        .disabled(microTaskTitle.isEmpty)
                )
            }
        }
        
    }
    
    private func updateMicroTask() {
        withAnimation {
            microTask.microTask = microTaskTitle
            microTask.detail = detail
            microTask.timer = timer
            
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

struct MicroTaskEditSheet_Previews: PreviewProvider {
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
        newMicroTask.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 10
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.task = newTask
        
        return NavigationView {
            
            MicroTaskEditSheet(microTask: newMicroTask)
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(.dark)
    }
}
