//
//  ProfileViewController.swift
//  Chat And Note
//
//  Created by  Vitalii on 19.02.2021.
//

import UIKit
import SDWebImage

final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private var presentedUserEmail: String?
    
    private var profileVM = ProfileVM()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .link
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        return imageView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addSubview(imageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .none
        
        presentedUserEmail = CacheManager.shared.getEmail()
        prepareProfileData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: view.width,
                                  height: 200)
        imageView.frame = CGRect(x: (headerView.width-150) / 2,
                                 y: 25,
                                 width: 150,
                                 height: 150)
        imageView.layer.cornerRadius = imageView.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentUserEmail = CacheManager.shared.getEmail()
        if presentedUserEmail != currentUserEmail {
            prepareProfileData()
            tableView.reloadData()
            presentedUserEmail = currentUserEmail
        }
    }
    
    private func prepareProfileData() {
        profileVM = ProfileVM()
        
        profileVM.addData(ProfileDataVM(viewModelType: .info,
                                        title: "Name: \(CacheManager.shared.getName() ?? "No Name")",
                                        handler: nil))
        profileVM.addData(ProfileDataVM(viewModelType: .info,
                                        title: "Email: \(CacheManager.shared.getEmail() ?? "No Email")",
                                        handler: nil))
        profileVM.addData(ProfileDataVM(viewModelType: .logout, title: "Log Out",handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "",
                                                message: "",
                                                preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                                style: .destructive,
                                                handler: { [weak self] _ in
                                                    
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    
                                                    AuthManager.shared.logOut()
                                                    
                                                    let vc = LoginViewController()
                                                    let nav = UINavigationController(rootViewController: vc)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    strongSelf.present(nav, animated: true)
                                                    
                                                }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            
            strongSelf.present(actionSheet, animated: true)
        }))
        
        fillTableHeader()
    }
    
    func fillTableHeader() {
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
                
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileVM.getNumberOfDataItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = profileVM.getProfileDataVM(forIndexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        profileVM.getProfileDataVM(forIndexPath: indexPath).handler?()
    }
}
