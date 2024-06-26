//
//  NewIrregularViewController.swift
//  Tracker
//
//  Created by Chingiz on 24.12.2023.
//

import UIKit

final class NewIrregularViewController: BaseTrackerViewController {
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        setupNavBar(title: NSLocalizedString("setupNavBarNewIrregular.title", comment: ""))
        configureUIElements()
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        createButton.isEnabled = false
        createButton.backgroundColor = .trGray
    }
    
    // MARK: - Actions
    
    @objc override func pushCancelButton() {
        super.pushCancelButton()
    }
    
    @objc override func pushCreateButton() {
        guard let trackerName = textField.text else { return }
        let currentDate = Date()
        let currentWeekday = Calendar.current.component(.weekday, from: currentDate)
        let newSchedule = Schedule(value: WeekDay(rawValue: currentWeekday) ?? .sunday, isOn: true)
        let scheduleArray = [newSchedule]
        let weekdayArray = scheduleArray.map { $0.value }
        
        let newTracker = Tracker(
            idTracker: UUID(),
            name: trackerName,
            color: selectedColor ?? .trBlack,
            emoji: selectedEmoji ?? "❓",
            schedule: weekdayArray,
            isPinned: false
        )
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
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

extension NewIrregularViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventButtonCell.reuseIdentifier, for: indexPath) as! EventButtonCell
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .trBackground
        if indexPath.row == 0 {
            cell.titleLabel.text = dataForTableView[0]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
