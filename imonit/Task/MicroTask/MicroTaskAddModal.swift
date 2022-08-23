//
//  MicroTaskAddModal.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/23.
//

import SwiftUI

struct MicroTaskAddModal: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: Task
    @Binding var showingAddMicroTaskTextField: Bool
    @State private var newMicroTask = ""
    @State private var minutes = 10
    @State private var isExpand = false
    var microTasksCount: Int
    
    var body: some View {
        VStack {
            // 🚫 Chancel Button
            HStack {
                Button(
                    action: { withAnimation { isExpand.toggle() } },
                    label: {
                        Image(systemName: isExpand ? "dock.arrow.down.rectangle" : "dock.arrow.up.rectangle")
                            .font(.callout)
                    }
                )
                Spacer()
                Button(
                    action: { withAnimation { showingAddMicroTaskTextField.toggle() } },
                    label: {
                        Text("Chancel")
                            .font(.callout)
                            .padding(.trailing)
                    }
                )
            }
            .padding(.bottom)
            
            if isExpand == false {
                // ✏️ Input Form
                VStack {
                    HStack(spacing: 10) {
                        TextField("Micro Task Title", text: $newMicroTask)
                        Picker(selection: $minutes, label: Text("Select")) {
                            ForEach(1..<61, id: \.self) { minute in
                                Text("\(minute) minute").tag(minute)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                }
                
            } else {
                // ✏️✏️✏️ Expand Input form
                VStack {
                    TextField("Micro Task Title", text: $newMicroTask)
                    HStack {
                        Text("Timer")
                        Spacer()
                        Picker(selection: $minutes, label: Text("Select")) {
                            ForEach(1..<61, id: \.self) { minute in
                                Text("\(minute) minute").tag(minute)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        
                    }
                    // TODO: Add Micro Task Attributes
                    TextField("Detail", text: .constant(""))
                    
                    TextField("Satisfied", text: .constant(""))
                    
                    TextField("Difficult", text: .constant(""))
                }
            }
        }
        
        // + Add Button
        Button(
            action: { withAnimation { addMicroTasks() } },
            label: {
                Text("Add")
            }
        )
        .buttonStyle(.borderedProminent)
        .disabled(newMicroTask.isEmpty)
    }
    
    private func addMicroTasks() {
        let newMicroTasks = MicroTask(context: viewContext)
        newMicroTasks.microTask = newMicroTask
        newMicroTasks.timer = Int16(minutes * 60)
        newMicroTasks.order = Int16(microTasksCount + 1)
        newMicroTasks.createdAt = Date()
        newMicroTasks.id = UUID()
        newMicroTasks.isDone = false
        newMicroTasks.task = task
        
        do {
            try viewContext.save()
            newMicroTask = ""
            minutes = 10
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct MicroTaskAddModal_Previews: PreviewProvider {
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
        newMicroTask.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 600
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.task = newTask
        
        return MicroTaskAddModal(task: newTask, showingAddMicroTaskTextField: .constant(true), microTasksCount: 3)
    }
}
