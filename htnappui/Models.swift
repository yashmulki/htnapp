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
    func checkActive(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> Bool // Basically takes in the set of points and confirms that you are in the right mode
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


func angleBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    return atan2(abs(point1.x-point2.x), abs(point1.y-point2.y))
}

struct Squats: Move {
    var name: String = "Squats"
    
    func checkActive(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> Bool {
        let lh = recognizedPoints[.bodyLandmarkKeyLeftHip]
        let lk = recognizedPoints[.bodyLandmarkKeyLeftKnee]
        let rh = recognizedPoints[.bodyLandmarkKeyRightHip]
        let rk = recognizedPoints[.bodyLandmarkKeyRightKnee]

        if lh != nil && lk != nil && lh!.confidence > 0 && lk!.confidence > 0 {
            let angle = angleBetween(lh!.location, lk!.location)
            print("Left Squat Angle: \(angle)")

            if angle > 1 {
                return true
            }
        }

        if rh != nil && rk != nil && rh!.confidence > 0 && rk!.confidence > 0  {
            let angle = angleBetween(rh!.location, rk!.location)
            print("Right Squat Angle: \(angle)")

            if angle > 1 {
                return true
            }
        }

        return false
    }

}

struct Person {
    var name: String
}

var routine1 = Routine(
    name: "Daily Challenge",
    type: .exercise,
    difficulty: .medium,
    associatedSong: Song(name: "Hawaii", artist: "The Beach Boys", resourcePath: "hawaii"),
    length: 15,
    coverImage: Image("exercise1"),
    steps: [
        RoutineStep(repetitions: 5, move: Squats())
    ]
)

var routines = [routine1, routine1,routine1,routine1,routine1,routine1]
