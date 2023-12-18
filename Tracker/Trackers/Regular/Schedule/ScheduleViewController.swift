//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Chingiz on 16.12.2023.
//

import UIKit

// MARK: - ScheduleViewControllerDelegate

protocol ScheduleViewControllerDelegate: AnyObject {
    func updateScheduleInfo(_ selectedDays: [WeekDay])
}

// MARK: - ScheduleViewController

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var selectedSchedule: [WeekDay] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushDoneButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        setupNavBar()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func pushDoneButton() {
        switchStatus()
        delegate?.updateScheduleInfo(selectedSchedule)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar(){
        navigationItem.title = "Расписание"
    }
    
    private func setupView() {
        [tableView,
         doneButton
        ].forEach { view.addSubview($0) }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        let minimumDistanceFromTableViewToDoneButton: CGFloat = 24
        let maximumDistanceFromTableViewToDoneButton: CGFloat = 47
        let minimumDistanceFromBottomSafeAreaToDoneButton: CGFloat = 16
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 525),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -minimumDistanceFromBottomSafeAreaToDoneButton),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: minimumDistanceFromTableViewToDoneButton),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: maximumDistanceFromTableViewToDoneButton)
        ])
    }
    
    private func switchStatus() {
        for (index, weekDay) in WeekDay.allCases.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            guard let switchView = cell?.accessoryView as? UISwitch else {return}
            
            if switchView.isOn {
                selectedSchedule.append(weekDay)
            } else {
                selectedSchedule.removeAll { $0 == weekDay }
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as? CustomTableViewCell else { return UITableViewCell()}
        cell.backgroundColor = .trBackgroundDay
        cell.textLabel?.text = WeekDay.allCases[indexPath.row].value
        let switchButton = UISwitch(frame: .zero)
        switchButton.setOn(false, animated: true)
        switchButton.onTintColor = .trBlue
        switchButton.tag = indexPath.row
        cell.accessoryView = switchButton
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
