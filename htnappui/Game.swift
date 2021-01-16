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
    
    var leftHandParticles: CALayer!
    var rigthHandParticles: CALayer!
    
    var captureSession: AVCaptureSession!
    var dispatchQueue: DispatchQueue?

    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?

    let imageWidth = 1280
    let imageHeight = 720
    
    
    // Also should keep polling the backend probably to check for other person's score (once every second?)
    // Also send our score each time
    func pollServer() {
        
    }
    

    // tracking exercise
    
    var routine: Routine!
    var activitiesIndex = 0
    var activitiesCompletedRepetition = 0
    
    var lastCompletionTimeStamp: Date = Date()
    
    func checkIfExercise(recognizedPoints: [VNRecognizedPoint]) {
        DispatchQueue.main.async { [self] in
            
            // Make sure it doesn't keep repeated counting
            if Date().timeIntervalSince(self.lastCompletionTimeStamp).isLess(than: 0.5) {
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
            
            headerLabel.text = "Activity \(activitiesIndex + 1)/\(routine.steps.count)    \(activitiesCompletedRepetition)/\(routine.steps[activitiesIndex].repetitions)"
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

        
        captureSession.addInput(videoDeviceInput)

        let videoOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoOutput) else { return }

        dispatchQueue = DispatchQueue(label: "camera")
        videoOutput.setSampleBufferDelegate(self, queue: dispatchQueue)

//        captureSession.sessionPreset = .medium
        captureSession.addOutput(videoOutput)
        captureSession.connections.first!.videoOrientation = .portraitUpsideDown
        captureSession.commitConfiguration()
//        captureSession.startRunning()
        preview?.videoPreviewLayer.session = captureSession
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            self.pollServer() // Polls every second, can change as desired
        }

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
        return

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

            
            // Retrieve the CGPoints containing the normalized X and Y coordinates.
            let imagePoints: [CGPoint] = torsoKeys.compactMap {
                guard let point = recognizedPoints[$0], point.confidence > 0 else {
                    return nil
                }

                // Translate the point from normalized-coordinates to image coordinates.
                return VNImagePointForNormalizedPoint(point.location,
                    Int(preview?.frame.width ?? 100), Int(preview?.frame.height ?? 100))
            }

            DispatchQueue.main.async {
                for dot in self.dots {
                    dot.removeFromSuperlayer()
                }
                
                for point in imagePoints {
                    let node = CAShapeLayer()
                    node.fillColor = UIColor.white.cgColor
                    node.path = UIBezierPath(ovalIn: CGRect(x: point.x  , y: point.y, width: 20, height: 20)).cgPath;
                    self.dots.append(node)
                    self.preview.layer.addSublayer(node)
                    
                    if let rw = recognizedPoints[.bodyLandmarkKeyRightWrist], rw.confidence > 0, let re = recognizedPoints[.bodyLandmarkKeyRightElbow], rw.confidence > 0 {

                        let rightWrist = VNImagePointForNormalizedPoint(rw.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        let rightElbow = VNImagePointForNormalizedPoint(re.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        self.drawLine(onLayer: self.preview.layer, fromPoint: rightWrist, toPoint: rightElbow)
                    }
                    
                    if let rs = recognizedPoints[.bodyLandmarkKeyRightShoulder], rs.confidence > 0, let re = recognizedPoints[.bodyLandmarkKeyRightElbow], re.confidence > 0 {
                        
                        let rightShoulder = VNImagePointForNormalizedPoint(rs.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        let rightElbow = VNImagePointForNormalizedPoint(re.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        self.drawLine(onLayer: self.preview.layer, fromPoint: rightShoulder, toPoint: rightElbow)
                    }
                    
                    if let rs = recognizedPoints[.bodyLandmarkKeyRightShoulder], rs.confidence > 0, let ls = recognizedPoints[.bodyLandmarkKeyLeftShoulder], ls.confidence > 0 {
                        
                        let rightShoulder = VNImagePointForNormalizedPoint(rs.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        let leftShoulder = VNImagePointForNormalizedPoint(ls.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        self.drawLine(onLayer: self.preview.layer, fromPoint: rightShoulder, toPoint: leftShoulder)
                    }
                    
                    if let lw = recognizedPoints[.bodyLandmarkKeyLeftWrist], lw.confidence > 0, let le = recognizedPoints[.bodyLandmarkKeyLeftElbow], le.confidence > 0 {
                        
                        let leftWrist = VNImagePointForNormalizedPoint(lw.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        let leftElbow = VNImagePointForNormalizedPoint(le.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        self.drawLine(onLayer: self.preview.layer, fromPoint: leftWrist, toPoint: leftElbow)
                    }
                    
                    if let ls = recognizedPoints[.bodyLandmarkKeyLeftShoulder], ls.confidence > 0, let le = recognizedPoints[.bodyLandmarkKeyLeftElbow], le.confidence > 0 {
                        
                        let rightShoulder = VNImagePointForNormalizedPoint(ls.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        let rightElbow = VNImagePointForNormalizedPoint(le.location,
                                                                        Int(self.preview?.frame.width ?? 100), Int(self.preview?.frame.height ?? 100))
                        self.drawLine(onLayer: self.preview.layer, fromPoint: rightShoulder, toPoint: rightElbow)
                    }
                }
            }

            print(imagePoints)
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
        self.dots.append(line)
    }
  
    
        
    
    // We store these and make it follow hands -> TODO
    func makeHandParticles() {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        let yellow = makeEmitterCell(color: UIColor.yellow)
        particleEmitter.emitterCells = [yellow]
        view.layer.addSublayer(particleEmitter)
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
    
    func repetitionactivtyParticles() {
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
        cell.birthRate = 3
        cell.lifetime = 7.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
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
    }
}

extension GameViewController : OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")

        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        publisher = OTPublisher(delegate: self, settings: settings)
        let capture = ExampleVideoCapture()
        capture.captureSession = captureSession
        publisher?.videoCapture = capture
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

//        guard let publisherView = publisher.view else {
//            return
//        }
//
//        let screenBounds = UIScreen.main.bounds
//        publisherView.frame = CGRect(
//            x: screenBounds.width - 150 - 20,
//            y: screenBounds.height - 150 - 20,
//            width: 150,
//            height: 150
//        )
//
//        view.addSubview(publisherView)
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
