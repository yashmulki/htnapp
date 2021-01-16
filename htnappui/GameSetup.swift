//
//  GameSetup.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI
import Introspect

struct GameSetup: View {
    var routine: Routine
    @State var friendChosen: Bool = false
    @State var friend: Person? = nil

    @State var navigate = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        routine.coverImage.resizable().frame(width: 75, height: 75).clipShape(RoundedRectangle(cornerRadius: 15)).padding(.trailing, 15)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(routine.name).font(.title2).bold()
                            Text("\(routine.length) Minutes").font(.system(size: 15, weight: .light, design: .default))
                            HStack {
                                Image(systemName: "music.note")
                                Text(routine.associatedSong.name)
                            }.font(.system(size: 15, weight: .light, design: .default))
                        }
                        Spacer()
                    }.padding(.bottom, 20).padding(.top, 20).padding(.leading, 20)

                    // Just something to get started.
                    NavigationLink(
                        destination: Game(),
                        isActive: $navigate,
                        label: {
                            Text("Start Game")
                        }
                    ).padding(.vertical, 20)

                    HStack {
                        
                        VStack {
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding()
                                Text("You")
                            }.padding()
                            
                        }.background(Color(UIColor.secondarySystemBackground)).cornerRadius(20).padding(.trailing, 20)
                        
                        
                        if friendChosen {
                            VStack {
                                VStack {
                                    Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding()
                                    Text(friend!.name)
                                }.padding()
                                
                            }.background(Color(UIColor.secondarySystemBackground)).cornerRadius(20).onTapGesture {
                                withAnimation {
                                    friendChosen = false
                                }
                            }.padding(.trailing, 20)
                        } else {
                            VStack {
                                VStack {
                                    Text("Player 2")
                                    Text("(Optional)")
                                }.padding().padding([.top, .bottom], 45).padding([.leading, .trailing], 15)
                            }.overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        style: StrokeStyle(
                                            lineWidth: 2,
                                            dash: [15]
                                        )
                                    )
                                    .foregroundColor(.gray)
                            )
                        }
                        
                    }.padding(.bottom, 50)
                    
                    HStack {
                        Text("Friends")
                        Spacer()
                    }.padding(.leading, 20).padding(.bottom, 20)
                    
                    VStack {
                        HStack {
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("Adi")
                            }.onTapGesture {
                                friend = Person(name: "John")
                                withAnimation {
                                    friendChosen = true
                                }
                            }
                            Spacer()
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("Taylor")
                            }
                            Spacer()
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("Fred")
                            }
                        }
                        HStack {
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 5)
                                Text("John")
                            }.onTapGesture {
                                friend = Person(name: "John")
                                withAnimation {
                                    friendChosen = true
                                }
                            }
                            Spacer()
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("John")
                            }
                            Spacer()
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("John")
                            }
                        }
                        HStack {
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("John")
                            }.onTapGesture {
                                friend = Person(name: "John")
                                withAnimation {
                                    friendChosen = true
                                }
                            }
                            Spacer()
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("John")
                            }
                            Spacer()
                            VStack {
                                Image("mypfp").resizable().frame(width: 75, height: 75).clipShape(Circle()).padding(.bottom, 10)
                                Text("John")
                            }
                        }
                    }.padding([.leading, .trailing], 20)
                    
                }
            }
            Button(action: {
                print("Hello button tapped!")
            }) {
                Text("Start")
                    .padding([.leading, .trailing], 40)
                    .padding([.top, .bottom], 5)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 5)
                    )
            }.padding()
        }.navigationBarTitle(Text("Game Setup"), displayMode: .inline).introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
    }
}

//struct GameSetup_Previews: PreviewProvider {
//    static var previews: some View {
//        GameSetup()
//    }
//}
