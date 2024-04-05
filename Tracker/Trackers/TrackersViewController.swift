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
    
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    private let trackersLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.font = .boldSystemFont(ofSize: 34)
        trackerLabel.textColor = .trBlack
        return trackerLabel
    }()
    
    private let searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
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
        datePicker.locale = .current
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
        
        trackerStore.setDelegate(self)
        reloadData()
        
        visibleCategories = filterTrackersBySelectedDate()
        collectionView.reloadData()
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
        visibleCategories = filterTrackersBySelectedDate()
        collectionView.reloadData()
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
    
    private func reloadData() {
        trackerCategoryStore.getCategories { [weak self] categories in
            self?.categories = categories
            self?.filterVisibleCategories(for: self?.currentDate ?? Date())
        }
    }
    
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
        
        let trackersLabelText = NSLocalizedString("trackersLabel.text", comment: "")
        trackersLabel.text = trackersLabelText
        let searchTextFieldText = NSLocalizedString("searchTextField.placeholder", comment: "")
        searchTextField.placeholder = searchTextFieldText
        let emptyStateText = NSLocalizedString("emptyState.text", comment: "")
        emptyStateLabel.text = emptyStateText
        let noResultsText = NSLocalizedString("noResults.text", comment: "")
        noResultsLabel.text = noResultsText
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
    
    private func getRecords(for tracker: Tracker) -> [TrackerRecord] {
        do {
            return try trackerRecordStore.recordsFetch(for: tracker)
        } catch {
            assertionFailure("Failed to get records for tracker")
            return []
        }
    }
    
    private func filterTrackersBySelectedDate() -> [TrackerCategory] {
        var categoriesFromCoreData: [TrackerCategory] = []
        trackerCategoryStore.getCategories { categories in
            categoriesFromCoreData = categories
        }
        let selectedWeekday = Calendar.current.component(.weekday, from: currentDate)
        var filteredCategories: [TrackerCategory] = []
        var pinnedTrackers: [Tracker] = []
        
        for category in categoriesFromCoreData {
            
            let filteredTrackersForDate = category.trackers.filter { tracker in
                return tracker.schedule.contains(WeekDay(rawValue: selectedWeekday) ?? .monday)
            }
            let nonPinnedTrackersForDate = filteredTrackersForDate.filter { !$0.isPinned }
            if !nonPinnedTrackersForDate.isEmpty {
                filteredCategories.append(TrackerCategory(categoryTitle: category.categoryTitle, trackers: nonPinnedTrackersForDate))
            }
            let pinnedTrackersForDate = filteredTrackersForDate.filter { $0.isPinned }
            pinnedTrackers.append(contentsOf: pinnedTrackersForDate)
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(categoryTitle: NSLocalizedString("pinnedCategoryTitle", comment: ""), trackers: pinnedTrackers)
            filteredCategories.insert(pinnedCategory, at: 0)
        }
        
        return filteredCategories
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
        let isCompleted = isTrackerCompletedToday(id: tracker.idTracker, tracker: tracker)
        
        let completedDays = getRecords(for: tracker).filter({
            $0.trackerID == tracker.idTracker
        }).count
        
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
    func getSelectedDate() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
        guard let selectedDate = calendar.date(from: dateComponents) else { return Date() }
        return selectedDate
    }
    
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerID: id, date: getSelectedDate())
        try? trackerRecordStore.addRecord(with: trackerRecord.trackerID, by: trackerRecord.date)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerID: id, date: getSelectedDate())
        try? trackerRecordStore.deleteRecord(with: trackerRecord.trackerID, by: trackerRecord.date)
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        currentDate = datePicker.date
        
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
        return trackerRecord.trackerID == id && isSameDay
    }
    
    func isTrackerCompletedToday(id: UUID, tracker: Tracker) -> Bool {
        do {
            return try trackerRecordStore.recordsFetch(for: tracker).contains { trackerRecord in
                isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
            }
        } catch {
            assertionFailure("Failed to get records for tracker")
            return false
        }
    }
    
    func deleteTracker(tracker: Tracker) {
        let actionSheet: UIAlertController = {
            let alert = UIAlertController()
            alert.title = NSLocalizedString("deleteTrackerAlert.title", comment: "")
            return alert
        }()
        
        let action1 = UIAlertAction(title: NSLocalizedString("deleteTrackerAlertAction1.title", comment: ""), style: .destructive) { [weak self] _ in
            do {
                try self?.trackerStore.deleteTracker(tracker)
                self?.reloadData()
                self?.collectionView.reloadData()
            } catch {
                print("Failed to delete tracker: \(error)")
            }
        }
        let action2 = UIAlertAction(title: NSLocalizedString("deleteTrackerAlertAction2.title", comment: ""), style: .cancel)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        
        present(actionSheet, animated: true)
    }
    
    func pinTracker(tracker: Tracker) {
        do {
            try trackerStore.pinTracker(tracker)
            reloadData()
            collectionView.reloadData()
            visibleCategories = filterTrackersBySelectedDate()
            collectionView.reloadData()
        } catch {
            print("Failed to pin tracker: \(error)")
        }
    }
}

// MARK: - TrackersViewControllerDelegate

extension TrackersViewController: TrackersViewControllerDelegate {
    func createdTracker(tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, toCategory: TrackerCategory(categoryTitle: categoryTitle, trackers: []))
            categories.append(TrackerCategory(categoryTitle: categoryTitle, trackers: [tracker]))
            filterVisibleCategories(for: currentDate)
            collectionView.reloadData()
            reloadData()
        } catch {
            print("Failed to add tracker to Core Data: \(error)")
        }
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

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.insertedSections)
            collectionView.insertItems(at: update.insertedIndexPaths)
        }
    }
}
