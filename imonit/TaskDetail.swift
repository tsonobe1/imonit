//
//  TaskDetail.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI



struct TaskDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
    @ObservedObject var task : Task
    @State var showingAddMicroTaskTextField = false
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(task.task!)
                    .font(.headline)
                    .bold()
                if !showingAddMicroTaskTextField {
                    HStack{
                        Text("from")
                        Text(startDateFormatter(date: task.startDate!))
                        Text("to")
                        Text(endDateFormatter(date: task.endDate!))
                    }
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .padding(.top, 1)
                    Text(task.detail!)
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
            }
            .padding()
            MicroTaskList(withChild: task, showingAddMicroTaskTextField: $showingAddMicroTaskTextField)
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    self.showingEditSheet.toggle()
                }
                .fullScreenCover(isPresented: $showingEditSheet){
                    TaskEditSheet(task: task)
                }
            }
        }
    }
}

func startDateFormatter(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/d HH:mm"
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func endDateFormatter(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let dateString = dateFormatter.string(from: date)
    return dateString
}




import CoreData

struct TaskDetail_Previews: PreviewProvider {
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
            
            TaskDetail(task: newTask)
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(.dark)
    }
}
