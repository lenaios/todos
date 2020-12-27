//
//  EntryViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/17.
//

import UIKit
import CoreData
import UserNotifications

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
        guard let taskName = taskTextField.text, !taskName.isEmpty else {
            return
        }
        
        CoreDataManager.shared.insertTask(taskName: taskName, dueDate: dueDate.date, completion: completionHandler)
        
        // UserNotification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (success, error) in
            guard let strongSelf = self else {
                return
            }
            if success {
                print("auth success!")
                DispatchQueue.main.async {
                    // setting, triger, request user notification
                    strongSelf.scheduleTest(taskName: taskName, dueDate: strongSelf.dueDate.date)
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func scheduleTest(taskName: String, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = taskName
        content.sound = .default
        //content.badge = 1
        content.body = "It's almost close to deadline!"
        
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                  from: targetDate),
                                                    repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("something went wrong")
            }
        })
    }
}
