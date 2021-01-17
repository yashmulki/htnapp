import Vision
import OpenTok
import SwiftUI
import Foundation
import AVFoundation
import SpriteKit

class PreviewView : UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// Would be nice if this wasn't here.
let apiKey = "47084024"

// :/
struct VonageInfo {
    var sessionId = ""
    var token = ""
}

class GameViewController : UIViewController {
    @IBOutlet var preview: PreviewView!
    
    
    @IBAction func exitGame(_ sender: Any) {
        popCallBack()
    }
    
    
    @IBOutlet var headerLabel: UILabel!
    
    @IBOutlet var yourStreamView: RoundedCornerView!
    
    @IBOutlet var opponentStreamView: RoundedCornerView!
    
    @IBOutlet var opponentLabel: UILabel!
    
    @IBOutlet var youProgress: UIProgressView!
    
    @IBOutlet var opponentProgress: UIProgressView!
    
    var popCallBack: () -> Void = {}
    
    var leftHandEmitter: CAEmitterLayer!
    var rightHandEmitter: CAEmitterLayer!
    
    
    var leftHandNode = CGPoint()
    var rightHandNode = CGPoint()
    
    var captureSession: AVCaptureSession!
    var dispatchQueue: DispatchQueue?

    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?

    let imageWidth = 1280
    let imageHeight = 720
    
    var customInput: ExampleVideoCapture?
    var videoInput: AVCaptureDeviceInput?

    // tracking exercise
    
    var routine: Routine! = routine1
    var activitiesIndex = 0
    var activitiesCompletedRepetition = 0
    
    var lastCompletionTimeStamp: Date = Date()
    
    func checkIfExercise(recognizedPoints: [VNRecognizedPointKey:VNRecognizedPoint]) {
        DispatchQueue.main.async { [self] in
            // Make sure it doesn't keep repeated counting
            if Date().timeIntervalSince(lastCompletionTimeStamp).isLess(than: 1) {
                return
            }
            
            let move = routine.steps[activitiesIndex].move
            
            if move.checkActive(recognizedPoints: recognizedPoints) {
                lastCompletionTimeStamp = Date()
                activitiesCompletedRepetition += 1
            }
            
            if activitiesCompletedRepetition >= routine.steps[activitiesIndex].repetitions {
                // Move to next if available, or just end the game
                if activitiesIndex == routine.steps.count - 1 {
                    // Go to the game end screen
                } else {
                    // finishedActivityParticles() -> make this not trash first
                    activitiesIndex += 1
                    activitiesCompletedRepetition = 0
                }
            }
            
            headerLabel.text = "\(routine.steps[activitiesIndex].move.name)   \(activitiesCompletedRepetition)/\(routine.steps[activitiesIndex].repetitions)"
            youProgress.progress = (Float(activitiesIndex)/Float(routine.steps.count))
        }
    }

    var dots = [CAShapeLayer]()

    // Swift gods please forgive me.
    var vonageInfo: VonageInfo?

    func connectToSession(sessionId: String, token: String) {
        session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
        
        var error: OTError?
        session?.connect(withToken: token, error: &error)

        if error != nil {
            print(error!)
        }
    }

    func setupCapture() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
              captureSession.canAddInput(videoDeviceInput) else { return }
        
        videoInput = videoDeviceInput
        
