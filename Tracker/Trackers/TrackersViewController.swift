//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Chingiz on 28.11.2023.
//

import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
    func createdTracker(tracker: Tracker, categoryTitle: String)
}

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var visibleCategories: [TrackerCategory] = []
    var currentDate: Date = .init()
    
    // MARK: - Private Properties
    
    private let trackersLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.text = "Трекеры"
        trackerLabel.font = .boldSystemFont(ofSize: 34)
        trackerLabel.textColor = .trBlack
        return trackerLabel
    }()
    
    private let searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Поиск"
        searchField.font = UIFont.systemFont(ofSize: 17)
        searchField.addTarget(self, action: #selector(searchTrackers), for: .allEvents)
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
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "glowingStar")
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .trBlack
        return label
    }()
    
    private let noResultsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "faceWithMonocle")
        return imageView
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .trBlack
        return label
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        
        currentDate = Date()
        filterVisibleCategories(for: currentDate)
        emptyCollectionView()
        emptySearchCollectionView()
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .always
        searchTextField.addTarget(self, action: #selector(textFieldCleared), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func pushAddTrackerButton() {
        let creatingTrackerViewController = CreatingTrackerViewController()
        creatingTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: creatingTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func dateChanged(_ picker: UIDatePicker) {
        currentDate = datePicker.date
        filterVisibleCategories(for: currentDate)
        if let datePickerContainerView = view.subviews.first(where: { String(describing: type(of: $0)).contains("UIDatePicker") }) {
            datePickerContainerView.subviews.forEach { subview in
                if let button = subview as? UIButton {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }
    
    @objc private func searchTrackers() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            filterVisibleCategories(for: currentDate)
            return
        }
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.name.localizedCaseInsensitiveContains(searchText) &&
                tracker.schedule.contains(WeekDay(rawValue: Calendar.current.component(.weekday, from: currentDate)) ?? .monday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                categoryTitle: category.categoryTitle,
                trackers: filteredTrackers
            )
        }
        visibleCategories = filteredCategories.compactMap { $0 }
        if visibleCategories.isEmpty {
            showNoResultsImage()
            hideEmptyStateImage()
        } else {
            hideNoResultsImage()
            hideEmptyStateImage()
        }
        collectionView.reloadData()
    }
    
    @objc private func textFieldCleared() {
        if searchTextField.text?.isEmpty ?? true {
            filterVisibleCategories(for: currentDate)
            if visibleCategories.isEmpty {
                showEmptyStateImage()
            } else {
                hideEmptyStateImage()
            }
            hideNoResultsImage()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
         searchTextField,
         collectionView,
         emptyStateImageView,
         emptyStateLabel,
         noResultsImageView,
         noResultsLabel
        ].forEach { view.addSubview($0) }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            searchTextField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            noResultsImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            noResultsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsImageView.widthAnchor.constraint(equalToConstant: 80),
            noResultsImageView.heightAnchor.constraint(equalToConstant: 80),
            
            noResultsLabel.topAnchor.constraint(equalTo: noResultsImageView.bottomAnchor, constant: 8),
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func isMatchRecord(model: TrackerRecord, with trackerId: UUID) -> Bool {
        return model.trackerID == trackerId && Calendar.current.isDate(model.date, inSameDayAs: currentDate)
    }
    
    private func setEmptyStateVisibility(isHidden: Bool, for imageView: UIImageView, label: UILabel) {
        imageView.isHidden = isHidden
        label.isHidden = isHidden
    }
    
    private func emptyCollectionView() {
        if visibleCategories.isEmpty && searchTextField.text?.isEmpty ?? true {
            showEmptyStateImage()
            hideNoResultsImage()
        } else {
            hideEmptyStateImage()
        }
    }
    
    private func emptySearchCollectionView() {
        if visibleCategories.isEmpty && !(searchTextField.text?.isEmpty ?? true) {
            showNoResultsImage()
            hideEmptyStateImage()
        } else {
            hideNoResultsImage()
        }
    }
    
    private func showEmptyStateImage() {
        emptyStateImageView.isHidden = false
        emptyStateLabel.isHidden = false
    }
    
    private func hideEmptyStateImage() {
        emptyStateImageView.isHidden = true
        emptyStateLabel.isHidden = true
    }
    
    private func showNoResultsImage() {
        noResultsImageView.isHidden = false
        noResultsLabel.isHidden = false
    }
    
    private func hideNoResultsImage() {
        noResultsImageView.isHidden = true
        noResultsLabel.isHidden = true
    }
    
    private func filterVisibleCategories(for selectedDate: Date) {
        let selectedWeekday = Calendar.current.component(.weekday, from: selectedDate)
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(WeekDay(rawValue: selectedWeekday) ?? .monday)
            }
            return TrackerCategory(categoryTitle: category.categoryTitle, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
        
        emptyCollectionView()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories.isEmpty ? 0 : visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as! TrackerCollectionViewCell
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains {
            isMatchRecord(model: $0, with: tracker.id)
        }
        let completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        
        cell.delegate = self
        cell.setupUI(with: tracker, isCompletedToday: isCompleted, completedDays: completedDays, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier, for: indexPath) as! TrackerSupplementaryView
        view.setTrackerSupplementaryView(text: visibleCategories.isEmpty ? "" : visibleCategories[indexPath.section].categoryTitle)
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

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func competeTracker(id: UUID) {
        guard currentDate <= Date() else {
            return
        }
        completedTrackers.append(TrackerRecord(trackerID: id, date: currentDate))
        collectionView.reloadData()
    }
    
    func uncompleteTracker(id: UUID) {
        completedTrackers.removeAll { element in
            if (element.trackerID == id &&  Calendar.current.isDate(element.date, equalTo: currentDate, toGranularity: .day)) {
                return true
            } else {
                return false
            }
        }
        collectionView.reloadData()
    }
}

// MARK: - TrackersViewControllerDelegate

extension TrackersViewController: TrackersViewControllerDelegate {
    func createdTracker(tracker: Tracker, categoryTitle: String) {
        categories.append(TrackerCategory(categoryTitle: categoryTitle, trackers: [tracker]))
        filterVisibleCategories(for: currentDate)
        collectionView.reloadData()
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UISearchTextFieldDelegate {
    private func textFieldShouldReturn(_ textField: UISearchTextField) -> Bool {
        textField.resignFirstResponder()
        hideNoResultsImage()
        return true
    }
}
