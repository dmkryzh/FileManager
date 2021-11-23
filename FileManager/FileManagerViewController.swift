//
//  FileManagerViewController.swift
//

import UIKit
import Foundation
import KeychainAccess


class FileManagerViewController: UIViewController {
    
    let keychain = Keychain(service: "test")
    
    private var passWordText: String?
    
    var rootDirectory: URL?
    
    var directory: URL?
    
    var contentOfDirectory: [String]? {
        didSet {
            if UserDefaults.standard.bool(forKey: "sort") {
                contentOfDirectory?.sort(by: <)
                table.reloadData()
            } else {
                contentOfDirectory?.sort(by: >)
                table.reloadData()
            }
        }
    }
    
    var isLogged = false
    
    var fullUrlPath: [URL]?
    
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
    
    lazy var secondloginAlert: UIAlertController = {
        let alert = UIAlertController(title: "Registration", message: "Password should be no longer then 4 symbols", preferredStyle: .alert)
        alert.addTextField() { [self] login in
            login.textColor = .black
            login.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            login.autocapitalizationType = .none
            login.tintColor = UIColor.init(named: "accentColor")
            login.autocapitalizationType = .none
            login.placeholder = "Password"
            login.textContentType = .password
            login.isSecureTextEntry = true
            login.delegate = self
        }
        
        let secondCreatePassword = UIAlertAction(title: "Повторите пароль", style: .default) { [self] _ in
            // если пароль в первом окне не совпадает с парорлем из второго окна то регистрируемся заново
            
            if !isLogged {
                
                if loginAlert.textFields?[0].text != alert.textFields?[0].text {
                    repeatEnterPassword()
                } else {
                    keychain["applicationPassword"] = alert.textFields?[0].text
                    let alert = UIAlertController(title: "Success", message: "Password is set", preferredStyle: .alert)
                    present(alert, animated: true) {
                        sleep(2)
                        dismiss(animated: true) {
                            isLogged = true
                        }
                    }
                }
                //юзер залогинен
                isLogged = true
            }
            
            else {
                if resetPassword.textFields?[0].text != alert.textFields?[0].text {
                    repeatEnterPassword()
                } else {
                    keychain["applicationPassword"] = alert.textFields?[0].text
                    let alert = UIAlertController(title: "Success", message: "Password is set", preferredStyle: .alert)
                    present(alert, animated: true) {
                        sleep(2)
                        dismiss(animated: true) {
                            
                        }
                    }
                }
            }
        }
        alert.addAction(secondCreatePassword)
        return alert
    }()
    
