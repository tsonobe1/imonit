//
//  MicroTaskAddButton.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/17.
//

import SwiftUI

struct MicroTaskAddButton: View {
    @Binding var showingAddMicroTaskTextField: Bool

    var body: some View {
        Button("Add Micro Tasks") {
            withAnimation(.default) {
                showingAddMicroTaskTextField.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .accentColor(Color.white)
        .background(Color.blue)
        .cornerRadius(15)
        .padding()
    }
}

struct MicroTaskAddButton_Previews: PreviewProvider {
    static var previews: some View {
        MicroTaskAddButton(showingAddMicroTaskTextField: .constant(true))
    }
}
