//
//  Calender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/30.
//

import SwiftUI

struct Calender: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: WeeklyCalender()) {
                    Text("Weekcly")
                }
                NavigationLink(destination: MonthlyCalender()) {
                    Text("Monthly")
                }
            }
            .navigationTitle("Calender")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Calender_Previews: PreviewProvider {
    static var previews: some View {
        Calender()
    }
}
