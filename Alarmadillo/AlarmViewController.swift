//
//  AlarmViewController.swift
//  Alarmadillo
//
//  Created by Thang Le Tan on 9/13/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit

class AlarmViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var alarm: Alarm!

    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tapToSelectImage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let titleAttributes = [NSFontAttributeName: UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        //navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        title = alarm.name
        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time
        
        
        if alarm.image.characters.count > 0 {
            let imageFileName = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            imageView.image = UIImage(contentsOfFile: imageFileName.path)
            tapToSelectImage.isHidden = true
        }
        
    
        
        
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        let fm = FileManager()
        
        if alarm.image.characters.count > 0 {
            // the alarm already has an image, so delete it
            do {
                let currentImage =
                Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
                
                if fm.fileExists(atPath: currentImage.path ) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
            
        }
        
        do {
            //generate new filename for the image
            alarm.image = "\(UUID().uuidString).jpg"
            //write the new image to document directory
            let newPath =
                Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            let jpeg = UIImageJPEGRepresentation(image, 80)
            try jpeg?.write(to: newPath)
            
            save()
            
        } catch {
            print("Failed to save the new image")
        }
        
        //update user interface
        
        imageView.image = image
        tapToSelectImage.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        alarm.name = name.text!
        alarm.caption = caption.text!
        title = alarm.name
        
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func datePickerChanged(_ sender: AnyObject) {
        alarm.time = datePicker.date
        
        save()
    }

    @IBAction func imageViewTapped(_ sender: AnyObject) {
        
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func save() {
        NotificationCenter.default.post(name: NSNotification.Name("save"), object: nil)
    }
    
    
}
