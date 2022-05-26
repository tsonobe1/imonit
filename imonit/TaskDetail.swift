//
//  TaskDetail.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/24.
//

import SwiftUI


struct TaskDetail: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var task : Task
    
    @State private var tasks = ["Paul", "Taylor", "Adele", "rolen", "ipsum", "aran", "wein", "Waaaaanpp"]
    
    
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task) {
        self.task = task
        _microTasks = FetchRequest(
            entity: MicroTask.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \MicroTask.order, ascending: true)
            ],
            predicate: NSPredicate(format: "task == %@", task)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading){
            VStack{
                Text(task.detail!)
            }.padding()
            
            
            List{
                Section {
                    ForEach(microTasks){ microTask in
                        NavigationLink{
                            Text("TEST")
                        } label: {
                            HStack{
                                Text("\(microTask.order) : \(microTask.microTask!)")
                                Spacer()
                                Text("10 min").font(.caption)
                            }
                        }
                    }.onDelete(perform: deleteItems)
                } header: {
                    HStack{
                        Text("Micro tasks").bold().font(.title2)
                        Spacer()
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                        
                        Button("Edit") {
                            withAnimation() {
                                if editMode?.wrappedValue == .inactive{
                                    editMode?.wrappedValue = .active
                                }else if editMode?.wrappedValue == .active {
                                    editMode?.wrappedValue = .inactive
                                }
                            }
                        }
                        
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle(task.task!)
            
        }
        
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            func rowRemove(offsets: IndexSet) {
                tasks.remove(atOffsets: offsets)
            }
            
        }
    }
    
    private func addItem() {
        print("TEST")
    }
    
}

struct TaskDetail_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetail(withChild: Task())
    }
}
