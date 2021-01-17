//
//  GameSetup.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI
import Introspect

let api = "https://exeroom-623bzrlseq-ue.a.run.app"

struct GameSetup: View {
    var routine: Routine
    
    @Binding var superNavigate: Bool
    
    @State var friendChosen: Bool = false
    @State var friend: Person? = nil

    @State private var roomCode = ""
    @State var vonageInfo = VonageInfo()

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
                    }.padding(.bottom, 20).padding(.top, 120).padding(.leading, 20)

                    let binding = Binding<String>(get: {
                        roomCode
                    }, set: {
                        roomCode = $0

                        vonageInfo.sessionId = ""
                        vonageInfo.token = ""
                    })

                    // This is going to look so shitty lol.
                    TextField("Room Code", text: binding)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if roomCode.isEmpty {
                            let url = URL(string: "\(api)/rooms/create")!

                            let requestParams: [String:Any] = [
                                "user_id": UIDevice.current.name,
                                "workout": "quick"
                            ]
                            guard let requestData =
                                try? JSONSerialization.data(withJSONObject: requestParams) else { return }

                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.httpBody = requestData

                            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                guard let data = data else { return }

                                guard let json = try? JSONSerialization.jsonObject(
                                    with: data, options: []) as? [String: Any] else { return }
                                guard let roomId = json["room_id"] as? String else { return }
                                guard let sessionId = json["session_id"] as? String else { return }
                                guard let token = json["token"] as? String else { return }

                                roomCode = roomId

                                // I feel paralyzed to move this crazy action call out of the function.
                                vonageInfo.sessionId = sessionId
                                vonageInfo.token = token

                                print(sessionId)
                            }

                            task.resume()
                        } else {
                            let url = URL(string: "\(api)/rooms/join")!

                            let requestParams: [String:Any] = [
                                "room_id": roomCode,
                                "user_id": UIDevice.current.name
                            ]
                            guard let requestData =
                                try? JSONSerialization.data(withJSONObject: requestParams) else { return }

                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.httpBody = requestData

                            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                guard let data = data else { return }

                                guard let json = try? JSONSerialization.jsonObject(
                                    with: data, options: []) as? [String: Any] else { return }
                                guard let sessionId = json["session_id"] as? String else { return }
                                guard let token = json["token"] as? String else { return }

                                // ::::|||||
                                vonageInfo.sessionId = sessionId
                                vonageInfo.token = token
                            }

                            task.resume()
                        }
                    }) {
                        if !vonageInfo.sessionId.isEmpty {
                            Text("Connected")
                        } else if roomCode.isEmpty {
                            Text("New Room")
                        } else {
                            Text("Connect")
                        }
                    }

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
                        Text("Invite Friends")
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
            // Just something to get started.
            NavigationLink(
                destination: Game(vonageInfo: vonageInfo.sessionId.isEmpty ? nil : vonageInfo, navigated: $navigate, superNavigate: $superNavigate),
                isActive: $navigate,
                label: {
                    Text("Start")
                        .padding([.leading, .trailing], 40)
                        .padding([.top, .bottom], 5)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                        )
                  
                }
            ).padding(.vertical, 20)
            
        }.edgesIgnoringSafeArea(.all).navigationBarTitle(Text("Game Setup"), displayMode: .inline).introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
    }
}

//struct GameSetup_Previews: PreviewProvider {
//    static var previews: some View {
//        GameSetup()
//    }
//}
