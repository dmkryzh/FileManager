//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Dmitrii KRY on 21.05.2021.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    weak var delegate: FileManagerViewController?
    
    let userDefaults = UserDefaults.standard
    
    var settings: UserDefaults?
    
    let sortLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sorting by <"
        return label
    }()
    
    let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Show size of content"
        return label
    }()
    
    let resetPassword: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset password", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightText
        button.addTarget(self, action: #selector(resetPasswordLogic), for: .touchUpInside)
        return button
    }()
    
    @objc func resetPasswordLogic() {
        delegate?.resetPassword.textFields?[0].setValue(nil, forKey: "text")
        present(delegate!.resetPassword, animated: true, completion: nil)
    }
    
    
    lazy var switchSorting: UISwitch = {
        let switcher = UISwitch()
        if userDefaults.bool(forKey: "sort") {
        switcher.setOn(true, animated: false)
        } else {
            switcher.setOn(false, animated: false)
        }
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switchSortDidChange(_:)), for: .valueChanged)
        return switcher
    }()
    
    lazy var switchSize: UISwitch = {
        let switcher = UISwitch()
        if userDefaults.bool(forKey: "size") {
            switcher.setOn(true, animated: false)
        } else {
            switcher.setOn(false, animated: false)
        }
        
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switchSizeDidChange(_:)), for: .valueChanged)
        return switcher
    }()
    
    @objc func switchSortDidChange(_ sender: UISwitch){
        if (sender.isOn == true){
            userDefaults.setValue(true, forKey: "sort")
        }
        else{
            userDefaults.setValue(false, forKey: "sort")
        }
    }

    @objc func switchSizeDidChange(_ sender: UISwitch){
        if (sender.isOn == true){
            userDefaults.setValue(true, forKey: "size")
            delegate?.table.reloadData()
        }
        else{
            userDefaults.setValue(false, forKey: "size")
            delegate?.table.reloadData()
        }
    }
    
    lazy var constraints = [
        
        sortLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        sortLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        switchSorting.topAnchor.constraint(equalTo: sortLabel.bottomAnchor, constant: 16),
        switchSorting.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        sizeLabel.topAnchor.constraint(equalTo: switchSorting.bottomAnchor, constant: 16),
        sizeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        switchSize.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 16),
        switchSize.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        resetPassword.heightAnchor.constraint(equalToConstant: 50),
        resetPassword.widthAnchor.constraint(equalToConstant: 150),
        resetPassword.topAnchor.constraint(equalTo: switchSize.bottomAnchor, constant: 16),
        resetPassword.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sortLabel)
        view.addSubview(switchSorting)
        view.addSubview(sizeLabel)
        view.addSubview(switchSize)
        view.addSubview(resetPassword)
        NSLayoutConstraint.activate(constraints)
        view.backgroundColor = .white
        
    }
}
