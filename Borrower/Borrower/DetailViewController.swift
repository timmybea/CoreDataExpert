//
//  DetailViewController.swift
//  Borrower
//
//  Created by Tim Beals on 2017-05-01.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TimeframeDelegate {

    @IBOutlet weak var itemTitleTF: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var borrowedOnLabel: UILabel!
    @IBOutlet weak var returnedOnLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameTF: UITextField!
    
    var moc: NSManagedObjectContext!
    
    var detailItem: BorrowItem? {
        didSet {
            self.configureView()
        }
    }
    
    var beginDate: NSDate?
    var endDate: NSDate?
    
    var personImageAdded = false
    var itemImageAdded = false
    
    enum PicturePurpose {
        case item
        case person
    }
    
    var picturePurposeSelector: PicturePurpose = .item

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let itemGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPictureToItem))
        itemImageView.addGestureRecognizer(itemGestureRecognizer)
        
        let personGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPictureToPerson))
        personImageView.addGestureRecognizer(personGestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if let borrowItem = detailItem {
            if let itemTextField = itemTitleTF {
                itemTextField.text = borrowItem.itemName
            }
            
            
            if let imageView = itemImageView {
                if let availableImageData = borrowItem.image as? Data {
                    imageView.image = UIImage(data: availableImageData)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"

            if let borrowOnLabel = borrowedOnLabel {
                if let availableStartDate = borrowItem.borrowFrom {
                    borrowOnLabel.text = "Borrow on: \(dateFormatter.string(from: availableStartDate as Date))"
                }
            }

            if let returnOnLabel = returnedOnLabel {
                if let availableEndDate = borrowItem.borrowTo {
                    returnOnLabel.text = "Borrow on: \(dateFormatter.string(from: availableEndDate as Date))"
                }
            }
        
        }
    }
    
    @IBAction func saveItemTouched(_ sender: Any) {
        
        var borrowItem: BorrowItem?
        
        if detailItem == nil {
            borrowItem = BorrowItem(context: moc)
        } else {
            borrowItem = detailItem
        }
        
        
        if let borrowItem = borrowItem {
            if itemTitleTF.text != nil {
                borrowItem.itemName = itemTitleTF.text
            }
            
            if let itemImage = itemImageView.image {
                borrowItem.image = NSData(data: UIImageJPEGRepresentation(itemImage, 0.3)!)
            }
            
            if let availableStartDate = beginDate {
                borrowItem.borrowFrom = availableStartDate
            }
            
            if let availableEndDate = endDate {
                borrowItem.borrowTo = availableEndDate
            }
            
            let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
            
            if let name = personNameTF.text {
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                fetchRequest.fetchLimit = 1
                
                let numberOfResults = try! moc.count(for: fetchRequest)
                
                if numberOfResults == 0 { //create a new person
                    
                    let newPerson = Person(context: moc)
                    
                    newPerson.name = name
                    
                    if let image = personImageView.image {
                        
                        newPerson.image = NSData(data: UIImageJPEGRepresentation(image, 0.3)!)
                        
                        
                    }
                    
                    
                    
                } else { //add existing person
                    
                }
                
                
                
                
            }
            
            
            
        }
        
        
        do {
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func addPictureToItem() {
        picturePurposeSelector = .item
        addImageWithPurpose()
    }

    func addPictureToPerson() {
        picturePurposeSelector = .person
        addImageWithPurpose()
    }
    
    func addImageWithPurpose() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        self.present(imagePickerController, animated: true)
    }

    
    //MARK: ImagePickerController delegate method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //scale image to make file size smaller
            let scaledImage = UIImage.scaleImage(image: image, toWidth: itemImageView.frame.width, andHeight: itemImageView.frame.height)
            
            if picturePurposeSelector == .item {
                //add to item imageView
                itemImageView.image = scaledImage
                itemImageAdded = true
            } else {
                //add to person imageView
                personImageView.image = scaledImage
                personImageAdded = true
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Timeframe delegate method
    
    func didSelectTimeframe(dateRange: GLCalendarDateRange) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        beginDate = dateRange.beginDate as NSDate?
        endDate = dateRange.endDate as NSDate?
        
        borrowedOnLabel.text = "Borrow on: \(dateFormatter.string(from: dateRange.beginDate))"
        returnedOnLabel.text = "Return on: \(dateFormatter.string(from: dateRange.endDate))"
        
    }
    
    //MARK: segue method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setDateRange" {
            let timeframeVC = segue.destination as! TimeframeViewController
            timeframeVC.timeframeDelegate = self
        }
    }
}

