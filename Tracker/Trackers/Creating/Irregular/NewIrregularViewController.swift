//
//  NewIrregularViewController.swift
//  Tracker
//
//  Created by Chingiz on 24.12.2023.
//

import UIKit

final class NewIrregularViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: CreatingTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let dataForTableView = "Категория"
    private var selectedSchedule: [WeekDay] = []
    private var selectedCategory = String()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .trBackgroundDay
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.addLeftPadding(16)
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.smartInsertDeleteType = .no
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .trBackgroundDay
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.register(EventButtonCell.self, forCellReuseIdentifier: EventButtonCell.reuseIdentifier)
        return tableView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trWhite
        button.setTitleColor(.trRed, for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.trRed.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(pushCancelButton), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushCreateButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        setupNavBar()
        setupView()
        setupConstraints()
        
        createButton.isEnabled = false
        createButton.backgroundColor = .trGray
    }
    
    // MARK: - Actions
    
    @objc private func pushCancelButton() {
        dismiss(animated: true)
        delegate?.cancelCreateTracker()
    }
    
    @objc private func pushCreateButton() {
        guard let trackerName = textField.text else { return }
        let currentDate = Date()
        let currentWeekday = Calendar.current.component(.weekday, from: currentDate)
        let newSchedule = Schedule(value: WeekDay(rawValue: currentWeekday) ?? .sunday, isOn: true)
        let scheduleArray = [newSchedule]
        let weekdayArray = scheduleArray.map { $0.value }
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .colorSelection12,
            emoji: "🏓",
            schedule: weekdayArray
        )
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar(){
        navigationItem.title = "Новое нерегулярное событие"
    }
    
    private func setupView() {
        [textField,
         tableView,
         stackView
        ].forEach { view.addSubview($0) }
        
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        [cancelButton,
         createButton
        ].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            tableView.heightAnchor.constraint(equalToConstant: 75),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setSubTitle(_ subTitle: String?, forCellAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventButtonCell else {
            return
        }
        cell.set(subText: subTitle)
    }
    
    private func updateCategory(_ category: String) {
        selectedCategory = category
        setCategoryTitle(selectedCategory)
    }
    
    private func setCategoryTitle(_ category: String) {
        setSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }
}

// MARK: - UITableViewDelegate

extension NewIrregularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 else { return }
        let categoryViewController = CategoryViewController()
        categoryViewController.delegate = self
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NewIrregularViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventButtonCell.reuseIdentifier, for: indexPath) as! EventButtonCell
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .trBackgroundDay
        cell.titleLabel.text = dataForTableView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - CategoryViewControllerDelegate

extension NewIrregularViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        updateCategory(category)
    }
}

// MARK: - UITextFieldDelegate

extension NewIrregularViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .trBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .trGray
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
