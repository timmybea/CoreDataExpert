//
//  DetailViewController.swift
//  Borrower
//
//  Created by Tim Beals on 2017-05-01.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TimeframeDelegate, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource {

    @IBOutlet weak var itemTitleTF: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var borrowedOnLabel: UILabel!
    @IBOutlet weak var returnedOnLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameTF: MLPAutoCompleteTextField!
    
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
        
        self.personNameTF.autoCompleteDelegate = self
        self.personNameTF.autoCompleteDataSource = self
        self.personNameTF.autoCompleteTableAppearsAsKeyboardAccessory = true
        self.personNameTF.autoCompleteTableBackgroundColor = UIColor.white
        
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
            
            if let person = borrowItem.person {
                if let imageView = personImageView {
                    if let imageData = person.image as? Data {
                        imageView.image = UIImage(data: imageData)
                    }
                }
                
                if let textField = personNameTF {
                    textField.text = person.name
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
                
                
                var currentPerson: Person? = nil
                
                if numberOfResults == 0 { //create a new person
                    
                    currentPerson = Person(context: moc)
                    
                } else { //add existing person
                    
                    var persons = [Person]()
                    
                    do {
                        persons = try moc.fetch(fetchRequest)
                    } catch {
                        print(error)
                    }
                    
                    if let foundPerson = persons.first {
                        currentPerson = foundPerson
                    }
                }
                
                //allow user to save or update person info
                if let currentPerson = currentPerson {
                    currentPerson.name = name
                    
                    if let image = personImageView.image {
                        currentPerson.image = NSData(data: UIImageJPEGRepresentation(image, 0.3)!)
                    }
                    currentPerson.addToBorrowItem(borrowItem)
                }
            }
        }
        do {
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
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
    
    //MARK: Autocomplete methods
    
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, possibleCompletionsFor string: String!) -> [Any]! {
        //provide complete list of person names
        
        var persons = [Person]()
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        
        do {
            persons = try moc.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        var nameArray = [String]()
        
        for person in persons {
            if let name = person.name {
                nameArray.append(name)
            }
        }
        
        return nameArray
    }

    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, didSelectAutoComplete selectedString: String!, withAutoComplete selectedObject: MLPAutoCompletionObject!, forRowAt indexPath: IndexPath!) {
        
        let predicate = NSPredicate(format: "name == %@", selectedString)
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.predicate = predicate
        
        var person: Person?
        
        do {
            person = try moc.fetch(fetchRequest).first
        } catch {
            print(error)
        }
        
        if let person = person {
            if let imageData = person.image as? Data {
                personImageView.image = UIImage(data: imageData)
            }
            
            if let name = person.name {
                personNameTF.text = name
            }
        }
    }
    
}

