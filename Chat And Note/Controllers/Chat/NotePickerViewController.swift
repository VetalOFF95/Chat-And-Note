//
//  NotePickerViewController.swift
//  Chat And Note
//
//  Created by  Vitalii on 21.03.2021.
//

import UIKit

final class NotePickerViewController: UIViewController {
    
    public var completion: ((Note) -> Void)?
    
    var notes = [Note]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(NoteTableViewCell.self,
                       forCellReuseIdentifier: NoteTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        
        DatabaseManager.shared.fetchNotes(for: email) { [weak self] notes in
            for note in notes {
                self?.notes.append(note)
            }
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

//MARK: - TableView
extension NotePickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier,
                                                 for: indexPath) as! NoteTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = notes[indexPath.row]
        
        // send this note
        navigationController?.popViewController(animated: true)
        completion?(model)
    }
}
