//
//  Leaderboards.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI

struct Leaderboards: View {
    var body: some View {
        NavigationView{
            ScrollView{
                LeaderBoardRow(image: Image("aadi"), name: "Adi Chaudhry", xp: 10052, max: 10052, index: 1)
                LeaderBoardRow(image: Image("fred"), name: "Fred Gao",xp: 8402,max: 10052, index: 2 )
                LeaderBoardRow(image: Image("mypfp"), name: " Me",xp: 7400, max: 10052, index: 3 )
                LeaderBoardRow(image: Image("taylor"), name: "Taylor Whatley",xp: 5102, max: 10052, index: 4 )
                LeaderBoardRow(image: Image("person5"), name: "John Appleseed",xp: 4202, max: 10052, index: 5 )
                LeaderBoardRow(image: Image("person2"), name: "Jane Appleseed", xp: 3984, max: 10052, index: 6 )
                LeaderBoardRow(image: Image("person3"), name: "Jack Smith",xp: 2498, max: 10052, index: 7 )
            }.navigationBarTitle(Text("LeaderBoards"))
        }
    }
}

struct LeaderBoardRow: View {
    let image: Image
    let name: String
    let xp: Int
    let max: Int
    let index: Int
    var colorArray = [
        Color(UIColor(red: 248/255, green: 113/255, blue: 113/255, alpha: 1)),
        Color(UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1)),
        Color(UIColor(red: 185/255, green: 28/255, blue: 28/255, alpha: 1)),
        Color(UIColor(red: 251/255, green: 191/255, blue: 36/255, alpha: 1)),
        Color(UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1)),
        Color(UIColor(red: 52/255, green: 211/255, blue: 153/255, alpha: 1)),
        Color(UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1)),
        Color(UIColor(red: 5/255, green: 150/255, blue: 105/255, alpha: 1)),
        Color(UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1)),
        Color(UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)),
        Color(UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1)),
        Color(UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1)),
    ]
    
    var body: some View {
        HStack {
            image.resizable().frame(width: 50, height: 50).clipShape(Circle()).padding()
            VStack(alignment: .leading) {
                Text(name)
            }
            Spacer()
            Text("XP: \(xp)").opacity(1).padding()

        }.padding([.leading, .trailing], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).background(
            GeometryReader { geometry in
                Rectangle().fill(colorArray[index])
                    .blendMode(.multiply)
                    .blur(radius: 0.5)
                    .frame(width: CGFloat(xp) / CGFloat(max) * geometry.size.width)
            }
            
        )
    }
}


struct Leaderboards_Previews: PreviewProvider {
    static var previews: some View {
        Leaderboards()
    }
}
