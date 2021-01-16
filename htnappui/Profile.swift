//
//  Profile.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-16.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle")
                Text("Johnny Appleseed").font(.title).bold()
            }
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}
