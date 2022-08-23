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
    @State private var showingEditSheet = false

    var body: some View {
        VStack(alignment: .leading) {

            Text(microTask.microTask!)
                .font(.title3)
                .bold()

            VStack {
                if let isDetail = microTask.detail {
                    Text(isDetail)
                } else {
                    EmptyView()
                }
            }
            .font(.footnote)
            .padding([.top, .bottom], 5)
            .foregroundColor(.secondary)

            // MARK: Timer
            MicroTaskTimer(microTask: microTask)
                .padding(10)

            Spacer()
        }
        .padding(.horizontal)
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    self.showingEditSheet.toggle()
                }
                .fullScreenCover(isPresented: $showingEditSheet) {
                    MicroTaskEditSheet(microTask: microTask)
                }
            }
        }

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
        newTask.influence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu"
        newTask.benefit = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"

        let newMicroTask = MicroTask(context: viewContext)
        newMicroTask.microTask = "Quis nostrud exercitation ullamco"
        newMicroTask.detail = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
        newMicroTask.id = UUID()
        newMicroTask.isDone = false
        newMicroTask.timer = 5
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
