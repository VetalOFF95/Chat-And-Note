//
//  NewConversationViewController.swift
//  Chat And Note
//
//  Created by  Vitalii on 19.02.2021.
//

import UIKit
import JGProgressHUD

final class NewConversationViewController: UIViewController {
    
    private let newConversationVM = NewConversationVM()
    
    public var completion: ((SearchResult) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - TableView
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newConversationVM.getNumberOfSearchResults()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = newConversationVM.getSearchResultModel(forIndexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        let targetUserData = newConversationVM.getSearchResultModel(forIndexPath: indexPath)
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

//MARK: - SearchBar
extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        newConversationVM.removeAllSearchResults()
        spinner.show(in: view)
        
        newConversationVM.searchUsers(with: text, completion: updateUI)
        spinner.dismiss()
    }
    
    func updateUI() {
        if newConversationVM.isSearchResultsEmpty() {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
            tableView.reloadData()
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