        captureSession.addInput(videoDeviceInput)

        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
        ]
        
        guard captureSession.canAddOutput(videoOutput) else { return }

        dispatchQueue = DispatchQueue(label: "camera")
        videoOutput.setSampleBufferDelegate(self, queue: dispatchQueue)

        captureSession.sessionPreset = .hd1280x720
        captureSession.addOutput(videoOutput)
        captureSession.usesApplicationAudioSession = false

        captureSession.connections.first!.videoOrientation = .portraitUpsideDown
        captureSession.commitConfiguration()

        if vonageInfo == nil {
            captureSession.startRunning()
            makeHandParticles()
        }

        preview?.videoPreviewLayer.session = captureSession
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCapture()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCapture()
                } else {
                    print("Image session is not authorized.")
                }
            }

        default:
            print("Image session is not valid.")
            return
        }

        guard let vonageInfo = vonageInfo else { return }
        connectToSession(sessionId: vonageInfo.sessionId, token: vonageInfo.token)
        
        
        
    }

    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedPointsObservation] else {
            return
        }

        for observation in observations {
            guard let recognizedPoints = try? observation.recognizedPoints(forGroupKey: .all) else {
                return
            }

            // Torso point keys in a clockwise ordering.
            let torsoKeys: [VNRecognizedPointKey] = [
                .bodyLandmarkKeyLeftShoulder,
                .bodyLandmarkKeyRightShoulder,
                .bodyLandmarkKeyNeck,
                .bodyLandmarkKeyLeftElbow,
                .bodyLandmarkKeyRightElbow,
                .bodyLandmarkKeyLeftWrist,
                .bodyLandmarkKeyRightWrist,
                .bodyLandmarkKeyLeftHip,
                .bodyLandmarkKeyRightHip,
                .bodyLandmarkKeyRoot,
                .bodyLandmarkKeyLeftKnee,
                .bodyLandmarkKeyRightKnee,
                .bodyLandmarkKeyLeftAnkle,
                .bodyLandmarkKeyRightAnkle,
            ]

            checkIfExercise(recognizedPoints: recognizedPoints)
            
            // Retrieve the CGPoints containing the normalized X and Y coordinates.
            let imagePoints: [CGPoint] = torsoKeys.compactMap {
                guard let point = recognizedPoints[$0], point.confidence > 0 else {
                    return nil
                }

                // Translate the point from normalized-coordinates to image coordinates.
                return VNImagePointForNormalizedPoint(point.location,
                    Int(preview?.frame.width ?? 100), Int(preview?.frame.height ?? 100))
            }

            DispatchQueue.main.async { [self] in
                
                self.rightHandNode =  VNImagePointForNormalizedPoint(recognizedPoints[.bodyLandmarkKeyRightWrist]?.location ?? CGPoint(), Int(preview?.frame.width ?? 100), Int(preview?.frame.height ?? 100))

                self.leftHandNode = VNImagePointForNormalizedPoint(recognizedPoints[.bodyLandmarkKeyLeftWrist]?.location ?? CGPoint(), Int(preview?.frame.width ?? 100), Int(preview?.frame.height ?? 100))

                self.moveHandParticles()
                
                self.drawPoints(imagePoints: imagePoints)
                self.drawLines(recognizedPoints: recognizedPoints)
            }
        }
    }

    func drawLine(_ a: VNRecognizedPoint?, _ b: VNRecognizedPoint?) {
        let width = Int(preview?.frame.width ?? 100)
        let height = Int(preview?.frame.height ?? 100)

        if let a = a, a.confidence > 0, let b = b, b.confidence > 0 {
            let aPoint = VNImagePointForNormalizedPoint(a.location, width, height)
            let bPoint = VNImagePointForNormalizedPoint(b.location, width, height)
            self.drawLine(onLayer: preview.layer, fromPoint: aPoint, toPoint: bPoint)
        }
    }

    func drawLines(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) {
        drawLine(recognizedPoints[.bodyLandmarkKeyRightWrist], recognizedPoints[.bodyLandmarkKeyRightElbow])
        drawLine(recognizedPoints[.bodyLandmarkKeyRightShoulder], recognizedPoints[.bodyLandmarkKeyRightElbow])
        drawLine(recognizedPoints[.bodyLandmarkKeyRightShoulder], recognizedPoints[.bodyLandmarkKeyLeftShoulder])
        drawLine(recognizedPoints[.bodyLandmarkKeyLeftWrist], recognizedPoints[.bodyLandmarkKeyLeftElbow])
        drawLine(recognizedPoints[.bodyLandmarkKeyLeftShoulder], recognizedPoints[.bodyLandmarkKeyLeftElbow])
    }

    func drawPoints(imagePoints: [CGPoint]) {
        for dot in dots {
            dot.removeFromSuperlayer()
        }

        for point in imagePoints {
            let node = CAShapeLayer()
            node.fillColor = UIColor.white.cgColor
            node.path = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 20, height: 20)).cgPath
            dots.append(node)
            preview.layer.addSublayer(node)
        }
    }
    
    func drawLine(onLayer layer: CALayer, fromPoint start: CGPoint, toPoint end: CGPoint)  {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.lineWidth = 50
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = UIColor.white.cgColor
        layer.addSublayer(line)
        dots.append(line)
    }

    func moveHandParticles() {
        leftHandEmitter?.emitterPosition = leftHandNode
        rightHandEmitter?.emitterPosition = rightHandNode
    }
    
    // We store these and make it follow hands -> TODO
    func makeHandParticles() {
        
        let yellow = makeEmitterCell(color: .yellow)
        
        leftHandEmitter = CAEmitterLayer()
        leftHandEmitter.emitterPosition = leftHandNode
        leftHandEmitter.emitterShape = .circle
        leftHandEmitter.emitterSize = CGSize(width: 10, height: 10)
        leftHandEmitter.emitterCells = [yellow]
        view.layer.addSublayer(leftHandEmitter)
        
        rightHandEmitter = CAEmitterLayer()
        rightHandEmitter.emitterPosition = rightHandNode
        rightHandEmitter.emitterShape = .circle
        rightHandEmitter.emitterSize = CGSize(width: 10, height: 10)
        rightHandEmitter.emitterCells = [yellow]
        view.layer.addSublayer(rightHandEmitter)
        
//        let particleEmitter = CAEmitterLayer()
//        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
//        particleEmitter.emitterShape = .line
//        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
//        let yellow = makeEmitterCell(color: UIColor.yellow)
//        particleEmitter.emitterCells = [yellow]
        
        
//        view.layer.addSublayer(particleEmitter)
    }
    
    // Obviously need to tune these
    func finishedActivityParticles() {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        let yellow = makeEmitterCell(color: UIColor.yellow)
        particleEmitter.emitterCells = [yellow]
        view.layer.addSublayer(particleEmitter)
    }

    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 7.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi / 2
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        cell.contents = UIImage(named: "particle_confetti")?.cgImage
        return cell
    }
    
}