    lazy var resetPassword: UIAlertController = {
        let alert = UIAlertController(title: "Reset password", message: "Password should be no longer then 4 symbols", preferredStyle: .alert)
        alert.addTextField() { [self] login in
            login.textColor = .black
            login.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            login.autocapitalizationType = .none
            login.tintColor = UIColor.init(named: "accentColor")
            login.autocapitalizationType = .none
            login.placeholder = "Password"
            login.delegate = self
            login.textContentType = .password
            login.isSecureTextEntry = true
        }
        
        let cretePassword = UIAlertAction(title: "Создайте пароль", style: .default) { [self] _ in
            guard alert.textFields?[0].text != keychain["applicationPassword"] else { return }
            dismiss(animated: true) {
                secondloginAlert.textFields?[0].setValue(nil, forKey: "text")
                self.present(secondloginAlert, animated: true, completion: nil)
            }
        }
        alert.addAction(cretePassword)
        return alert
    }()
    
    
    lazy var loginAlert: UIAlertController = {
        let alert = UIAlertController(title: "Registration", message: "Password should be no longer then 4 symbols", preferredStyle: .alert)
        alert.addTextField() { [self] login in
            login.textColor = .black
            login.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            login.autocapitalizationType = .none
            login.tintColor = UIColor.init(named: "accentColor")
            login.autocapitalizationType = .none
            login.placeholder = "Password"
            login.delegate = self
            login.textContentType = .password
            login.isSecureTextEntry = true
        }
        
        let cretePassword = UIAlertAction(title: "Создайте пароль", style: .default) { [self] _ in
            guard alert.textFields?[0].text != keychain["applicationPassword"] else { return }
            dismiss(animated: true) {
                present(secondloginAlert, animated: true, completion: nil)
            }
        }
        
        let enterPassword = UIAlertAction(title: "Введите пароль", style: .default) { [self] _ in
            // смотрим совпадает ли пароль со значение в кей-чейне
            if alert.textFields?[0].text != self.keychain["applicationPassword"] {
                let alertFailure = UIAlertController(title: "Failure", message: "Password is wrong, try again", preferredStyle: .alert)
                present(alertFailure, animated: true) {
                    sleep(2)
                    dismiss(animated: true) {
                        alert.textFields?[0].setValue(nil, forKey: "text")
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
            // если сопадает, то юзер залогинен
            isLogged = true
        }
        
        // смотрим есть ли записи в кей-чейне
        if ((keychain["applicationPassword"]?.isEmpty) != nil) {
            alert.addAction(enterPassword)
        } else if isLogged {
            alert.addAction(cretePassword)
        } else {
            alert.addAction(cretePassword)
        }
        
        return alert
    }()
    
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
    
    //MARK: Functions
    
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
    
    func repeatEnterPassword() {
        let alert = UIAlertController(title: "Passwords don't match", message: "Please try again", preferredStyle: .alert)
        present(alert, animated: true) { [self] in
            sleep(2)
            dismiss(animated: true) {
                loginAlert.textFields?[0].setValue(nil, forKey: "text")
                secondloginAlert.textFields?[0].setValue(nil, forKey: "text")
                resetPassword.textFields?[0].setValue(nil, forKey: "text")
                if isLogged {
                    present(resetPassword, animated: true, completion: nil)
                } else {
                    present(loginAlert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @objc func addPassword() {
        passWordText = loginAlert.textFields?[0].text
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
        let fullContent = try? FileManager.default.contentsOfDirectory(at: name, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        guard let _ = content else { return }
        fullUrlPath = fullContent
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
    
    //MARK: FileSize func
    func fileSize(forURL url: Any) -> Double {
        var fileURL: URL?
        var fileSize: Double = 0.0
        if (url is URL) || (url is String)
        {
            if (url is URL) {
                fileURL = url as? URL
            }
            else {
                fileURL = URL(fileURLWithPath: url as! String)
            }
            var fileSizeValue = 0.0
            try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double? ?? 0.0)
            if fileSizeValue > 0.0 {
                fileSize = (Double(fileSizeValue) / (1024 * 1024))
            }
        }
        return fileSize
    }
    
    func displayAlertLogin() {
        guard !isLogged else { return }
        present(loginAlert, animated: true, completion: nil)
    }
    
    //MARK: DidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(headerLabel)
        view.addSubview(backToRootButton)
        view.addSubview(table)
        NSLayoutConstraint.activate(constraints)
        view.backgroundColor = .white
        createNavBarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        displayAlertLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "sort") {
            contentOfDirectory?.sort(by: <)
            table.reloadData()
        } else {
            contentOfDirectory?.sort(by: >)
            table.reloadData()
        }
    }
    
    
}

//MARK: Extentions

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
        let text: UILabel = {
            let text = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 30)))
            text.text = ""
            text.font = UIFont.systemFont(ofSize: 10)
            text.numberOfLines = 0
            return text
        }()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryView = text
        guard let _ = contentOfDirectory?[indexPath.item] else { return UITableViewCell(style: .default, reuseIdentifier: "cell")}
        cell.textLabel?.text = contentOfDirectory![indexPath.item]
        
        if UserDefaults.standard.bool(forKey: "size") {
            text.text = "Size \(String(format:"%.1f", fileSize(forURL: fullUrlPath![indexPath.item]))) kb"
        } else {
            text.text = nil
        }
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
            let alertPicture = UIAlertController(title: "Try again", message: "picture is already exist", preferredStyle: .alert)
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
//ограничение на количество символов в пароле
extension FileManagerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 4
    }
}
