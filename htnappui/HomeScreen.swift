//
//  HomeScreen.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-15.
//

import SwiftUI
import AVFoundation
import Combine

struct HomeScreen: View {
    @EnvironmentObject var state: UIStateModel
    @State var audioPlayer: AVAudioPlayer? = nil
    @State var sinks: [AnyCancellable] = []
    
    var body: some View {
        
       return NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack {
                    HStack {
                        Text("Exercise   ")
                        Text("Dance").opacity(0.6)
                    }.font(.system(size: 15, weight: .light, design: .default)).padding(.top, 10)
                    
                    HStack {
                        ForEach(0..<routines[state.activeCard].difficulty.rawValue + 1) {_ in
                            Image(systemName: "star.fill")
                        }
                    }.padding(.top, 30)
                    
                    SnapCarousel().padding(.top, 40)
                    VStack {
                        Text(routines[state.activeCard].name).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(.top,20)
                        Text("\(routines[state.activeCard].length) Minutes").font(.system(size: 15, weight: .ultraLight, design: .default))
                        
                        MusicDisplay().background(Color(UIColor.secondarySystemBackground)).cornerRadius(20).padding(.top, 50)
                        
                    }.offset(x: 0, y: -80)
                    
                    
                    
                }
            
            }.navigationBarHidden(true).onAppear {
                state.$activeCard.sink { (newVal) in
                    let path = Bundle.main.path(forResource: routines[state.activeCard].associatedSong.resourcePath, ofType: "mp3")
                    let url = URL(fileURLWithPath: path!)
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        audioPlayer?.volume = 0.2
//                        audioPlayer?.play()
                    } catch {
                        // error yikes
                    }
                }.store(in: &sinks)
            }
        }
    }
}

struct MusicDisplay: View {
    @EnvironmentObject var state: UIStateModel
    var body: some View {
        HStack {
            Image(systemName: "music.note").font(.system(size: 20)).padding(.trailing, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            VStack(alignment: .leading) {
                Text(routines[state.activeCard].associatedSong.name)
                Text(routines[state.activeCard].associatedSong.artist).font(.system(size: 14, weight: .ultraLight, design: .default))
            
            }
        }.padding([.top, .bottom], 20).padding([.leading, .trailing], 40)
    }
}

//struct HomeScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScreen()
//    }
//}
