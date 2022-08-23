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
    @Binding var showingAddMicroTaskTextField: Bool

    // MARK: 親Viewで選択したTaskを使い、MicroTasksをFetchする
    @ObservedObject var task: Task
    @FetchRequest var microTasks: FetchedResults<MicroTask>
    init(withChild task: Task, showingAddMicroTaskTextField: Binding<Bool>) {
        // showingAddMicroTaskTextFieldは、Addをタップした時にTaskのDateやDetailを隠すのに使う
        self._showingAddMicroTaskTextField = showingAddMicroTaskTextField
        self.task = task
        _microTasks = FetchRequest(
            entity: MicroTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \MicroTask.order, ascending: true)],
            predicate: NSPredicate(format: "task == %@", task)
        )
    }

    // MicroTaskのListの下部に表示
    private var totalTime: Int {
        var total = 0
        for minute in microTasks {
            total += Int(minute.timer / 60)
        }
        return total
    }

    @State private var isStartMicroTask = false

    // MicroTask追加時にListの最下部にScrollするためのプロパティ
    private var microTasksCount: Int { microTasks.count }

    var body: some View {
        // 👉 MicroTaskが存在しない場合
        if microTasks.isEmpty && !showingAddMicroTaskTextField {
            MicroTaskAddButton(showingAddMicroTaskTextField: $showingAddMicroTaskTextField)
        }
        // 👉 MicroTaskが存在する場合
        else {
            ScrollViewReader { scrollProxy in
                List {
                    Section(
                        //
                        //
                        // 📝 Header & Footer
                        //
                        //
                        header: HStack(spacing: 20) {
                            Text("\(microTasks.count)  Micro tasks")
                                .font(.caption)
                            Spacer()
                            // 🔘 Add Button
                            if showingAddMicroTaskTextField == false {
                            Button(showingAddMicroTaskTextField ? "Done" : "Add") {
                                withAnimation(.easeInOut) {
                                    showingAddMicroTaskTextField.toggle()
                                }
                            }
                            .font(.body)
                            }
                            // 🔘 Edit Button
                            Button(editMode?.wrappedValue == .active ? "Done" : "Edit") {
                                withAnimation {
                                    if editMode?.wrappedValue == .inactive {
                                        editMode?.wrappedValue = .active
                                    } else if editMode?.wrappedValue == .active {
                                        editMode?.wrappedValue = .inactive
                                    }
                                }
                            }
                            .font(.body)
                            .disabled(microTasks.isEmpty)
                        }, footer: HStack {
                            Spacer()
                            Text("Total : \(totalTime) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }) {
                        //
                        //
                        // 📝 MicroTasksのリスト
                        //
                        //
                        ForEach(microTasks) { microTask in
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(microTask.order) ").font(.footnote)
                                    .foregroundColor(.secondary)
                                Text("\(microTask.microTask!)").font(.subheadline)
                                    .strikethrough(microTask.isDone)
                                    .fontWeight(.regular)
                                Spacer()
                                Text("\(microTask.timer / 60) min").font(.caption)
                            }
                            .padding(.vertical, 10)
                            .foregroundColor(microTask.isDone ? Color.secondary : Color.primary)
                            // .backgroundにNavigationリンクを指定してopacity0にすることでNavigationLinkの矢印>を非表示にする
                            .background(
                                NavigationLink("", destination: MicroTaskDetail(microTask: microTask))
                                    .opacity(0)
                            )
                            //
                            //
                            // 🫲 MicroTasks ListのSwipeアクション
                            //
                            //
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    isStartMicroTask.toggle()
                                } label: {
                                    Image(systemName: isStartMicroTask ? "stop.circle.fill" : "timer")
                                }.tint(isStartMicroTask ? .red : .green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { microTaskIsDelete(microTask: microTask)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteMicroTasks)
                        .onMove(perform: moveMicroTasks)
                        // MicroTaskを追加したときに、リストの最下部にScrollする
                        .onChange(of: microTasks.count) { [microTasksCount] afterMicroTasksCount in
                            withAnimation {
                                // Only when adding items.
                                if microTasksCount < afterMicroTasksCount {
                                    scrollProxy.scrollTo(microTasks.last?.id)
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                //
                //
                // 📝 MicroTaskの追加フォーム
                //
                //
                .safeAreaInset(edge: .bottom) {
                    if showingAddMicroTaskTextField {
                        VStack {
                            MicroTaskAddModal(task: task, showingAddMicroTaskTextField: $showingAddMicroTaskTextField, microTasksCount: microTasksCount)
                        }
                        .transition(.move(edge: .bottom))
                        .padding()
                        .background(.ultraThinMaterial)
                    }
                }
            }
        }
    }

    private func microTaskIsDone(microTask: MicroTask) {
        microTask.isDone.toggle()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func microTaskIsDelete(microTask: MicroTask) {
        withAnimation {
            viewContext.delete(microTask)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            //            for (index, microTask) in microTasks.enumerated() {
            //                if microTask.order != index {
            //                    microTask.order = Int16(index + 1)
            //                }
            //            }
            for (index, microTask) in microTasks.enumerated() where microTask.order != index {
                microTask.order = Int16(index + 1)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
            for (index, microTask) in microTasks.enumerated() where microTask.order != index {
                microTask.order = Int16(index + 1)
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
            let objectsShouldChange: [Int] = Array(source.first! + 1...destination - 1)
            print("objectsShouldChange \(objectsShouldChange)")
            for items in objectsShouldChange {
                microTasks[items].order = Int16(items)
            }
            microTasks[source.first!].order = Int16(destination)
        } else if source.first! > destination {
            let objectsShouldChange: [Int] = Array(destination..<source.first!)
            print("objectsShouldChange \(objectsShouldChange)")

            for items in objectsShouldChange {
                microTasks[items].order = Int16(items + 2)
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
        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"

        let newMicroTask = MicroTask(context: viewContext)
        newMicroTask.microTask = "Duis aute irure dolor in reprehenderit in voluptate"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 600
        newMicroTask.createdAt = Date()
        newMicroTask.order = 0
        newMicroTask.task = newTask

        return NavigationView {
            MicroTaskList(withChild: newTask, showingAddMicroTaskTextField: .constant(false))
                .environment(\.managedObjectContext, viewContext)
        }.navigationTitle("TEST")
        .preferredColorScheme(.dark)
    }
}
