//
//  EditingHabitsViewController.swift
//  Tracker
//
//  Created by Chingiz on 06.04.2024.
//

import UIKit

final class EditingHabitsViewController: BaseTrackerViewController {
    
    var tracker: Tracker?
    
    private var selectedWeekdays: [Int: Bool] = [:]
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .trBlack
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        setupNavBar(title: NSLocalizedString("setupNavBarEditingHabits.title", comment: ""))
        configureUIElements()
        tableView.delegate = self
        tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        createButton.isEnabled = false
        createButton.backgroundColor = .trGray
        counterLabel.text = "5 дней"
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
    
    override func configureUIElements() {
        
        contentView.addSubview(counterLabel)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [counterLabel,
         textField,
         tableView,
         emojisAndColorsCollectionView,
         stackView].forEach { scrollView.addSubview($0) }
        
        textField.delegate = self
        tableView.dataSource = self
        emojisAndColorsCollectionView.dataSource = self
        emojisAndColorsCollectionView.delegate = self
        
        [cancelButton, createButton].forEach { stackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            counterLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            counterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            counterLabel.heightAnchor.constraint(equalToConstant: 40),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 50),
            
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            
            emojisAndColorsCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojisAndColorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojisAndColorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojisAndColorsCollectionView.heightAnchor.constraint(equalToConstant: 460),
            
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.topAnchor.constraint(equalTo: emojisAndColorsCollectionView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
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

extension EditingHabitsViewController: UITableViewDelegate {
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

extension EditingHabitsViewController {
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

extension EditingHabitsViewController: ScheduleViewControllerDelegate {
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
