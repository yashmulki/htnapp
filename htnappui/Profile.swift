//
//  Profile.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI
import SwiftyJSON
import AVKit

struct Profile: View {
    
    //@State var videos : JSON = JSON()
    @State var videos : [String] = []
    
    func loadData() {
        
        print("requesting")
        
        let urlStr : String = "https://exeroom-623bzrlseq-ue.a.run.app/archives"
        let url = URL(string: urlStr)
        guard let requestUrl = url else {
            print("failed")
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        print("monke")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("reeeee")
            
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("status code \(response.statusCode)")
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("response data string:\n \(dataString)")
                do {
                    if let dataFromString = try dataString.data(using: .utf8, allowLossyConversion: false) {
                        let json = try JSON(data: dataFromString)
                        
                        var strings : [String] = []
                        
                        for (index, subJson):(String, JSON) in json {
                            print("----------------")
                            print(subJson)
                            if let a = subJson.string {
                                strings.append(a)
                            }
                            print(type(of: index))
                        }
                        
                        videos.append(contentsOf: strings)
                    }
                } catch {
                    print("ruh roh")
                }
               
            }
        
        }
        task.resume()
        print("oooof")
        
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Image("mypfp").resizable().frame(width: 50, height: 50).clipShape(Circle()).padding()
                Text("Yash Monkey").font(.title).bold()
                Spacer()
                Button(action: {}, label: {
                    Image(systemName: "gear").foregroundColor(.white).font(.system(size: 30)).padding()
                })
            }
            
            Text("Clips").frame(height:30, alignment: .bottomLeading).offset(x:-140)
            
            ScrollView {
                ForEach(videos, id: \.self) { video in
                    VideoRow(link: video)
                }
            }
            
        }.onAppear(perform: loadData)
    }
}

struct VideoRow: View {
    
    let height = CGFloat(300)
    let width = CGFloat(11) / CGFloat(19.5) * CGFloat(300)
    let link: String
    
    var body: some View {
        HStack {
            VideoPlayer(player: AVPlayer(url: URL(string: link)!))
                .frame( height: height)
                .cornerRadius(25)
                .padding(8)
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}
