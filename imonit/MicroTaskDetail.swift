//
//  MicroTaskDetail.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/28.
//

import SwiftUI

struct MicroTaskDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var microTask: MicroTask
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text(Image(systemName: "timer"))
                Text("\(microTask.timer) min")
            }
            
            Text(microTask.microTask!)
            
            List{
                Section(header:  HStack(spacing: 20){
                    Text("Micro tasks")
                    Spacer()
                    // Add Button
                    Button("test") {
              
                    }
                    .font(.body)
                    // Edit Button
                    Button("TEST") {
                    }
                    .font(.body)
                }){
                ForEach(1..<9){ i in
                    Text("test list")
                }
            }
            }.listStyle(.plain)
           
            
            if let isDetail = microTask.detail{
                Text(isDetail)
            }else{
                Text("undefinde")
            }
            
            Spacer()
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
//        .padding()
        
    }
}

struct MicroTaskDetail_Previews: PreviewProvider {
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
        newMicroTask.microTask = "Duis aute irure dolor"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 10
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.task = newTask
        
        return NavigationView {
            MicroTaskDetail(microTask: newMicroTask)
                .environment(\.managedObjectContext, viewContext)
        }
            .preferredColorScheme(.dark)
    }
}
