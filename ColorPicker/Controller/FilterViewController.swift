//
//  FilterViewController.swift
//  ColorPicker
//
//  Created by Admin on 5/12/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ChromaColorPicker
import CropViewController

class FilterViewController: UIViewController, UIPopoverPresentationControllerDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let colorPicker = ChromaColorPicker()
    let brightnessSlider = ChromaBrightnessSlider()

   
    var image: UIImage!
    var drawView: DrawView!
    var toolBar = UIToolbar()
    var picker = UIPickerView()
    var numOfButton: Int = 0
    var cColor: UIColor = UIColor(red: 1, green: 203 / 255, blue: 164 / 255, alpha: 0.5)
    var cTrans: CGFloat = 0.5
    var newRect: CGRect!
    var semiCircleImage: UIImage!
    var r: Int = 0
    var g: Int = 0
    var b: Int = 0

    @IBOutlet weak var photo: UIImageView! //view to display selected image
    @IBOutlet weak var btnFirst: UIButton! // select first color button
    @IBOutlet weak var btnSecond: UIButton! // select second color button
    @IBOutlet weak var btnDone: UIButton! // filter done button
    @IBOutlet weak var pickerView: UIView! // color picker view
    @IBOutlet weak var btnSelected: UIButton!
    @IBOutlet weak var transSlider: GradientSlider! // transparent control slider
    @IBOutlet weak var colorSlider: GradientSlider! // color control slider
    @IBOutlet weak var widthSlider: UISlider! // brush width control slider
    @IBOutlet weak var selectedColorView: UIView! // view to display selected color from color picker
    @IBOutlet weak var btnAuto: UIButton! //AutoBrush button
    @IBOutlet weak var btnUndo: UIButton! //Undo button
    @IBOutlet weak var btnRedo: UIButton! //Redo button
    @IBOutlet weak var btnClear: UIButton! //Clear button
    @IBOutlet weak var photoView: UIView! //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.isHidden = true // color picker view hidden
        
        // color slider style setting
        colorSlider.thickness = 20
        colorSlider.trackBorderWidth = 0.2
        colorSlider.trackBorderColor = UIColor.white
        
        //transparent slider style setting
        transSlider.thickness = 20
        transSlider.trackBorderWidth = 0.2
        transSlider.trackBorderColor = UIColor.white
        
        //Auto brush button style setting
        btnAuto.layer.borderColor = self.view.tintColor.cgColor
        btnAuto.layer.borderWidth = 1
        
        //color slider's original color setting
        colorSlider.minColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1) //first color to white color
        colorSlider.maxColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1) //second color to black color
        
        //transparent slider's original value setting
        transSlider.minColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0) //transparent to 0%
        transSlider.maxColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1) //transparent to 100%
        
        //first button style setting
        btnFirst.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        btnFirst.layer.borderWidth = 1
        btnFirst.layer.borderColor = colorSlider.maxColor.cgColor
        
        //second button style setting
        btnSecond.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        btnSecond.layer.borderWidth = 1
        btnSecond.layer.borderColor = colorSlider.minColor.cgColor
        
        //current color's original value
        cColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        colorSlider.thumbColor = cColor // color slider's thumb color to current color
        
        //image resizing
        self.image = resizeImage(image: self.image, targetSize: CGSize(width: self.image.size.width / 2, height: self.image.size.height / 2))
        //display image on view
        photo.image = self.image
        
