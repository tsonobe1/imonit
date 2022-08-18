//
//  TaskEditSheet.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/06/03.
//

import SwiftUI

struct TaskEditSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var task: Task

    // for text field
    @State private var taskTitle: String
    @State private var detail: String
    @State private var startDate: Date
    @State private var endDate: Date

    // Task Entity -->> @State property
    init(task: Task) {
        self.task = task
        _taskTitle = State(initialValue: task.task ?? "")
        _detail = State(initialValue: task.detail ?? "")
        _startDate = State(initialValue: task.startDate ?? Date())
        _endDate = State(initialValue: task.endDate ?? Date())
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: Form - Task
                    Section(header: Text("Task")) {
                        TextField("Task Title", text: $taskTitle)
                        TextEditor(text: $detail)
                        DatePicker("Starts", selection: $startDate)
                        DatePicker("Ends", selection: $endDate)
                    }
                    .textCase(nil)
                }
                .navigationTitle("Edit Task")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        dismiss()
                    },
                    trailing: Button("Save") {
                        updateTask()

                    }
                    .disabled(taskTitle.isEmpty)
                )
            }
        }
    }

    private func updateTask() {
        withAnimation {
            task.task = taskTitle
            task.detail = detail
            task.startDate = startDate
            task.endDate = endDate

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

struct TaskEditSheet_Previews: PreviewProvider {
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

            TaskEditSheet(task: newTask)
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(.dark)
    }
}
