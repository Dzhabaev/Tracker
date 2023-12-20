//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Chingiz on 28.11.2023.
//

import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = [] // Список категорий и их трекеров
    var completedTrackers: [TrackerRecord] = [] // Список выполненных трекеров
    var visibleCategories: [TrackerCategory] = []
    var currentDate: Date = .init() // Хранение текущей даты, при выборе даты в UIDatePicker меняет значение этого свойства
    
    private let trackersLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.text = "Трекеры"
        trackerLabel.font = .boldSystemFont(ofSize: 34)
        trackerLabel.textColor = .trBlack
        return trackerLabel
    }()
    
    private let searchField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Поиск"
        searchField.font = UIFont.systemFont(ofSize: 17)
        return searchField
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .trWhite
        collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func pushAddTrackerButton() {
        let creatingTrackerViewController = UINavigationController(rootViewController: CreatingTrackerViewController())
        present(creatingTrackerViewController, animated: true)
    }
    
    @objc private func dateChanged(_ picker: UIDatePicker) {
        currentDate = datePicker.date
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        let addTrackerButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(pushAddTrackerButton))
        addTrackerButton.tintColor = .trBlack
        navigationItem.leftBarButtonItem = addTrackerButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupViews() {
        [trackersLabel,
         searchField,
         collectionView
        ].forEach { view.addSubview($0) }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            searchField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension TrackersViewController {
    // Метод для добавления нового трекера в соответствующую категорию
    func addNewTracker(_ tracker: Tracker, to categoryIndex: Int) {
        guard categoryIndex >= 0 && categoryIndex < categories.count else { return }
        categories[categoryIndex].trackers.append(tracker)
    }
    
    // Метод для добавления записи об выполненном трекере
    func addCompletedTrackerRecord(_ trackerRecord: TrackerRecord) {
        completedTrackers.append(trackerRecord)
    }
    
    // Метод для удаления выполненного трекера из массива completedTrackers
    func removeCompletedTrackerRecord(_ trackerRecord: TrackerRecord) {
        if let index = completedTrackers.firstIndex(where: { $0.trackerID == trackerRecord.trackerID && $0.date == trackerRecord.date }) {
            completedTrackers.remove(at: index)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as! TrackerCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier, for: indexPath) as! TrackerSupplementaryView
        view.setTrackerSupplementaryView(text: "Домашний уют") 
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, 
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 148
        let interItemSpacing: CGFloat = 10
        let width = (collectionView.bounds.width - interItemSpacing) / 2
        return CGSize(width: width, height: height)
    }
}
