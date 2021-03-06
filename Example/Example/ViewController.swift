//
//  ViewController.swift
//  Example
//
//  Created by Jacob Sikorski on 2017-05-22.
//  Copyright © 2017 Jacob Sikorski. All rights reserved.
//

import UIKit
import NetworkKit

class ViewController: UIViewController {
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(tappedSendButton), for: .touchUpInside)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.tintColor = UIColor.black
        return button
    }()
    
    lazy var textView: UITextView = {
        return UITextView()
    }()
    
    lazy var baseUrlTextField: UITextField = {
        let textField = UITextField()
        textField.text = "https://jsonplaceholder.typicode.com"
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var pathTextField: UITextField = {
        let textField = UITextField()
        textField.text = "/posts/1"
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    fileprivate var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.groupTableViewBackground
        title = "Example "
        setupLayout()
        
        // Configure the Text Fields
        baseUrlTextField.delegate = self
        pathTextField.delegate = self
    }
    
    @objc private func tappedSendButton() {
        currentTextField?.resignFirstResponder()
        
        let dispatcher = AlamofireDispatcher(serverProvider: self)
        
        dispatcher.future(from: {
            return BasicRequest(method: .get, path: self.pathTextField.text ?? "")
        }).response({ [weak self] response in
            #if DEBUG
            response.debug()
            #endif
            
            let jsonString = try response.decodeString(encoding: .utf8)
            self?.textView.text = jsonString
        }).error({ [weak self] error in
            self?.textView.text = error.localizedDescription
        }).send()
    }
    
    private func setupLayout() {
        view.addSubview(sendButton)
        view.addSubview(textView)
        view.addSubview(baseUrlTextField)
        view.addSubview(pathTextField)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        baseUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        pathTextField.translatesAutoresizingMaskIntoConstraints = false
        
        baseUrlTextField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        baseUrlTextField.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        baseUrlTextField.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        
        pathTextField.topAnchor.constraint(equalTo: baseUrlTextField.bottomAnchor, constant: 15).isActive = true
        pathTextField.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        pathTextField.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        
        sendButton.topAnchor.constraint(equalTo: pathTextField.bottomAnchor, constant: 15).isActive = true
        sendButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        
        textView.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 15).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.baseUrlTextField {
            pathTextField.becomeFirstResponder()
        } else if let urlString = baseUrlTextField.text, URL(string: urlString) != nil {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentTextField?.resignFirstResponder()
        return true
    }
}

extension ViewController: ServerProvider {
    var baseURL: URL {
        return URL(string: baseUrlTextField.text!)!
    }
}
