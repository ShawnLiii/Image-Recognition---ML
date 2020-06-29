//
//  ViewController.swift
//  Image Recognition - ML
//
//  Created by Shawn Li on 6/28/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    let imagePicker = UIImagePickerController()
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var resultLbl: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func pickImageTapped(_ sender: UIBarButtonItem)
    {
        setupImagePicker()
    }
    
    func setupImagePicker()
    {
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            cameraUnavaliableAlert()
        }
    }

    func cameraUnavaliableAlert()
    {
        let errorAlert = UIAlertController(title: "Camera is unavaliable", message: "You can select a picture from Library.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default){ _ in self.selectImageFromLibrary() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        errorAlert.addAction(confirmAction)
        errorAlert.addAction(cancelAction)
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    func selectImageFromLibrary()
    {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func handlePictureByML(image: UIImage)
    {
        guard let ciImage = CIImage(image: image) else { fatalError("Can't transfer UIImage to CIImage") }
        
        // Create Model
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else { fatalError("Load ML Model failed") }
        // Create Request
        let request = VNCoreMLRequest(model: model)
        { (request, error) in
            guard let results = request.results else { fatalError("Image Recognition Failed") }
            
            let classification = results as! [VNClassificationObservation]
            // Get Label
            self.resultLbl.text = classification.isEmpty ? "I can't recognize the image, I have to learn more" : "This is most likely \(classification.first!.identifier), might also be \(classification[1].identifier)."
        }
        // Fetch and Perform Request
        do
        {
            try VNImageRequestHandler(ciImage: ciImage).perform([request])
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        pictureImageView.image = image
        handlePictureByML(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
}

