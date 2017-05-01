//
//  NotebookViewController.swift
//  FirstCoreData
//
//  Created by Tim Beals on 2017-04-29.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit
import CoreData

class NotebookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    var moc: NSManagedObjectContext!
    
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        self.title = "Notebook Table"
        
        tableViewSetup()
        setupFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableViewSetup() {
        
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    //MARK: tableview delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellIdentifier")
        }
        let notebook = fetchedResultsController.object(at: indexPath)
        
        cell?.textLabel?.text = notebook.title
        
        return cell!
    }

    //MARK: update managed objects
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Change Title", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter new notebook title"
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            
            let textfield = alertController.textFields?.first
            let notebook = self.fetchedResultsController.object(at: indexPath)
            notebook.title = textfield?.text
            
            do {
                try self.moc.save()
            } catch {
                print(error)
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: delete managed objects

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notebook = fetchedResultsController.object(at: indexPath)
            notebook.managedObjectContext?.delete(notebook)
            
            do {
                try moc.save()
            } catch {
                print(error)
            }
        }
    }
    
    //fetched results controller delegate method. If the controller has deleted the managed object from the coredatabase, then delete the row in the tableView
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .delete {
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        } else if type == .update {
            configureCell(indexPath: indexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func configureCell(indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        let notebook = fetchedResultsController.object(at: indexPath)
        
        cell?.textLabel?.text = notebook.title
    }
}

