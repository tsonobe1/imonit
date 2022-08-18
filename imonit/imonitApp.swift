//
//  imonitApp.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/18.
//

import SwiftUI

@main
struct ImonitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
