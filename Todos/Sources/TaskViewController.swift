//
//  TaskViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/19.
//

import UIKit

class TaskViewController: UIViewController {

    var model: Task?
    var completionHandler: (() -> Void)?
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    
    func configure(model: Task) {
        self.model = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let task = model else {
            return
        }
        taskNameTextField.text = task.name
        dueDate.date = task.dueDate ?? Date()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTask))
    }
    
    @objc func deleteTask() {
        guard let model = model else {
            return
        }
        
        CoreDataManager.shared.deleteTask(object: model, completion: completionHandler)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapUpdateButton() {
        // update Task
        guard let text = taskNameTextField.text, let id = model?.name else {
            return
        }
        CoreDataManager.shared.updatetask(id: id, taskName: text, dueDate: Date(), completion: completionHandler)
        navigationController?.popViewController(animated: true)
    }
}
