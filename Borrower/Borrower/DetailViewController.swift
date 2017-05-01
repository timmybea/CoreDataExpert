//
//  DetailViewController.swift
//  Borrower
//
//  Created by Tim Beals on 2017-05-01.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController {

    @IBOutlet weak var itemTitleTF: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var borrowedOnLabel: UILabel!
    @IBOutlet weak var returnedOnLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameTF: UITextField!
    
    var moc: NSManagedObjectContext!
    
    var detailItem: BorrowItem? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        
        
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func saveItemTouched(_ sender: Any) {
        
        if detailItem == nil { //create new borrow item
            
            let borrowItem = BorrowItem(context: moc)
            
            if itemTitleTF.text != nil {
                borrowItem.itemName = itemTitleTF.text
            }

            
            
            
        } //else update an existing borrow item
        
        do {
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }



}

