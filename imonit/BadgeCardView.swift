//
//  BadgeCardView.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/08/21.
//

import SwiftUI

struct BadgeCardView: View {
    @State var title: String
    @State var value: String
    @State var valueColor: Color

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.caption2)
                .padding(4.0)
                .foregroundColor(.white)
                .background(Color(#colorLiteral(red: 0.1638943553, green: 0.164074719, blue: 0.1681288481, alpha: 1)))
            Text(value)
                .font(.caption2)
                .fontWeight(.bold)
                .padding(4.0)
                .padding(.horizontal, 8.0)
                .foregroundColor(.white)
                .background(valueColor)
        }
        .cornerRadius(8.0)
    }
}

struct BadgeCardView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeCardView(
            title: "Swift Package Manager",
            value: "compatible",
            valueColor: Color.green
        )
    }
}
