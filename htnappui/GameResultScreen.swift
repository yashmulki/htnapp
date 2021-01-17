//
//  GameResultScreen.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI

struct GameResultScreen: View {
    @Binding var navigatedSuper: Bool
    var won: Bool
    
    var body: some View {
        ZStack {
            (won ? Color.green : Color.red).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                if won {
                    Image(systemName: "checkmark.shield.fill").resizable().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 125, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                } else {
                    Image(systemName: "xmark.shield.fill").resizable().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 125, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                Text(won ? "You Won!" : "You Lost")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(.top, 20)
                Spacer()
                
                Button(action: {
                    navigatedSuper = false
                }) {
                    Text("Go Home").padding([.leading, .trailing], 40)
                        .padding([.top, .bottom], 5)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 5)
                        )
                }
                
                Spacer()
            }
        }
    }
}
//
//struct GameResultScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        GameResultScreen(navigatedSuper: .constant(true), won: false)
//    }
//}
