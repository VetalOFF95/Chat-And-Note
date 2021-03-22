//
//  NotesViewController.swift
//  Chat And Note
//
//  Created by  Vitalii on 20.03.2021.
//

import UIKit

class NotesViewController: UIViewController {
    
    var notesVM = NotesVM(currentCategory: "No category")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = notesVM.getCurrentCategory()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notesVM.fetchNotes { [weak self] in self?.loadItems() }
    }
    
    func loadItems(){
        notesVM.sortNotesDescendingByDate()
        tableView.reloadData()
    }
 
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item",
                                      message: "Enter new item title",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] action in
            if !textField.text!.trimmingCharacters(in: .whitespaces).isEmpty,
               let category = self?.notesVM.getCurrentCategory() {
                
                let newItem = Note(title: textField.text!,
                                   dateCreated: Date(),
                                   parentCategory: category)
                self?.notesVM.addNote(note: newItem)
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

extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesVM.getNumberOfNotes()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = notesVM.getNoteTitle(for: indexPath)
        return cell
    }
}
