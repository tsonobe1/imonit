//
//  MicroTaskAddSheet.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/06/01.
//

import SwiftUI

struct MicroTaskAddSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode

    var body: some View {
        VStack {
            Form {

            }
        }
    }
}

struct MicroTaskAddSheet_Previews: PreviewProvider {
    static var previews: some View {
        MicroTaskAddSheet()
    }
}
