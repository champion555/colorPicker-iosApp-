//
//  ResultViewController.swift
//  ColorPicker
//
//  Created by Admin on 5/13/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Toast_Swift

class ResultViewController: UIViewController {
    
    var beforeImage: UIImage!
    var afterImage: UIImage!
    var compareImage: UIImage!

    @IBOutlet weak var comparePhoto: BeforeAfterView! //before and after view
    @IBOutlet weak var btnRedo: UIButton! // redo color button
    @IBOutlet weak var btnSave: UIButton! // save button
    @IBOutlet weak var btnAnother: UIButton! // cancel button
    @IBOutlet weak var toolView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //redo color button style setting
        btnRedo.layer.borderColor = self.view.tintColor.cgColor
        btnRedo.layer.borderWidth = 0.5
        //cancel button style setting
        btnAnother.layer.borderColor = UIColor.red.cgColor
        btnAnother.layer.borderWidth = 0.5
        
        comparePhoto.image1 = beforeImage
        comparePhoto.image2 = afterImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientation = false
    }
    // redo color button click event
    @IBAction func goFilter(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        vc.image = self.beforeImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // cancel button click event
    @IBAction func goAnother(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //save button click event
    @IBAction func goSave(_ sender: Any) {
        //save filtered image
        guard let image = afterImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, #selector(saveError(_:didFinishSavingWithError:contextInfo:)), nil)
        //save original image
        guard let image1 = beforeImage else { return }
        UIImageWriteToSavedPhotosAlbum(image1, nil, #selector(saveError(_:didFinishSavingWithError:contextInfo:)), nil)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // save image function
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Success!", message: "Your image has been saved to your photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

