
//  CanvasViewController.swift
//  Swoosh
//  Created by Sashen Pillay on 2019/03/24.
//  Copyright © 2019 Sashen Pillay. All rights reserved.
//

import UIKit
import Vision

class CanvasViewController: UIViewController {

    // MARK: @IBOutlets
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var recognitionLabel: UILabel!
    @IBOutlet weak var labelImageView: UIImageView!
    
    // MARK: Properties
    
    var requests = [VNRequest]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }
    
    // MARK: @IBActions
    
    @IBAction func clearCanvasTap(_ sender: Any) {
        canvasView.clearCanvas()
        recognitionLabel.text = ""
    }
    
    @IBAction func recogniseTap(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
            canvasView.clearCanvas()
        }catch{
            print(error)
        }
    }
    
    // MARK: Opertaions
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {fatalError("can not load Vision ML model")}
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
        guard let observations = request.results else {print("no results"); return}
        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.9})
            .map({$0.identifier})
    
        let number = classifications.last
        DispatchQueue.main.async {
            self.recognitionLabel.text = number
        }
        
    }

}
