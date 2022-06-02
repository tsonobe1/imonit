//
//  TaskList.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI

struct TaskList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    @State private var showingAddSheet = false
    
    @State private var taskEditMode = false
    
    
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                ForEach(tasks) { task in
                    NavigationLink {
                        TaskDetail(task: task)
                            .padding()
                    } label: {
                        VStack{
                            HStack{
                                if taskEditMode == true{
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
                        taskEditMode.toggle()
                    }
                }
                ToolbarItem {
                    Button("Add") {
                        self.showingAddSheet.toggle()
                    }
                    .sheet(isPresented: $showingAddSheet){
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    
    
}


struct TaskList_Previews: PreviewProvider {
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
        
        return TaskList()
            .environment(\.managedObjectContext, viewContext)
    }
}
