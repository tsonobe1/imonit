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
    @ObservedObject var task: Task
    @State var showingAddMicroTaskTextField = false
    @State var showingEditSheet = false
    @State private var isOpenedDisclosure = true

    var body: some View {
        VStack(alignment: .leading) {
            //
            //
            // 📝 Taskの各種情報の表示
            //
            //
            VStack(alignment: .leading) {
                Text(task.task!)
                    .font(.title2)
                    .bold()
                // MARK: 子ViewのMicroTaskListから値を貰い、TrueならTaskのDateやDetailを隠す
                if !showingAddMicroTaskTextField {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "calendar")
                        VStack(alignment: .leading) {
                            Text(dateFormatter(date: task.startDate!))
                            HStack(spacing: 5) {
                                Text("from")
                                Text(dateTimeFormatter(date: task.startDate!))
                                Text("to")
                                Text(dateTimeFormatter(date: task.endDate!))
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding([.top, .bottom], 5)

                    DisclosureGroup("Show Detail", isExpanded: $isOpenedDisclosure) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "doc.plaintext")
                                Text(task.detail!)
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)

                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "figure.stand")
                                Text(task.detail!)
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)

                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "figure.stand")
                                Text(task.influence!) //
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)

                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "figure.stand")
                                Text(task.benefit!) //
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.subheadline)
                    .foregroundColor(isOpenedDisclosure ? .primary : .secondary)
                    .accentColor(isOpenedDisclosure ? .primary : .secondary)
                }
            }
            .padding(.horizontal)
            //
            //
            // 📝 MicroTaskのListの表示
            //
            //
            MicroTaskList(withChild: task, showingAddMicroTaskTextField: $showingAddMicroTaskTextField)
        }
        .navigationBarTitle("") // 無駄なスペースを削除
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    self.showingEditSheet.toggle()
                }
                .fullScreenCover(isPresented: $showingEditSheet) {
                    TaskEditSheet(task: task)
                }
            }
        }
    }
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
