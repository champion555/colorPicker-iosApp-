//
//  ViewController.swift
//  ColorPicker
//
//  Created by Admin on 5/12/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView! //View to display camera
    @IBOutlet weak var btnGallery: UIButton! // button to open Gallery
    @IBOutlet weak var btnPrevious: UIButton! // button to load previous work but not working
    
    var captureSession = AVCaptureSession()
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var image: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // control Open Gallery Button Style
        btnGallery.layer.borderWidth = 2
        btnGallery.layer.borderColor = UIColor.white.cgColor
        // control Previous Gallery Button Style
        btnPrevious.layer.borderWidth = 2
        btnPrevious.layer.borderColor = self.view.tintColor.cgColor
        //set up capture session
        setupCaptureSession()
        //set up devic
        setupDevice()
        //set up input and output
        setupInputOutput()
        //set up preview the photo that take from camera or gallery
        setupPreviewLayer()
        //start capture
        startRunningCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        //get Camera from device
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        //set the camera to back or front
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        //set up the backCamera to current camera
        currentCamera = backCamera
    }
    //getting the photo from camera(jpeg format)
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!) //if there is camera in device
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    //setting the previous image from taken image
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    //running camera
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func switchToFrontCamera() {

    }
    
    func switchToBackCamera() {

    }
    //open Gallery
    @IBAction func openGallery(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    //take Image when click Shooter
    @IBAction func imageCapture(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
}
//sending the photo that get from camera to preview controller
extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {

            image = UIImage(data: imageData)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
            vc.image = image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//sending the photo that get from gallery to filter controller
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        self.imagePicker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        vc.image = image
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
//extension UIImage {
//
//    func crop(size: CGSize, offset: CGPoint, scale: CGFloat = 1.0) -> UIImage? {
//        let rect = CGRect(x: offset.x * scale, y: offset.y * scale, width: size.width * scale, height: size.height * scale)
//        if let cropped = self.cgImage?.cropping(to: rect) {
//            return UIImage(cgImage: cropped)
//        }
//        return nil
//    }
//
//}
