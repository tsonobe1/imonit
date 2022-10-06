//
//  Calender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/30.
//

import SwiftUI

struct Calender: View {
    @State var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(selection: $selectedDate, label: { Text("Date") })
                NavigationLink(destination: DailyCalender(selectedDate: selectedDate)) {
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
