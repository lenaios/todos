//
//  TaskViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/19.
//

import UIKit

/*
 
 1. tasknameTextField view hierachy
    #issue   테이블뷰 스크롤했을 때 네비게이션바가 TextField를 덮고 내려옴
    #resolve - view 서브 뷰에서 테이블뷰 헤더로 지정합니다.
             - 텍스트필드에 오토레이아웃을 지정하기 위해서 헤더에 빈 뷰를 하나 둔 뒤 해당 뷰의 서브 뷰로 추가하여 제약조건 추가
 
 */

class TaskViewController: UIViewController, UITextFieldDelegate {

    var model: Task?
    var completionHandler: (() -> Void)?
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    
    func configure(model: Task) {
        self.model = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameTextField.delegate = self
        
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
    
    // MARK:  - UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // update Task
        guard let text = taskNameTextField.text, let id = model?.name else {
            return false
        }
        CoreDataManager.shared.updatetask(id: id, taskName: text, dueDate: Date(), completion: completionHandler)
        navigationController?.popViewController(animated: true)
        return true
    }
}
