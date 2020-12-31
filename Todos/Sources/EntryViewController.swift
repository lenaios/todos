//
//  EntryViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/17.
//

import UIKit
import CoreData
import UserNotifications

/*
 
 1. 메서드 관심사 분리 - extention 추가
 2. syntax 개선 - 줄바꿈, 트레일링클로져
 
 */

class EntryViewController: UIViewController {
    
    // MARK: Properties
    var status: String?
    var model: Task?
    var completionHandler: (() -> Void)?
    
    // MARK: UI
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    
    // MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Helpers
extension EntryViewController {
    func setupUI() {
        if status == "entry" {
            let rightBarButtonItem = UIBarButtonItem(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(didTapSaveButton)
            )
            
            navigationItem.rightBarButtonItem = rightBarButtonItem
            
            
            taskTextField.becomeFirstResponder()
            
        } else if status == "edit" {
            let rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(deleteTask)
            )
            navigationItem.rightBarButtonItem = rightBarButtonItem
            
            guard let task = model else { return }
            taskTextField.text = task.name
            dueDate.date = task.dueDate ?? Date()
        }
        taskTextField.delegate = self
    }
    
    func configure(model: Task) {
        self.model = model
    }
    
    func schedulePush(taskName: String, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = taskName
        content.sound = .default
        //content.badge = 1
        content.body = "It's almost close to deadline!"
        
        let targetDate = Date().addingTimeInterval(10)
        
        let matchingDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: targetDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: matchingDate,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "some_long_id",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("something went wrong")
            }
        }
    }
}

// MARK: - Actions
extension EntryViewController {
    
    @objc func didTapSaveButton() {
        guard let taskName = taskTextField.text, !taskName.isEmpty else {
            return
        }
        
        let result = CoreDataManager.shared.insertTask(taskName: taskName, dueDate: dueDate.date)
        if result {
            completionHandler?()
        }
        
        // UserNotification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (success, error) in
            guard let strongSelf = self else {
                return
            }
            if success {
                print("auth success!")
                DispatchQueue.main.async {
                    // setting, triger, request user notification
                    strongSelf.schedulePush(taskName: taskName, dueDate: strongSelf.dueDate.date)
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteTask() {
        guard let model = model else { return }
        let result = CoreDataManager.shared.deleteTask(object: model)
        if result {
            completionHandler?()
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TextFieldDelegate
extension EntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if status == "edit" {
            guard let text = textField.text,
                  let id = model?.name else {
                return false
            }
            
            let result = CoreDataManager.shared.updatetask(id: id, taskName: text, dueDate: dueDate.date)
            if result {
                completionHandler?()
            }
            navigationController?.popViewController(animated: true)
        }
        return true
    }
}
