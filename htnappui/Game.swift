import Vision
import OpenTok
import SwiftUI
import Foundation
import AVFoundation

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
    @IBOutlet weak var preview: PreviewView!
    
    var captureSession: AVCaptureSession!
    var dispatchQueue: DispatchQueue?

    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?

    let imageWidth = 1280
    let imageHeight = 720

    var dots = [UIView]()

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
        captureSession.commitConfiguration()

        captureSession.startRunning()

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
                    dot.removeFromSuperview()
                }

                for point in imagePoints {
                    let newView = UIView(frame: CGRect(x: point.x, y: point.y, width: 20, height: 20))
                    newView.backgroundColor = .red

                    self.dots.append(newView)

                    self.preview.insertSubview(newView, at: 1)
                }
            }

            print(imagePoints)
        }
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
        guard let publisher = publisher else {
            return
        }

        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }

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

    func makeUIViewController(context: UIViewControllerRepresentableContext<GameController>) -> GameViewController {
        // No passing????
        let controller = UIStoryboard(name: "GameController", bundle: nil)
            .instantiateViewController(withIdentifier: "GameViewController") as! GameViewController

        // This will have to do if I want connect method to run during viewDidLoad I suppose.
        controller.vonageInfo = vonageInfo

        return controller
    }

    func updateUIViewController(_ uiViewController: GameViewController,
                                context: UIViewControllerRepresentableContext<GameController>) { }
    
    init(vonageInfo: VonageInfo?) {
        self.vonageInfo = vonageInfo
    }
}

struct Game : View {
    let vonageInfo: VonageInfo?

    var body: some View {
        GameController(vonageInfo: vonageInfo)
    }

    init(vonageInfo: VonageInfo? = nil) {
        self.vonageInfo = vonageInfo
    }
}
