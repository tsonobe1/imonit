//
//  MonthlyCalender.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/30.
//

import SwiftUI

struct MonthlyCalender: View {
    let week:[String] = ["San","Mon","Tue","Wed","Thu","Fri","Sat"]
    @State var diff: Int = 0
    @State private var isNavigation = false // Navigation
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: Button for debugging
            Group {
                Stepper(value: $diff, in: -1000...1000) {
                    Text("Diff")
                }
                .foregroundColor(.brown)
                Button("Today") {
                    diff = 0
                }
            }
            
            let calendar = Calendar(identifier: .gregorian)
            let date = Date().changeMonth(diff: diff)
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            // Navigation to Day Detail
            NavigationLink(destination: DailyCalender(selectedDate: selectedDate), isActive: self.$isNavigation) {
                EmptyView()
            }
            
            // MARK: Year - Month
            Group {
                Text(date.DateToString(format: "Y"))
                    .bold()
                    .font(.title)
                +
                Text("  ")
                +
                Text(date.DateToString(format: "MMMM"))
                    .bold()
                    .font(.title3)
                    .foregroundColor(diff == 0 ? .red : .primary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(week, id: \.self) { i in
                    Text(i)
                }
                // 操作している日からdiff日移動させた日が属する月の初日〜最終日を取得
                let days:[Date] = date.getAllDays()
                // ↑で取得した月の初日の曜日を取得
                let start = days[0].getWeekDay()
                let end = start + days.count
                
                // 6 * 7のマス目を作成
                ForEach((0...41), id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.thinMaterial)
                            .frame(width: 50, height: 50)
                        
                        if(index >= start && index < end) {
                            // 表示の位置をズラす
                            let i = index - start
                            Text(days[i].DateToString(format: "d"))
                                .font(.title2)
                                .foregroundColor(isSameMonthDate(days[i], Date()) ? .red : .primary)
                        }
                    }
                    .frame(width: 50, height: 45)
                    .onTapGesture {
                        isNavigation.toggle()
                        // 選択した日付のDateを生成してnavigationLinkに使う
                        selectedDate = calendar.date(from: DateComponents(year: year, month: month, day: index - start + 1))!
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct MonthlyCalender_Preview: PreviewProvider {
    static var previews: some View {
        MonthlyCalender()
            .preferredColorScheme(.dark)
    }
}



extension Date {
    // 本日の月の初日を取得
    func firstDayOfTheMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    mutating func plusOneDay() {
        self = Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    mutating func minusOneDay() {
        self = Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    // firstDayOfTheMonthをdiff月分ズラす
    func changeMonth(diff: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: diff, to: self)!
    }
    
    // 指定したDateの属する月のすべての日を取得
    func getAllDays() -> [Date] {
        var day1st = firstDayOfTheMonth()
        var days = [Date]()
        days.append(day1st)
        
        // day1stの属する月のすべてのday(1,2,3,4....,30,31)をdaysに追加する
        let range = Calendar.current.range(of: .day, in: .month, for: day1st)!
        for _ in 0..<range.count - 1 {
            day1st.plusOneDay()
            days.append(day1st)
        }
        return days
    }
    
    // 指定したDateの曜日を数値で返す -> Sun:0 Mon:1 Tue:2 Wed:3 Thu:4 Fri:5 Sat:6
    func getWeekDay() -> Int {
        Calendar.current.component(.weekday, from: self) - 1
    }
    
    func DateToString(format: String) -> String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = TimeZone.current
        df.dateFormat = format
        
        return df.string(from: self)
    }
}

// xxsstyleによるフォーマットは、出力形式をロケールによりローカライズしてくれる
func DatetoStringByStyle(date: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .long
    f.timeStyle = .none
    return f.string(from: date)
}

// ２つのDate(xx年xx月xx日にフォーマットしたstring)が、同じ年月日かどうかを判定する
func isSameMonthDate(_ date1: Date, _ date2: Date) -> Bool {
    DatetoStringByStyle(date: date1) == DatetoStringByStyle(date: date2)
}

