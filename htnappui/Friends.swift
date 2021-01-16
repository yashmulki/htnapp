//
//  Friends.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI

struct Friends: View {
    var body: some View {
        NavigationView {
            ScrollView{
                FriendRow(image: Image("mypfp"), name: "Adi Chaudhry", activity: "Online", xp: 2532)
                FriendRow(image: Image("mypfp"), name: "Taylor Whatley", activity: "15m", xp: 9952)
                FriendRow(image: Image("mypfp"), name: "Fred Gao", activity: "1h", xp: 10342)
            }.navigationBarTitle(Text("Friends"))
        }
    }
}

struct FriendRow: View {
    let image: Image
    let name: String
    let activity: String
    let xp: Int
   
    var body: some View {
        HStack {
            image.resizable().frame(width: 50, height: 50).clipShape(Circle()).padding()
            VStack(alignment: .leading) {
                Text(name)
                Text("XP: \(xp)").opacity(0.7)
            }
            Spacer()
            Group {
                if activity == "Online" {
                    Circle().frame(width: 15, height: 15, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding().foregroundColor(.green)
                } else {
                    Text(activity).padding().opacity(0.7)
                }
            }
            
        }.padding([.leading, .trailing], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

struct Friends_Previews: PreviewProvider {
    static var previews: some View {
        Friends()
    }
}
