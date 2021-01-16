import Vision
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

class GameViewController : UIViewController {
    @IBOutlet weak var preview: PreviewView!
    
    var captureSession: AVCaptureSession!
    var dispatchQueue: DispatchQueue?

    let imageWidth = 1280
    let imageHeight = 720

    var dots = [UIView]()

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
//
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

struct GameController : UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<GameController>) -> GameViewController {
        UIStoryboard(name: "GameController", bundle: nil)
            .instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    }

    func updateUIViewController(_ uiViewController: GameViewController,
                                context: UIViewControllerRepresentableContext<GameController>) { }
}

struct Game : View {
    var body: some View {
        GameController()
    }
}
