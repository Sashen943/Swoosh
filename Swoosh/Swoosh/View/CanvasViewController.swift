import UIKit
import Vision

class CanvasViewController: UIViewController {

    // MARK: @IBOutlet(s)

    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var numberImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Properties

    var requests = [VNRequest]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }

    // MARK: @IBAction(s)

    @IBAction func clearCanvasTap(_ sender: Any) {
        canvasView.clearCanvas()
        self.numberImageView.isHidden = true
        self.statusLabel.isHidden = true
    }

    @IBAction func recogniseTap(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])

        do {
            try imageRequestHandler.perform(self.requests)
            canvasView.clearCanvas()
        }
        catch {
            print(error)
        }
    }

    // MARK: Opertaion(s)

    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {fatalError("Error loading model")}
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        self.requests = [classificationRequest]
    }

    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func handleClassification (request:VNRequest, error:Error?) {

        guard let observations = request.results else {
            return
        }

        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.9})
            .map({$0.identifier})

        guard let number = classifications.last else {
            self.statusLabel.text = "Oops! You haven't drawn anything"
            self.statusLabel.isHidden = false
            return
        }
        DispatchQueue.main.async {
            self.numberImageView.isHidden = false
            self.numberImageView.image = UIImage(imageLiteralResourceName: number)
            self.statusLabel.text = "It seems that the number you have drawn looks like \(number)"
            self.statusLabel.isHidden = false
        }

    }

}