//        let cropViewController = CropViewController(image: image)
//        cropViewController.delegate = self
//        present(cropViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getDrawView()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.enableAllOrientation = true
//    }
    
    func getDrawView() {
        //image aspect calculating
        let imgViewSize = photo.frame.size
        let imgSize = photo.image?.size

        let scaleW = imgViewSize.width / imgSize!.width
        let scaleH = imgViewSize.height / imgSize!.height

        var aspect: CGFloat

        if photo.image!.size.width > photo.image!.size.height {
            aspect = scaleW
        } else {
            aspect = scaleH
        }

        //making new view to fill image view
        var imageRect: CGRect = CGRect(x: 0, y: 0, width: imgSize!.width * aspect, height: imgSize!.height * aspect)
        imageRect.origin.x = (imgViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imgViewSize.height - imageRect.size.height) / 2

        imageRect.origin.x += photo.frame.origin.x
        imageRect.origin.y += photo.frame.origin.y

        let drawFrame = imageRect
        let dView: DrawView = DrawView(frame: drawFrame)
        dView.backgroundColor = UIColor.clear
        dView.alpha = 1
        drawView = dView
        photoView.addSubview(dView) // new view is added to current view
        drawView.color = cColor //new view's brushing color to current color
    }
    //first color setting
    @IBAction func selectFirstColor(_ sender: Any) {
        numOfButton = 1
        pickerView.isHidden = false
        changeColor()
        drawView.color = cColor
    }
    //seccont color setting
    @IBAction func selectSecondColor(_ sender: Any) {
        numOfButton = 2
        pickerView.isHidden = false
        changeColor()
    }
    //brushing undo
    @IBAction func onUndo(_ sender: Any) {
        drawView.undo()
    }
    //brushing redo
    @IBAction func onRedo(_ sender: Any) {
        drawView.reundo()
    }
    //all brushing clear
    @IBAction func onClear(_ sender: Any) {
        drawView.clear()
    }
    //change brush width
    @IBAction func changeBrushWidth(_ sender: Any) {
        drawView.lineWidth = CGFloat(widthSlider.value)
    }
    
    // Global variables
    var tag: Int = 0
    var color: UIColor = UIColor.gray
    
    // This function converts from HTML colors (hex strings of the form '#ffffff') to UIColors
    func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // UICollectionViewDataSource Protocol:
    // Returns the number of rows in collection view
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    // UICollectionViewDataSource Protocol:
    // Returns the number of columns in collection view
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 16
    }
    // UICollectionViewDataSource Protocol:
    // Inilitializes the collection view cells
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.tag = tag
        tag = tag + 1
        
        return cell
    }
    
    // Recognizes and handles when a collection view cell has been selected
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var colorPalette: Array<String>
        
        // Get colorPalette array from plist file
        let path = Bundle.main.path(forResource: "colorPalette", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path!)
        
        if let colorPalettePlistFile = pListArray {
            colorPalette = colorPalettePlistFile as! [String]
            
            let cell: UICollectionViewCell  = collectionView.cellForItem(at: indexPath)! as UICollectionViewCell
            let hexString = colorPalette[cell.tag]
            color = hexStringToUIColor(hexString)
            self.selectedColorView.backgroundColor = color
            
            //if first selecting,to first color setting
            if numOfButton == 1 {
                self.btnFirst.backgroundColor = color
                self.btnSecond.layer.borderColor = color.cgColor
                colorSlider.minColor = color
                colorSlider.thumbColor = color
                transSlider.minColor = color.withAlphaComponent(0.0)
                transSlider.maxColor = color.withAlphaComponent(1.0)
                self.cColor = color
            } else { // else, to second color setting
                self.btnSecond.backgroundColor = color
                colorSlider.maxColor = color
                self.btnFirst.layer.borderColor = color.cgColor
            }
        }
    }
    //when user slide the color slider, set the current color to selected color
    func changeColor() {
        let sColor = colorSlider.minColor
        let eColor = colorSlider.maxColor

        let sRgb = sColor.rgb()
        let eRgb = eColor.rgb()
        var cRgb = 0

        if eRgb! - sRgb! > 0 {
            cRgb = Int(CGFloat(abs(eRgb! - sRgb!)) * colorSlider.value) + sRgb!
        } else {
            cRgb = Int(CGFloat(abs(sRgb! - eRgb!)) * (1 - colorSlider.value)) + eRgb!
        }
        
        var t = (cRgb - sRgb!) / (eRgb! - sRgb!)
        
        t = max(Int(0.0), min(t, Int(1.0)))
        
        let sB = sRgb! & 0xFF
        let sG = (sRgb! >> 8) & 0xFF
        let sR = (sRgb! >> 16) & 0xFF
        
        let eB = eRgb! & 0xFF
        let eG = (eRgb! >> 8) & 0xFF
        let eR = (eRgb! >> 16) & 0xFF
        
        let iBlue = (CFloat(sB) + Float(colorSlider.value) * CFloat(eB - sB))
        let iGreen = (CFloat(sG) + Float(colorSlider.value) * CFloat(eG - sG))
        let iRed = (CFloat(sR) + Float(colorSlider.value) * CFloat(eR - sR))

        cColor = UIColor(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255, blue: CGFloat(iBlue)/255, alpha: cTrans)

        colorSlider.thumbColor = UIColor(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255, blue: CGFloat(iBlue)/255, alpha: 1.0)
        transSlider.minColor = UIColor(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255, blue: CGFloat(iBlue)/255, alpha: 0)
        transSlider.maxColor = UIColor(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255, blue: CGFloat(iBlue)/255, alpha: 1.0)
        
        photo.image = self.image
    }
    
    //filter color getting event
    @IBAction func getFilterColor(_ sender: Any) {
        changeColor()
        drawView.color = cColor
        drawView.recolor()
    }
    
    //transparent color setting event
    @IBAction func getTransparent(_ sender: Any) {
        cTrans = transSlider.value
        cColor = cColor.withAlphaComponent(cTrans)
        drawView.color = cColor
        drawView.recolor()
    }
    
    //filter done button click event
    @IBAction func doneFilter(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: drawView.bounds.size)
        let image = renderer.image { ctx in
            drawView.drawHierarchy(in: drawView.bounds, afterScreenUpdates: true)
        }
        let size = image.size

        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        photo.image?.draw(in: areaSize)
        image.draw(in: areaSize, blendMode: .normal, alpha: 1)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //go to result view controller
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        vc.beforeImage = self.image //sending original image
        vc.afterImage = newImage // sending filtered image
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func onSelected(_ sender: Any) {
        pickerView.isHidden = true
    }
    //image resizing function
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    
}

class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 20.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}
// rgb color to hexColor
extension UIColor {
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

private let defaultColorPickerSize = CGSize(width: 320, height: 320)
private let brightnessSliderWidthHeightRatio: CGFloat = 0.1
