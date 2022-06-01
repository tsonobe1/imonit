//
//  MicroTaskList.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/26.
//

import SwiftUI

struct MicroTaskList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
    @ObservedObject var task : Task
    
    @State private var showingAddSheet = false
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
    
    @State private var showingAddMicroTaskTextField = false
    @State private var microTask = ""
    @State private var minutes = 10
    
    var body: some View {
        // MARK: MicroTask is Not Exist
        if microTasks.isEmpty {
            Button("Add Micro Tasks"){
                withAnimation(.default){
                    openAddMicroTaskTextField()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(10)
            .accentColor(Color.white)
            .background(Color.blue)
            .cornerRadius(15)
            .padding()
            Spacer()
            
        }else{
            // MARK: MicroTask is Exist
            // MARK: List Header - Micro Tasks
            List{
                Section(header:  HStack(spacing: 20){
                    Text("Micro tasks")
                    Spacer()
                    // Add Button
                    Button("Add") {
                        withAnimation(.default){
                            openAddMicroTaskTextField()
                        }
                    }
                    // Edit Button
                    Button("Edit") {
                    withAnimation() {
                        if editMode?.wrappedValue == .inactive{
                            editMode?.wrappedValue = .active
                        }else if editMode?.wrappedValue == .active {
                            editMode?.wrappedValue = .inactive
                        }
                    }
                }.disabled(microTasks.isEmpty)
            }) {
                // MARK: List - Micro Tasks
                ForEach(microTasks){ microTask in
                    NavigationLink{
                        MicroTaskDetail(microTask: microTask)
                    } label: {
                        HStack{
                            Text("  \(microTask.order) : ").font(.caption)
                            Text("\(microTask.microTask!)").font(.callout)
                            Spacer()
                            Text("\(microTask.timer) min").font(.caption)
                        }
                    }
                    // Delete List Padding
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .onDelete(perform: deleteMicroTasks)
                .onMove(perform: moveMicroTasks)
                
            }
            .listRowSeparator(.hidden)
        }
            .listStyle(.plain)
        }
            
        
        // MARK: Form - Add Micro Tasks
        if showingAddMicroTaskTextField {
            Form{
                Section(footer: HStack{
                    Button(action: {
                        addMicroTasks()
                    }){
                        Spacer()
                        Text("Add micro tasks")
                            .font(.callout)
                            .padding(.top,5)
                        Spacer()
                    }
                    .disabled(microTask.isEmpty)
                }){
                    VStack{
                        HStack{
                            TextField("Micro Task Title", text: $microTask)
                            Picker(selection: $minutes, label:Text("Select")){
                                Spacer()
                                ForEach(1..<60, id: \.self) { i in
                                    Text("\(i) min").tag(i)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                }
            }
            .frame(height: 120)
            .transition(.move(edge: .bottom))
        }
    }
    
    // MARK: Function
    private func addMicroTasks(){
        let newMicroTasks = MicroTask(context: viewContext)
        newMicroTasks.microTask = microTask
        newMicroTasks.timer = Int16(minutes)
        newMicroTasks.order = Int16(microTasks.count+1)
        newMicroTasks.createdAt = Date()
        newMicroTasks.id = UUID()
        newMicroTasks.isDone = false
        newMicroTasks.task = task
        
        do {
            try viewContext.save()
            microTask = ""
            minutes = 10
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    private func openAddMicroTaskTextField(){
        showingAddMicroTaskTextField.toggle()
    }
    
    private func deleteMicroTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { microTasks[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            for (index, microTask) in microTasks.enumerated() {
                if microTask.order != index{
                    microTask.order = Int16(index+1)
                }
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    private func moveMicroTasks(from source: IndexSet, to destination: Int) {
        print("source first = \(source.first!)")
        print("destination = \(destination)")
        if source.first! < destination {
            let objectsShouldChange:[Int] = Array(source.first! + 1...destination - 1)
            print("objectsShouldChange \(objectsShouldChange)")
            for i in objectsShouldChange{
                microTasks[i].order = Int16(i)
            }
            microTasks[source.first!].order = Int16(destination)
        }
        else if source.first! > destination {
            let objectsShouldChange:[Int] = Array(destination..<source.first!)
            print("objectsShouldChange \(objectsShouldChange)")

            for i in objectsShouldChange{
                microTasks[i].order = Int16(i + 2)
            }
            microTasks[source.first!].order = Int16(destination + 1)
        }
        
        try? self.viewContext.save()
    }
    

}

struct MicroTaskList_Previews: PreviewProvider {
    static var previews: some View {
        MicroTaskList(withChild: Task())
    }
}
