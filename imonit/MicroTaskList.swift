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
    @Binding var showingAddMicroTaskTextField: Bool
    
    @State private var showingAddSheet = false
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task, showingAddMicroTaskTextField: Binding<Bool>) {
        
        self._showingAddMicroTaskTextField = showingAddMicroTaskTextField
        self.task = task
        _microTasks = FetchRequest(
            entity: MicroTask.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \MicroTask.order, ascending: true)
            ],
            predicate: NSPredicate(format: "task == %@", task)
        )
    }
    
    @State private var newMicroTask = ""
    @State private var minutes = 10
    
    // for ScrollViewReader
    // Scroll to the buttom of the List only when adding microtasks.
    var microTasksCount: Int {
        get{
            microTasks.count
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            // MARK: MicroTask is Not Exist
            if microTasks.isEmpty && !showingAddMicroTaskTextField {
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
                ScrollViewReader{ scrollProxy in
                List{
                    Section(header:  HStack(spacing: 20){
                        Text("\(microTasks.count)  Micro tasks")
                        Spacer()
                        // Add Button
                        Button(showingAddMicroTaskTextField ? "Done" : "Add") {
                            withAnimation(.easeInOut){
                                openAddMicroTaskTextField()
                            }
                        }
                        .font(.body)
                        // Edit Button
                        Button(editMode?.wrappedValue == .active ? "Done" : "Edit") {
                            withAnimation() {
                                if editMode?.wrappedValue == .inactive{
                                    editMode?.wrappedValue = .active
                                }else if editMode?.wrappedValue == .active {
                                    editMode?.wrappedValue = .inactive
                                }
                            }
                        }
                        .font(.body)
                        .disabled(microTasks.isEmpty)
                    }) {
                        // MARK: List - Micro Tasks
                        ForEach(microTasks){ microTask in
                            NavigationLink{
                                MicroTaskDetail(microTask: microTask)
                            } label: {
                                HStack{
                                    Text("\(microTask.order) : ").font(.caption)
                                    Text("\(microTask.microTask!)").font(.callout)
                                    Spacer()
                                    Text("\(microTask.timer) min").font(.caption)
                                }
                            }
                        }
                        .onDelete(perform: deleteMicroTasks)
                        .onMove(perform: moveMicroTasks)
                        // Scroll to bottom when add microtask
                        // but it doesn't scroll when deleting or moving items.
                        .onChange(of: microTasks.count) { [microTasksCount] afterMicroTasksCount in
                            withAnimation{
                                // Only when adding items.
                                if microTasksCount < afterMicroTasksCount {
                                    scrollProxy.scrollTo(microTasks.last?.id)
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }

                //            .offset(y: !showingAddMicroTaskTextField ? 0 : -110)
                .listStyle(.plain)
                .zIndex(1)
                
            }
            }
            
            // MARK: Form - Add Micro Tasks
            if showingAddMicroTaskTextField {
                VStack{
                    Section(footer:
                                Button(action: {
                        addMicroTasks()
                    }){
                        Spacer()
                        Text("Add micro tasks")
                            .font(.callout)
                            .padding(.top,3)
                            .foregroundColor(Color.accentColor)
                        Spacer()
                    }
                        .disabled(newMicroTask.isEmpty)
                    ){
                        HStack(spacing: 0){
                            TextField("Micro Task Title", text: $newMicroTask)
                            Picker(selection: $minutes, label:Text("Select")){
                                Spacer()
                                ForEach(1..<60, id: \.self) { i in
                                    Text("\(i) min").tag(i)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                    }
                }
                .transition(.move(edge: .bottom))
                .padding()
                .background{
                    Color.black.opacity(0.87).blur(radius: 10, opaque: false)
                }
                .offset(y: 5)
                .frame(maxHeight: 100)
                .zIndex(2)
                
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    
    
    
    // MARK: Function
    private func addMicroTasks(){
        let newMicroTasks = MicroTask(context: viewContext)
        newMicroTasks.microTask = newMicroTask
        newMicroTasks.timer = Int16(minutes)
        newMicroTasks.order = Int16(microTasks.count+1)
        newMicroTasks.createdAt = Date()
        newMicroTasks.id = UUID()
        newMicroTasks.isDone = false
        newMicroTasks.task = task
        
        do {
            try viewContext.save()
            newMicroTask = ""
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
            MicroTaskList(withChild: newTask, showingAddMicroTaskTextField:  .constant(false))
                .environment(\.managedObjectContext, viewContext)
        }.navigationTitle("TEST")
            .preferredColorScheme(.dark)
    }
}

