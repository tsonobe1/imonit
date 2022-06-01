//
//  MicroTaskDetail.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/28.
//

import SwiftUI

struct MicroTaskDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var microTask: MicroTask
    
    var body: some View {

        VStack(alignment: .leading){
            
            HStack{
//                Spacer()
                Text(Image(systemName: "timer"))
                Text("\(microTask.timer) min")
            }

                    
                
                if let isDetail = microTask.detail{
                    Text(isDetail)
                }else{
                    Text("undefinde")
                }
                
                
            Spacer()
      
        }.navigationBarTitle(microTask.microTask!)
            .navigationBarTitleDisplayMode(.inline)
            .padding()

    }
}

//struct MicroTaskDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        MicroTaskDetail(microTask: MicroTask())
//    }
//}
