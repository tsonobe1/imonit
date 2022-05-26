//
//  TaskRow.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task : Task
    
    var body: some View {
        
        VStack(alignment: .leading){

            HStack{
                Text(Image(systemName: "circle"))
                Text(task.task!)
                    .font(.headline)
            
            }.padding(20)
            
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60)
        .background(Color(.secondarySystemFill))
        .cornerRadius(10)
        
        
        
    }
}

//struct TaskRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskRow(task: Task())
//    }
//}
