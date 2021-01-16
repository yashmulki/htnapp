//
//  Routine.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-15.
//

import SwiftUI
import Vision

enum RoutineDifficulty: Int {
    case easy, medium, hard
}

enum RoutineType: Int {
    case exercise, dance
}

protocol Move {
    var name: String {get}
    func checkActive(recognizedPoints: [VNRecognizedPoint]) -> Bool // Basically takes in the set of points and confirms that you are in the right mode
}

struct RoutineStep {
    let repetitions: Int
    let move: Move
}

struct Song {
    let name: String
    let artist: String
    let resourcePath: String
}

struct Routine {
    let name: String
    let type: RoutineType
    let difficulty: RoutineDifficulty
    let associatedSong: Song
    let length: Int
    let coverImage: Image
    let steps: [RoutineStep]
}



struct JumpingJack: Move {
    
    var name: String = "Jumping Jack"
    
    func checkActive(recognizedPoints: [VNRecognizedPoint]) -> Bool {
        
        return true
    }

}

struct Person {
    var name: String
}

var routine1 = Routine(name: "Daily Challenge", type: .exercise, difficulty: .medium, associatedSong: Song(name: "Hawaii", artist: "The Beach Boys", resourcePath: "hawaii"), length: 15, coverImage: Image("exercise1"), steps: [])

var routines = [routine1, routine1,routine1,routine1,routine1,routine1]
