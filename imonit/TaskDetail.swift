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

    
    var body: some View {
       
        
            VStack(alignment: .leading){
                Text(task.task!).font(.headline).bold()
                HStack{
                    Text("from")
                    Text(startDateFormatter(date: task.startDate!))
                    Text("to")
                    Text(endDateFormatter(date: task.endDate!))
                }
                .font(.caption)
                .foregroundColor(Color.secondary)
                
                Text(task.detail!)
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                
                MicroTaskList(withChild: task)
                
                    
                
            }
        
        .navigationBarTitleDisplayMode(.inline)
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

}


