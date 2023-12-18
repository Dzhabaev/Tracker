//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Chingiz on 28.11.2023.
//

import UIKit

// MARK: - TrackersViewController
final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    var categories: [TrackerCategory] = [] // Список категорий и их трекеров
    var completedTrackers: [TrackerRecord] = [] // Список выполненных трекеров
    var visibleCategories: [TrackerCategory] = []
    
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
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        return collectionView
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "errorImage")
        return imageView
    }()
    
    private let errorTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .trBlack
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupConstraints()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func didTapAddTrackerButton() {
        let creatingTrackerViewController = UINavigationController(rootViewController: CreatingTrackerViewController())
        present(creatingTrackerViewController, animated: true)
    }
    
    private func setupNavigationBar() {
        let addTrackerButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddTrackerButton))
        addTrackerButton.tintColor = .trBlack
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupConstraints() {
        [trackersLabel,
         searchField,
         collectionView,
         errorImageView,
         errorTextLabel
        ].forEach
        {view.addSubview($0)}
        
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            errorImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            errorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80),
            
            errorTextLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
            errorTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell
        cell?.trackerView.backgroundColor = .red
        return cell!
    }
}



