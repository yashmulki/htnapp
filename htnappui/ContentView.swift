//
//  ContentView.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeScreen().environmentObject(UIStateModel())
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
           
            Friends()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Friends")
                }
            Leaderboards()
                .tabItem {
                    Image(systemName: "xmark.shield.fill")
                    Text("Leaderboards")
                }
            Profile()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice(.init(rawValue: "iPhone 11 Pro"))
    }
}
