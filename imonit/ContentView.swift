//
//  ContentView.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
//                WeeklyBar()
                VStack {
                    Text("Sat")
                    Text(selectedDate.DateToString(format: "d"))
                }
                DailyCalender(selectedDate: selectedDate)
            }
            .navigationBarHidden(true)
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
