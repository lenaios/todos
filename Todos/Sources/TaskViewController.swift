//
//  TaskViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/19.
//

import UIKit

class TaskViewController: UIViewController {

    // MARK: Properties
    var model: Task?
    var completionHandler: (() -> Void)?
    
    // MARK: UI
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    
    // MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Helpers
extension TaskViewController {
    func setupUI() {
        let rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteTask)
        )
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        taskNameTextField.delegate = self
        
        guard let task = model else { return }
        taskNameTextField.text = task.name
        dueDate.date = task.dueDate ?? Date()
    }
    
    func configure(model: Task) {
        self.model = model
    }
}

// MARK: - Actions
extension TaskViewController {
    @objc func deleteTask() {
        guard let model = model else { return }
        CoreDataManager.shared.deleteTask(object: model, completion: completionHandler)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension TaskViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // update Task
        guard let text = taskNameTextField.text,
              let id = model?.name else {
            return false
        }
        CoreDataManager.shared.updatetask(id: id, taskName: text, dueDate: Date(), completion: completionHandler)
        navigationController?.popViewController(animated: true)
        return true
    }
}
