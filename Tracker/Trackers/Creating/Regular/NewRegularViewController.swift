//
//  NewRegularViewController.swift
//  Tracker
//
//  Created by Chingiz on 16.12.2023.
//

import UIKit

// MARK: - UIViewController

final class NewRegularViewController: BaseTrackerViewController {
    
    private var selectedWeekdays: [Int: Bool] = [:]
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        setupNavBar(title: NSLocalizedString("setupNavBarNewRegular.title", comment: ""))
        configureUIElements()
        tableView.delegate = self
        tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        createButton.isEnabled = false
        createButton.backgroundColor = .trGray
    }
    
    // MARK: - Actions
    
    @objc override func pushCancelButton() {
        super.pushCancelButton()
    }
    
    @objc override func pushCreateButton() {
        guard let trackerName = textField.text else { return }
        let newTracker = Tracker(
            idTracker: UUID(),
            name: trackerName,
            color: selectedColor ?? .trBlack,
            emoji: selectedEmoji ?? "❓",
            schedule: selectedSchedule, 
            isPinned: false
        )
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func createSchedule(schedule: [WeekDay]) {
        self.selectedSchedule = schedule
        let subText = selectedSchedule.map { $0.shortValue }.joined(separator: ", ")
        setSubTitle(subText, forCellAt: IndexPath(row: 1, section: 0))
        tableView.reloadData()
        checkButtonActivation()
    }
    
    private func didSelectDays(_ days: [WeekDay]) {
        let abbreviatedDays = days.map { $0.shortValue }.joined(separator: ", ")
        if let scheduleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EventButtonCell {
            scheduleCell.set(subText: abbreviatedDays)
        }
    }
    
    override func checkButtonActivation() {
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategoryTextEmpty = textField.text?.isEmpty ?? true
        
        if isCategorySelected && isScheduleSelected  && !isCategoryTextEmpty && isEmojiSelected && isColorSelected {
            createButton.isEnabled = true
            createButton.backgroundColor = .trBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .trGray
        }
    }
}

// MARK: - UITableViewDelegate

extension NewRegularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            navigationController?.pushViewController(categoryViewController, animated: true)
        } else if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.switchStates = selectedWeekdays
            navigationController?.pushViewController(scheduleViewController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension NewRegularViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventButtonCell.reuseIdentifier, for: indexPath) as! EventButtonCell
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .trBackground
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            cell.titleLabel.text = dataForTableView[indexPath.row]
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.titleLabel.text = dataForTableView[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewRegularViewController: ScheduleViewControllerDelegate {
    func updateScheduleInfo(_ selectedDays: [WeekDay], _ switchStates: [Int: Bool]) {
        self.selectedSchedule = selectedDays
        let subText: String
        if selectedDays.count == WeekDay.allCases.count {
            subText = NSLocalizedString("selectedAllDay.subText", comment: "")
        } else {
            subText = selectedDays.map { $0.shortValue }.joined(separator: ", ")
        }
        setSubTitle(subText, forCellAt: IndexPath(row: 1, section: 0))
        isScheduleSelected = true
        checkButtonActivation()
        selectedWeekdays = switchStates
        tableView.reloadData()
    }
}
