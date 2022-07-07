//
//  ViewController.swift
//  TaskList
//
//  Created by Julia Romanenko on 06.07.2022.
//

import UIKit

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListTableViewController: UITableViewController {
    
    private let context = StorageManager.shared.context
    private var taskList: [Task] = []
    private let cellID = "taslCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        view.backgroundColor = UIColor(
            red: 243/255,
            green: 241/255,
            blue: 255/255,
            alpha: 1
        )
        fetchListTask()
        setupNavigationBar()
    }
    
}

// MARK: - Private methods
extension TaskListTableViewController {
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true

        
        let navBarAppearance = UINavigationBarAppearance()
                
        navBarAppearance.backgroundColor = UIColor(
            red: 189/255,
            green: 169/255,
            blue: 254/255,
            alpha: 1
        )
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    private func fetchListTask() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let tasks):
                taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func showAlertController(title: String, message: String, textField: String, actionFunc: @escaping (String) -> ()) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            actionFunc(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { texFieldAlert in
            texFieldAlert.placeholder = "New Task"
            texFieldAlert.text = textField
        }
        
        present(alert, animated: true)
    }
    
    @objc private func addNewTask() {
        showAlertController(title: "New Task",
                            message: "What do you want to do?",
                            textField: "", actionFunc: saveTask)
    }
    
    private func saveTask(_ taskName: String) {
        let task = Task(context: context)
        
        task.title = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        StorageManager.shared.saveContext()
    }
    
    private func editTask(_ taskName: String) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        taskList[indexPath.row].title = taskName
        tableView.reloadRows(at: [indexPath], with: .none)
        
        StorageManager.shared.saveContext()
    }
}

// MARK: - TableView DataSource
extension TaskListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        
        cell.contentConfiguration = content
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        
        showAlertController(title: "Edit the Task", message: "Change your task", textField: task.title ?? "", actionFunc: editTask)
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let task = taskList[indexPath.row]
        
        if editingStyle == .delete {
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            context.delete(task)
            
            StorageManager.shared.saveContext()
        }
    }
}

extension TaskListTableViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchListTask()
        tableView.reloadData()
    }
}

