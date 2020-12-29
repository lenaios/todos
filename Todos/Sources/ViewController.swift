//
//  ViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/16.
//

import UIKit
import CoreData

/*
 
 1. tasknameTextField view hierachy
    #issue   테이블뷰 스크롤했을 때 네비게이션바가 TextField를 덮고 내려옴
    #resolve - view 서브 뷰에서 테이블뷰 헤더로 지정합니다.
             - 텍스트필드에 오토레이아웃을 지정하기 위해서 헤더에 빈 뷰를 하나 둔 뒤 해당 뷰의 서브 뷰로 추가하여 제약조건 추가
 
 2. dateFormatter 타입프로퍼티 -> 저장프로퍼티
    #issue   dateFormatter를 타입프로퍼티로 지정할 이유가 없음
    #resolve - 저장프로퍼티로 변경
 
 3. entry,task viewController 중복
    #issue   동일한 UI를 가진 UIViewController를 두번 정의함
    #resolve - edit / add 상태를 지정하여 상태에 따라 다른 동작을 하도록 정의하여 재사용 하세요.
 
 4. numberOfSections 제거
    #issue   section이 1개 일때는 해당 메서드 필요x
 
 5. 메서드 관심사 분리 - extention 추가
 
 */

class ViewController: UIViewController {
    
    // MARK: Properties
    var taskData = [Task]()
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Helpers
extension ViewController {
    func setupUI() {
        let backBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: nil,
            action: nil
        )
        
        navigationItem.backBarButtonItem = backBarButtonItem
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

        fetchTasks()
    }
    
    func fetchTasks() {
        let data = CoreDataManager.shared.fetch(request: Task.fetchRequest())
        taskData = data
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func showEntryVC() {
        guard let entryVC = storyboard?.instantiateViewController(identifier: "entry")
                as? EntryViewController else { return }
        navigationController?.pushViewController(entryVC, animated: true)
        entryVC.completionHandler = { [weak self] in self?.fetchTasks() }
    }
}

// MARK: - Actions
extension ViewController {
    @IBAction func didTapAddButton() {
        showEntryVC()
    }
    
    @IBAction func didTapTextField() {
        showEntryVC()
    }
}

// MARK: - TableView Delegate&DataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = taskData[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = dateFormatter.string(from: task.dueDate!)
        cell.selectionStyle = .none
        
        //cell.textLabel?.text = taskDataSortedByDate?[indexPath.section][indexPath.row].name // task section 나누기
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let taskVC = storyboard?.instantiateViewController(identifier: "task") as? TaskViewController else { return }
        taskVC.configure(model: taskData[indexPath.row])
        taskVC.completionHandler = { [weak self] in self?.fetchTasks() }
        navigationController?.pushViewController(taskVC, animated: true)
    }
    
    // tableView editingStyle
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete cell
            tableView.beginUpdates()
            
            // delete data
            CoreDataManager.shared.deleteTask(object: taskData[indexPath.row], completion: nil)
            
            taskData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    // MARK: - Table View Header
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return ""
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 62.0
//    }
}