extension GameViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            try requestHandler.perform([request])
        } catch {
            print("Error: \(error)")
        }
        
        customInput?.captureOutput(output, didOutput: sampleBuffer, from: connection)
    }
}

extension GameViewController : OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")

        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        publisher = OTPublisher(delegate: self, settings: settings)
        customInput = ExampleVideoCapture()
        customInput?.captureSession = captureSession
        customInput?.videoInput = videoInput
        publisher?.videoCapture = customInput
        guard let publisher = publisher else {
            return
        }

        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        captureSession.startRunning()
    }

    func sessionDidDisconnect(_ session: OTSession) {
        // sessions will just die if you disconnect soo oops
        print("The client disconnected from the OpenTok session.")
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")

        subscriber = OTSubscriber(stream: stream, delegate: self)
        guard let subscriber = subscriber else {
            return
        }

        var error: OTError?
        session.subscribe(subscriber, error: &error)

        guard error == nil else {
            print(error!)
            return
        }

        guard let subscriberView = subscriber.view else {
            return
        }

        let screenBounds = UIScreen.main.bounds
        subscriberView.frame = CGRect(
            x: screenBounds.width - 150 - 20,
            y: screenBounds.height - 150 - 20,
            width: 150,
            height: 150
        )

        view.addSubview(subscriberView)
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

extension GameViewController : OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

extension GameViewController : OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }

    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
}

struct GameController : UIViewControllerRepresentable {
    let vonageInfo: VonageInfo?
    @Binding var navigated: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<GameController>) -> GameViewController {
        // No passing????
        let controller = UIStoryboard(name: "GameController", bundle: nil)
            .instantiateViewController(withIdentifier: "GameViewController") as! GameViewController

        // This will have to do if I want connect method to run during viewDidLoad I suppose.
        controller.vonageInfo = vonageInfo
        controller.popCallBack = {
            navigated = false
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: GameViewController,
                                context: UIViewControllerRepresentableContext<GameController>) { }
}

struct Game : View {
    let vonageInfo: VonageInfo?
    @Binding var navigated: Bool

    var body: some View {
        GameController(vonageInfo: vonageInfo, navigated: $navigated).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}
