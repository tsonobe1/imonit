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
    
    init(
        startDate: Binding<Date> = .constant(Date()),
        endDate: Binding<Date> = .constant(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!)
    ) {
        _startDate = startDate
        _endDate = endDate
    }
    
    @State private var task = ""
    @State private var detail = ""
    @State private var id = UUID()
    @Binding private var startDate: Date
    @Binding private var endDate: Date
    
    @State private var influence = ""
    @State private var benefit = ""
    
    // timer
    @State var minutes = 10
    
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: Form - Task
                    Section(
                        header: Text("Task"),
                        footer: Text(
                            startDate >= endDate ?
                            "Ends should be set to a date and time later than Starts." : ""
                        )
                        .font(.footnote)
                    ) {
                        TextField("Task Title", text: $task)
                        TextField("Task Detail", text: $detail)
                        DatePicker("Starts", selection: $startDate)
                        DatePicker("Ends", selection: $endDate)
                    }
                    .textCase(nil)
                    
                    Section(
                        header: Text("Motivation"),
                        footer: Text("Other")
                    ) {
                        // influence
                        TextField("Influence", text: $influence)
                        TextField("Benefit", text: $benefit)
                    }
                    .textCase(nil)
                }
                .navigationTitle("Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
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
            newTask.influence = influence
            newTask.benefit = benefit
            
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
