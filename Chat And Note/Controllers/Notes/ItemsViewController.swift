//
//  ItemsViewController.swift
//  Chat And Note
//
//  Created by  Vitalii on 20.03.2021.
//

import UIKit

class ItemsViewController: UIViewController {
    
    var currentCategory: String?
    var items = [Note]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentCategory = currentCategory else {
            return
        }
        
        title = currentCategory
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        
        items = [Note]()
        
        DatabaseManager.shared.fetchNotes(for: email) { [weak self] notes in
            for note in notes {
                if note.parentCategory == self?.currentCategory {
                    self?.items.append(note)
                }
            }
            self?.loadItems()
        }
    }
    
    func loadItems(){
        
        items.sort {
            $0.dateCreated > $1.dateCreated
        }
        
        tableView.reloadData()
    }
 
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item",
                                      message: "Enter new item title",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] action in
            
            if !textField.text!.trimmingCharacters(in: .whitespaces).isEmpty,
               let category = self?.currentCategory {
                
                let newItem = Note(title: textField.text!,
                                   dateCreated: Date(),
                                   parentCategory: category)
                self?.items.append(newItem)
                
                guard let email = CacheManager.shared.getEmail() else {
                    return
                }
                DatabaseManager.shared.insertNoteItem(item: newItem, for: email) { success in
                    if success {
                        print("Item was added successfully !")
                    }
                }
            }
            
            self?.loadItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
}

extension ItemsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].title
        
        return cell
    }
}
