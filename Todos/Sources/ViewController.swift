//
//  ViewController.swift
//  Todos
//
//  Created by Ador on 2020/12/16.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
    var taskData = [Task]()
    
    // date dateFormatter
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        fetchTasks()

    }
    
    func fetchTasks() {
        let data = CoreDataManager.shared.fetch(request: Task.fetchRequest())
        taskData = data
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func didTapAddButton() {
        guard let entryVC = storyboard?.instantiateViewController(identifier: "entry") as? EntryViewController else { return }
        navigationController?.pushViewController(entryVC, animated: true)
        entryVC.completionHandler = { [weak self] in self?.fetchTasks() }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = taskData[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = Self.dateFormatter.string(from: task.dueDate!)
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
    
    // MARK: - Table View Header
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}
