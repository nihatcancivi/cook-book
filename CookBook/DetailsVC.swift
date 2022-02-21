//
//  DetailsVC.swift
//  CookBook
//
//  Created by Nihat on 20.02.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var chosenFood : String?
    var chosendFoodId : UUID?

    @IBOutlet weak var foodDetailText: UITextView!
    @IBOutlet weak var foodNameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenFood != "" {
            
            //core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Foods")

            let idString = chosendFoodId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            foodNameText.text = name
                        }
                        if let details = result.value(forKey: "details") as? String{
                            foodDetailText.text = details
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            }catch{
                print("Error")
            }
        }else{
            //Navigation Bar Button
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonClicked))
            
        }
        

        
        let keyboardRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardRecognizer)
        
        //Image Gesture Recognizer
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    @objc func imageTapped(){
        let picker = UIImagePickerController()
        picker.delegate = self
        
        //Alert
        let alert = UIAlertController(title: "Seçiniz", message: "Bir fotoğraf çek veya galeriden bir resim seç.", preferredStyle: UIAlertController.Style.alert)
        let cameraButton = UIAlertAction(title: "Kamera", style: UIAlertAction.Style.default) { UIAlertAction in
            //camera control
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        picker.sourceType = .camera
                        self.present(picker, animated: true, completion: nil)
            }
                    else {
                        print("Kamera uygun değil")
                    }
        }
        let photoLibraryButton = UIAlertAction(title: "Galeri", style: UIAlertAction.Style.default) { UIAlertAction in
        
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        picker.allowsEditing = true
        alert.addAction(cameraButton)
        alert.addAction(photoLibraryButton)
        self.present(alert, animated: true, completion: nil)

        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        navigationItem.rightBarButtonItem?.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonClicked(){
        print("save tıklandı")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newFoods = NSEntityDescription.insertNewObject(forEntityName: "Foods", into: context)
        
        newFoods.setValue(foodNameText.text, forKey: "name")
        newFoods.setValue(foodDetailText.text, forKey: "details")
        newFoods.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newFoods.setValue(data, forKey: "image")
        do{
            try context.save()
            print("success")
            
        }catch{
            print("Kaydedilemedi")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
        
    }
   
}
