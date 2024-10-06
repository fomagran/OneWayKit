//
//  ViewController.swift
//  OneWayKit
//
//  Created by 47676921 on 10/06/2024.
//  Copyright (c) 2024 47676921. All rights reserved.
//

import UIKit
import OneWayKit
import Combine

final class ToDoViewController: UIViewController {
    
    private let oneway = OneWay<ToDoFeature>(initialState: .init(todos: []))
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOneWay()
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupOneWay() {
        // Binding State
        oneway.state
            .sink { [weak self] state in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // Async Actions Example
        oneway.send(.reserveToDo(5))
        oneway.send(.addToDoPerSecond(2))
        
        // Cancel Example
        oneway.state
            .map { $0.todos }
            .sink { [weak self] in
                if $0.count > 10 {
                    self?.oneway.cancel(ToDoFeature.Action.addToDoPerSecond(2))
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    @objc private func addButtonTapped() {
        let addToDoOneWay = OneWay<AddToDoFeature>(initialState: .init())
        
        // Transform Child Action Example
        oneway.transform(id: "AddToDoOneWay", action: addToDoOneWay.action) { [weak self] in
            self?.oneway.send(.addToDo($0))
        }
        let addToDoVC = AddToDoViewController(oneway: addToDoOneWay)
        present(addToDoVC, animated: true, completion: nil)
    }
}


// MARK: - UITableViewDataSource

extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = oneway.state.value.todos[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        oneway.state.value.todos.count
    }
}


// MARK: - UITableViewDelegate

extension ToDoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        oneway.send(.delete(indexPath.row))
    }
}
