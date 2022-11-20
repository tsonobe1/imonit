//
//  ContentView.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let week:[String] = ["San","Mon","Tue","Wed","Thu","Fri","Sat"]
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
//                WeeklyBar()
                HStack {
                    Button(action: {
                        selectedDate.minusOneDay()
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    Spacer()
                    HStack {
                        Text(selectedDate.DateToString(format: "M/d"))
                        Text("\(week[selectedDate.getWeekDay()])")
                    }
                    .foregroundColor(isSameMonthDate(selectedDate, Date()) ? .red : .primary)

                    Spacer()
                    Button(action: {
                        selectedDate.plusOneDay()
                    }, label: {
                        Image(systemName: "chevron.right")
                    })
                }
                .padding(.horizontal)
                DailyCalender(selectedDate: selectedDate)
                // MARK: Changed Date by Swipe
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onEnded({ value in
                                            if value.translation.width > 0 {
                                                print("<")
                                                withAnimation {
                                                    selectedDate.minusOneDay()
                                                }
                                            }

                                            if value.translation.width < 0 {
                                                print(">")
                                                withAnimation {
                                                    selectedDate.plusOneDay()
                                                }
                                            }
                                        }))
                    .transition(.slide)
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
