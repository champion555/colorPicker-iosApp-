//
//  PreviewViewController.swift
//  ColorPicker
//
//  Created by Admin on 5/12/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var image: UIImage! //the variable to receive the image from view controller

    @IBOutlet weak var btnCancel: UIButton! // cancel button
    @IBOutlet weak var photo: UIImageView! // view to display the image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image // displaying the image on view
        //cancel button style
        btnCancel.layer.borderWidth = 0.5
        btnCancel.layer.borderColor = UIColor.white.cgColor
    }
    //when click cancel button, go back to view controller
    @IBAction func onCancel(_ sender: Any) {
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
               self.navigationController?.pushViewController(vc, animated: true)
    }
    //when click use button, go to filter view controller
    @IBAction func onUse(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        vc.image = self.image
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
