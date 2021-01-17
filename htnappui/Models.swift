//
//  Routine.swift
//  htnappui
//
//  Created by Yashvardhan Mulki on 2021-01-15.
//

import SwiftUI
import Vision

enum RoutineDifficulty: Int {
    case easy = 0, medium = 1, hard = 2
}

enum RoutineType: Int {
    case exercise, dance
}

protocol Move {
    var name: String { get }
    var evidenceMinimum: Int { get }
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

func flip(_ p: CGPoint) -> CGPoint { CGPoint(x: 1 - p.x, y: 1 - p.y) }

struct Squats: Move {
    var name: String = "Squats"
    var evidenceMinimum: Int = 10
    
    func checkActive(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> Bool {
        let lh = recognizedPoints[.bodyLandmarkKeyLeftHip]
        let lk = recognizedPoints[.bodyLandmarkKeyLeftKnee]
        let rh = recognizedPoints[.bodyLandmarkKeyRightHip]
        let rk = recognizedPoints[.bodyLandmarkKeyRightKnee]

        if lh != nil && lk != nil && lh!.confidence > 0 && lk!.confidence > 0 {
            let angle = angleBetween(flip(lh!.location), flip(lk!.location))
            print("Left Squat Angle: \(angle)")

            if angle > 1 {
                return true
            }
        }

        if rh != nil && rk != nil && rh!.confidence > 0 && rk!.confidence > 0  {
            let angle = angleBetween(flip(rh!.location), flip(rk!.location))
            print("Right Squat Angle: \(angle)")

            if angle > 1 {
                return true
            }
        }

        return false
    }

}

struct JumpingJack: Move {
    var name: String = "Jumping Jacks"
    var evidenceMinimum: Int = 1
    
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
            let angle = angleBetween(flip(lw!.location), flip(le!.location))
            print("Left Jack Hand Angle: \(angle)")

            if angle > CGFloat.pi/3 || flip(lw!.location).y > flip(le!.location).y {
                return false
            }
        } else {
            return false
        }
        
        if rw != nil && re != nil && rw!.confidence > 0 && re!.confidence > 0  {
            let angle = angleBetween(flip(rw!.location), flip(re!.location))
            print("Right Jack Hand Angle: \(angle)")

            if angle > CGFloat.pi/3 || flip(rw!.location).y > flip(re!.location).y {
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
        RoutineStep(repetitions: 10, move: JumpingJack()),
        RoutineStep(repetitions: 10, move: Squats())
    ]
)

var routine2 = Routine(
    name: "Morning Workout",
    type: .exercise,
    difficulty: .easy,
    associatedSong: Song(name: "Here Comes the Sun", artist: "The Beatles", resourcePath: "hawaii"),
    length: 5,
    coverImage: Image("morning"),
    steps: [
        RoutineStep(repetitions: 10, move: JumpingJack()),
        RoutineStep(repetitions: 10, move: Squats())
    ]
)

var routine3 = Routine(
    name: "Extreme Exercise",
    type: .exercise,
    difficulty: .hard,
    associatedSong: Song(name: "Take on Me", artist: "A-ha", resourcePath: "hawaii"),
    length: 30,
    coverImage: Image("xtreme"),
    steps: [
        RoutineStep(repetitions: 10, move: JumpingJack()),
        RoutineStep(repetitions: 10, move: Squats())
    ]
)

var routines = [routine1, routine2, routine3]
