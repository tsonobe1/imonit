//
//  TaskRow.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task : Task
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        
        VStack(alignment: .leading){

            VStack(alignment: .leading){
                Text(task.task!)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(task.detail!)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            HStack(alignment: .bottom){
                Text("from")
                Text(startDateFormatter(date: task.startDate!))
                Text("to")
                Text(endDateFormatter(date: task.endDate!))
                Spacer()
                Text(Image(systemName: task.isDone ?  "checkmark.circle.fill" : "circle")).font(.title).onTapGesture {
                    toggleDone(task: task)
                }
            }
            .font(.caption)
            .foregroundColor(Color.secondary)

        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .frame(height: 60)
        .padding()
        .background(Color(.systemGray3).opacity(0.3))
        .cornerRadius(10)
        
        
        
        
    }
    func toggleDone(task: Task){
        print(task.isDone)
        task.isDone.toggle()
        
        
print(task.isDone)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
}

//struct TaskRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskRow(task: Task())
//    }
//}
