//
//  EntryViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/17.
//

import UIKit
import CoreData

class EntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    
    var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        
        taskTextField.delegate = self
        taskTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskTextField.resignFirstResponder()
        return true
    }
    
    @objc func didTapSaveButton() {
        guard let taskName = taskTextField.text else {
            return
        }
        if !taskName.isEmpty {
            print(taskName)
        }
        
        CoreDataManager.shared.insertTask(taskName: taskName, dueDate: dueDate.date, completion: completionHandler)

        navigationController?.popViewController(animated: true)
    }
}
