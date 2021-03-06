//
//  AppDelegate.swift
//  FirstCoreData
//
//  Created by Tim Beals on 2017-04-27.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: NotebookViewController())
        
        
        //A basic fetchrequest for all persisted notebook instances
        let moc = persistentContainer.viewContext //moc = managed object context
        
        let notebookRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        notebookRequest.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        notebookRequest.sortDescriptors = [sortDescriptor]
        
        /*
        //A basic predicate will return a notebook based on the contents of its title string
        let keyPath = "title"
        let searchString = "Lots"
        let notebookPredicate = NSPredicate(format: "%K CONTAINS[c] %@", keyPath, searchString)
//        let notebookPredicate = NSPredicate(format: "title CONTAINS 'Lots'")*/

        //This more complex predicate will return a noteboook that has ANY one note that CONTAINS the given string.
        let notebookPredicate = NSPredicate(format: "ANY note.title CONTAINS[c] 'Number 20'")
            
        notebookRequest.predicate = notebookPredicate
        
        var notebookArray = [Notebook]()
        
        do {
            notebookArray = try moc.fetch(notebookRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        for notebook in notebookArray {
            print("This notebook is called \(notebook.title!) and was created at \(notebook.createdAt!)")
            displayNotes(notebook: notebook)
        }
        
        
        //Create and save a managed object
//        let notebookObject = Notebook(context: moc)
//        notebookObject.title = "Lots of Notes"
//        notebookObject.createdAt = Date() as NSDate
//        
//        //add a 'to-many' object to the notebook
//        for index in 1...25 {
//            
//            let noteObject = Note(context: moc)
//            noteObject.title = "Title Number \(index)"
//            noteObject.content = "Content Number \(index)"
//            noteObject.createdAt = Date() as NSDate
//            
//            notebookObject.addToNote(noteObject)
//        }
//        
//        do {
//            try moc.save()
//        } catch {
//            print(error.localizedDescription)
//        }
        
        return true
    }

    func displayNotes(notebook: Notebook) {
        
        if let noteSet = notebook.note as? Set<Note> {
            
            let noteOrderedArray = noteSet.sorted(by: { (noteA:Note, noteB:Note) -> Bool in
                return noteA.createdAt?.compare(noteB.createdAt as! Date) == ComparisonResult.orderedAscending
            })
            
            for note in noteOrderedArray {
                print("Note title: \(note.title!)")
            }
        }
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        saveContext()
    }
    
    
    //MARK: CoreData Stack

    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "FirstCoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription: NSPersistentStoreDescription, error: Error?) in
            if let error = error as NSError? {
                print(error.localizedDescription)
                
            }
        })
        return container
    }()
    
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

