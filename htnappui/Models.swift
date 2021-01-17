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

struct JumpingJack: Move {
    var name: String = "Jumping"
    
    func checkActive(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> Bool {
        let lh = recognizedPoints[.bodyLandmarkKeyLeftHip]
        let la = recognizedPoints[.bodyLandmarkKeyLeftAnkle]
        let rh = recognizedPoints[.bodyLandmarkKeyRightHip]
        let ra = recognizedPoints[.bodyLandmarkKeyRightAnkle]

        let lw = recognizedPoints[.bodyLandmarkKeyLeftWrist]
        let le = recognizedPoints[.bodyLandmarkKeyLeftElbow]
        let rw = recognizedPoints[.bodyLandmarkKeyRightWrist]
        let re = recognizedPoints[.bodyLandmarkKeyRightElbow]
                
//        if lh != nil && la != nil && lh!.confidence > 0 && la!.confidence > 0 {
//            let angle = angleBetween(lh!.location, la!.location)
//            print("Left Jack Angle: \(angle)")
//
//            if angle > 1 {
//                return false
//            }
//        } else {
//            return false
//        }
//
//        if rh != nil && ra != nil && rh!.confidence > 0 && ra!.confidence > 0  {
//            let angle = angleBetween(rh!.location, ra!.location)
//            print("Right Jack Angle: \(angle)")
//
//            if angle > 1 {
//                return false
//            }
//        } else {
//            return false
//        }

        
        if lw != nil && le != nil && lw!.confidence > 0 && le!.confidence > 0  {
            let angle = angleBetween(lw!.location, le!.location)
            print("Left Jack Hand Angle: \(angle)")

            if angle > CGFloat.pi/3 || lw!.location.y > le!.location.y {
                return false
            }
        } else {
            return false
        }
        
        if rw != nil && re != nil && rw!.confidence > 0 && re!.confidence > 0  {
            let angle = angleBetween(rw!.location, re!.location)
            print("Right Jack Hand Angle: \(angle)")

            if angle > CGFloat.pi/3 || rw!.location.y > re!.location.y {
                return false
            }
        } else {
            return false
        }

        return true
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
        RoutineStep(repetitions: 5, move: JumpingJack()),
        
        
    ]
)

var routines = [routine1, routine1,routine1,routine1,routine1,routine1]
