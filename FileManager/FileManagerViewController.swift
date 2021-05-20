//
//  FileManagerViewController.swift
//
//  Created by Dmitrii KRY on 17.05.2021.
//

import UIKit
import Foundation
import KeychainAccess


class FileManagerViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    let keychain = Keychain(service: "test", accessGroup: "test").accessibility(.whenUnlocked)
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Catalog"
        return label
    }()
    
    lazy var table: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        return table
    }()
    
    lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    lazy var alert: UIAlertController = {
        let alert = UIAlertController(title: "Create folder", message: "Please give a folder name", preferredStyle: .alert)
        alert.addTextField() { login in
            login.textColor = .black
            login.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            login.autocapitalizationType = .none
            login.tintColor = UIColor.init(named: "accentColor")
            login.placeholder = "Folder name"
        }
        
        let actionOk = UIAlertAction(title: "Create", style: .default) { [self] _ in
            guard let _ = alert.textFields?[0].text else { return }
            createFolder((alert.textFields![0].text)!)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        
        return alert
    }()
    
    let backToRootButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to ROOT", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToRootFunc), for: .touchUpInside)
        return button
    }()
    
    func repeatEnterPassword() {
        let alert = UIAlertController(title: "Passwords don't match", message: "Please try again", preferredStyle: .alert)
        present(alert, animated: true) { [self] in
            sleep(2)
            dismiss(animated: true) {
                loginAlert.textFields?[0].setValue(nil, forKey: "text")
                secondloginAlert.textFields?[0].setValue(nil, forKey: "text")
                present(loginAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    private var passWordText: String?
    
    @objc func addPassword() {
        passWordText = loginAlert.textFields?[0].text
    }

    
    lazy var secondloginAlert: UIAlertController = {
        let alert = UIAlertController(title: "Registration", message: "Please fill password", preferredStyle: .alert)
        alert.addTextField() { [self] login in
            login.textColor = .black
            login.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            login.autocapitalizationType = .none
            login.tintColor = UIColor.init(named: "accentColor")
            login.autocapitalizationType = .none
            login.placeholder = "Password"
        }
        
        let secondCreatePassword = UIAlertAction(title: "Повторите пароль", style: .default) { [self] _ in
            if loginAlert.textFields?[0].text != secondloginAlert.textFields?[0].text {
                repeatEnterPassword()
            } else {
                let alert = UIAlertController(title: "Success", message: "Password is set", preferredStyle: .alert)
                present(alert, animated: true) {
                sleep(2)
                dismiss(animated: true, completion: nil)
                }
            }
        }
        alert.addAction(secondCreatePassword)
        return alert
    }()
    
    lazy var loginAlert: UIAlertController = {
        let alert = UIAlertController(title: "Registration", message: "Please fill password", preferredStyle: .alert)
        alert.addTextField() { [self] login in
            login.textColor = .black
            login.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            login.autocapitalizationType = .none
            login.tintColor = UIColor.init(named: "accentColor")
            login.autocapitalizationType = .none
            login.placeholder = "Password"
        }
        
        let cretePassword = UIAlertAction(title: "Создайте пароль", style: .default) { [self] _ in
            
            present(secondloginAlert, animated: true, completion: nil)
   
        }
        let enterPassword = UIAlertAction(title: "Введите пароль", style: .default)
        alert.addAction(cretePassword)
        return alert
    }()

    var rootDirectory: URL?
    
    var directory: URL?
    
    var contentOfDirectory: [String]?

    lazy var constraints =
        [
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            backToRootButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            backToRootButton.heightAnchor.constraint(equalToConstant: 40),
            backToRootButton.widthAnchor.constraint(equalToConstant: 120),
            backToRootButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            table.heightAnchor.constraint(equalToConstant: 300),
            table.topAnchor.constraint(equalTo: backToRootButton.bottomAnchor, constant: 16),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ]
    
    init() {
        rootDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        super.init(nibName: nil, bundle: nil)
        guard let _ = rootDirectory else { return }
        currentDirectory(rootDirectory!)
        directory = rootDirectory
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showAlert() {
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showPicker() {
        present(picker, animated: true, completion: nil)
    }
    
    @objc func backToRootFunc() {
        currentDirectory(rootDirectory!)
        table.reloadData()
    }
    
    
    
    func createNavBarItems() {
        let createFolder = UIBarButtonItem(title: "Создать папку", style: .plain, target: self, action: #selector (showAlert))
        let addPhoto = UIBarButtonItem(title: "Добавить фото", style: .plain, target: self, action: #selector (showPicker))
        navigationItem.rightBarButtonItem = createFolder
        navigationItem.leftBarButtonItem = addPhoto
    }
    
    func currentDirectory(_ name: URL) {
        let content = try? FileManager.default.contentsOfDirectory(at: name, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).map(){ $0.lastPathComponent }
        guard let _ = content else { return }
        contentOfDirectory = content
        directory = name
    }

    
    func createFolder(_ name: String) {
        guard let _ = directory else { return }
        let newDirectory = directory!.appendingPathComponent(name, isDirectory: true)
        try? FileManager.default.createDirectory(atPath: newDirectory.path, withIntermediateDirectories: true, attributes: nil)
        currentDirectory(directory!)
        table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(headerLabel)
        view.addSubview(backToRootButton)
        view.addSubview(table)
        NSLayoutConstraint.activate(constraints)
        view.backgroundColor = .white
        createNavBarItems()
        present(loginAlert, animated: true, completion: nil)
        
    }
    
}

extension FileManagerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let _ = directory else { return nil }
        return "\(directory!.lastPathComponent)/"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = contentOfDirectory?.count else { return 0 }
        return count
        
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            guard let _ = contentOfDirectory?[indexPath.item] else { return UITableViewCell(style: .default, reuseIdentifier: "cell")}
            cell.textLabel?.text = contentOfDirectory![indexPath.item]
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let _ = directory else { return }
            guard let cellText = tableView.cellForRow(at: indexPath)?.textLabel?.text else { return }
            directory = directory!.appendingPathComponent(cellText)
            if (try? directory?.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false {
                currentDirectory(directory!)
                table.reloadData()
        }
        
    }

}

extension FileManagerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let saveImage = image.pngData()
        let imageUrl = directory?.appendingPathComponent("picture_" + String("abcd12345".randomElement()!)).appendingPathExtension("png")
        if FileManager.default.fileExists(atPath: imageUrl!.path) {
            dismiss(animated: true, completion: nil)
            let alertPicture = UIAlertController(title: "Try again", message: "picture already exists", preferredStyle: .alert)
            present(alertPicture, animated: true){ [self] in
                sleep(2)
                dismiss(animated: true, completion: nil)
            }
        } else {
            try? saveImage?.write(to: imageUrl!)
            currentDirectory(directory!)
            table.reloadData()
        }
        dismiss(animated: true, completion: nil)
        
    }
}

