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
    
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}
