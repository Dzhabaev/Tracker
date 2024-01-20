//
//  BaseTrackerViewController.swift
//  Tracker
//
//  Created by Chingiz on 27.12.2023.
//

import UIKit

class BaseTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: CreatingTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    
    let dataForTableView = ["Категория", "Расписание"]
    var selectedSchedule: [WeekDay] = []
    var selectedCategory = String()
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var selectedEmojiIndex: Int?
    var selectedColorIndex: Int?
    var isCategorySelected = false
    var isScheduleSelected = false
    var emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    var colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3,
        .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9,
        .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textField: UITextField = {
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
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .trBackgroundDay
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(
            EventButtonCell.self,
            forCellReuseIdentifier: EventButtonCell.reuseIdentifier
        )
        return tableView
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var cancelButton: UIButton = {
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
    
    lazy var createButton: UIButton = {
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
    
    lazy var emojisAndColorsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .trWhite
        collectionView.isScrollEnabled = false
        collectionView.register(
            EmojisAndColorsCell.self,
            forCellWithReuseIdentifier: EmojisAndColorsCell.reuseIdentifier
        )
        collectionView.register(
            EmojisAndColorsSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojisAndColorsSupplementaryView.reuseIdentifier
        )
        return collectionView
    }()
    
    // MARK: - Actions
    
    @objc func pushCancelButton() {
        dismiss(animated: true)
        delegate?.cancelCreateTracker()
    }
    
    @objc func pushCreateButton() {
        guard let trackerName = textField.text else { return }
        let newTracker = Tracker(
            idTracker: UUID(),
            name: trackerName,
            color: selectedColor ?? .trBlack,
            emoji: selectedEmoji ?? "❓",
            schedule: selectedSchedule)
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    func setupNavBar(title: String) {
        navigationItem.title = title
    }
    
    func configureUIElements() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [textField,
         tableView,
         emojisAndColorsCollectionView,
         stackView
        ].forEach { scrollView.addSubview($0) }
        
        contentView.addSubview(emojisAndColorsCollectionView)
        
        textField.delegate = self
        tableView.dataSource = self
        emojisAndColorsCollectionView.dataSource = self
        emojisAndColorsCollectionView.delegate = self
        
        [cancelButton,
         createButton
        ].forEach { stackView.addArrangedSubview($0) }
        
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
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            
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
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 105)
    }
    
    func setSubTitle(_ subTitle: String?, forCellAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventButtonCell else {
            return
        }
        cell.set(subText: subTitle)
    }
    
    func updateCategory(_ category: String) {
        selectedCategory = category
        setCategoryTitle(selectedCategory)
        checkButtonActivation()
    }
    
    func setCategoryTitle(_ category: String) {
        setSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }
    
    func checkButtonActivation() {
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategoryTextEmpty = textField.text?.isEmpty ?? true
        
        if isCategorySelected && !isCategoryTextEmpty && isEmojiSelected && isColorSelected {
            createButton.isEnabled = true
            createButton.backgroundColor = .trBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .trGray
        }
    }
}

// MARK: - UITableViewDataSource

extension BaseTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("This method must be overridden by the subclass")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("This method must be overridden by the subclass")
    }
}

// MARK: - CategoryViewControllerDelegate

extension BaseTrackerViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        updateCategory(category)
        isCategorySelected = true
        checkButtonActivation()
    }
}

// MARK: - UITextFieldDelegate

extension BaseTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .trBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .trGray
        }
        checkButtonActivation()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension BaseTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojis.count
        } else if section == 1 {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisAndColorsCell.reuseIdentifier, for: indexPath) as! EmojisAndColorsCell
        
        if indexPath.section == 0 {
            let emoji = emojis[indexPath.row]
            cell.titleLabel.text = emoji
        } else if indexPath.section == 1 {
            let color = colors[indexPath.row]
            cell.titleLabel.backgroundColor = color
        }
        
        cell.titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EmojisAndColorsSupplementaryView.reuseIdentifier,
            for: indexPath
        ) as! EmojisAndColorsSupplementaryView
        if indexPath.section == 0 {
            view.titleLabel.text = "Emoji"
        } else if indexPath.section == 1 {
            view.titleLabel.text = "Цвет"
        }
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BaseTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 40, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let selectedEmojiIndex = selectedEmojiIndex {
                let previousSelectedIndexPath = IndexPath(item: selectedEmojiIndex, section: 0)
                if let cell = collectionView.cellForItem(at: previousSelectedIndexPath) as? EmojisAndColorsCell {
                    cell.backgroundColor = .clear
                }
            }
            let cell = collectionView.cellForItem(at: indexPath) as! EmojisAndColorsCell
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.backgroundColor = .trLightGray
            selectedEmoji = emojis[indexPath.row]
            selectedEmojiIndex = indexPath.row
        } else if indexPath.section == 1 {
            if let selectedColorIndex = selectedColorIndex {
                let previousSelectedIndexPath = IndexPath(item: selectedColorIndex, section: 1)
                if let cell = collectionView.cellForItem(at: previousSelectedIndexPath) as? EmojisAndColorsCell {
                    cell.layer.borderColor = UIColor.clear.cgColor
                    cell.layer.borderWidth = 0
                }
            }
            let cell = collectionView.cellForItem(at: indexPath) as! EmojisAndColorsCell
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.layer.borderColor = colors[indexPath.row].cgColor.copy(alpha: 0.3)
            cell.layer.borderWidth = 3
            selectedColor = colors[indexPath.row]
            selectedColorIndex = indexPath.row
        }
        checkButtonActivation()
    }
}
