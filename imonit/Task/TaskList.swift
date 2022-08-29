//
//  TaskList.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI
import CoreData

struct TaskList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.startDate, ascending: true)],
        predicate: nil,
        animation: .default)
    var tasks: FetchedResults<Task>
    @State private var showingAddSheet = false
    @State private var taskEditMode = false

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(tasks) { task in
                    NavigationLink {
                        TaskDetail(task: task)
                    } label: {
                        VStack {
                            HStack {
                                if taskEditMode == true {
                                    Button("Delete") {
                                        viewContext.delete(task)
                                    }
                                }
                                TaskRow(task: task)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        withAnimation {
                            taskEditMode.toggle()
                        }
                    }
                }
                ToolbarItem {
                    Button("Add") {
                        self.showingAddSheet.toggle()
                    }
                    .fullScreenCover(isPresented: $showingAddSheet) {
                        TaskAddSheet()
                    }
                }
            }
            .navigationTitle("Tasks")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError: NSError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    //    func getTodayTask() -> [Task] {
    //        let persistenceController = PersistenceController.shared
    //        let context = persistenceController.container.viewContext
    //
    //        // XX月XX日0時0分0秒に設定したものをstartにいれる
    //        var component = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
    //        component.hour = 0
    //        component.minute = 0
    //        component.second = 0
    //        let start: NSDate = NSCalendar.current.date(from: component)! as NSDate
    //
    //        // XX月XX日23時59分59秒に設定したものをendにいれる
    //        component.hour = 23
    //        component.minute = 59
    //        component.second = 59
    //        let end: NSDate = NSCalendar.current.date(from:component)! as NSDate
    //
    //        let predicate = NSPredicate(format:"(date >= %@) AND (date <= %@)",start,end)
    //
    //        let request = NSFetchRequest<Task>(entityName: "Task")
    //        request.predicate = predicate
    //        do {
    //            let tasks = try context.fetch(request)
    //            return tasks
    //        }
    //        catch {
    //            fatalError()
    //        }
    //    }

}

struct TaskList_Previews: PreviewProvider {
    static var previews: some View {
        let result: PersistenceController = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // task
        let newTask = Task(context: viewContext)
        newTask.task = "Quis nostrud exercitation ullamco"
        newTask.isDone = false
        newTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newTask.createdAt = Date()
        newTask.id = UUID()
        newTask.startDate = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!
        newTask.endDate = Date() + 100
        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"
        // micro task
        let newMicroTask = MicroTask(context: viewContext)
        newMicroTask.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 10
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.satisfactionPredict = 5
        newMicroTask.satisfactionPredict = 5
        newMicroTask.task = newTask

        let newMicroTask2 = MicroTask(context: viewContext)
        newMicroTask2.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask2.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask2.id = UUID()
        newMicroTask2.isDone = false
        newMicroTask2.timer = 10
        newMicroTask2.createdAt = Date()
        newMicroTask2.order = 0
        newMicroTask2.satisfactionPredict = 5
        newMicroTask2.satisfactionPredict = 5
        newMicroTask2.task = newTask

        let newTask2 = Task(context: viewContext)
        newTask2.task = "Quis nostrud exercitation ullamco"
        newTask2.isDone = false
        newTask2.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newTask2.createdAt = Date()
        newTask2.id = UUID()
        newTask2.startDate = Date()
        newTask2.endDate = Date()
        newTask2.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask2.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"
        // micro task

        return TaskList()
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, viewContext)
    }
}
