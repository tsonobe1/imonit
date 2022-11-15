//
//  ContentView.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var showingAddMicroTaskTextField = false

    var body: some View {

        TabView {
            TaskList() // 1枚目の子ビュー
                .tabItem {
                    Image(systemName: "1.circle.fill") // タブバーの①
                }

            Calender()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                }
        }
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
