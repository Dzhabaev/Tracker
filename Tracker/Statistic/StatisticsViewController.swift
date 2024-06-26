//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Chingiz on 29.11.2023.
//

import UIKit

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    
    private let statisticsLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.font = .boldSystemFont(ofSize: 34)
        trackerLabel.textColor = .trBlack
        trackerLabel.text = NSLocalizedString("statisticsLabel.text", comment: "")
        return trackerLabel
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "disappointedFace")
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .trBlack
        label.text = NSLocalizedString("emptyStateStatistics.text", comment: "")
        return label
    }()
    
    private lazy var bestPeriodLabel = CustomView()
    private lazy var perfectDaysLabel = CustomView()
    private lazy var completedTrackersLabel = CustomView()
    private lazy var averageLabel = CustomView()
    
    // MARK: -  UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchStats()
    }
    
    
    private func setupViews() {
        [statisticsLabel,
         emptyStateImageView,
         emptyStateLabel,
         bestPeriodLabel,
         perfectDaysLabel,
         completedTrackersLabel,
         averageLabel
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statisticsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bestPeriodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bestPeriodLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bestPeriodLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -198),
            bestPeriodLabel.heightAnchor.constraint(equalToConstant: 90),
            
            perfectDaysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            perfectDaysLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            perfectDaysLabel.topAnchor.constraint(equalTo: bestPeriodLabel.bottomAnchor, constant: 12),
            perfectDaysLabel.heightAnchor.constraint(equalToConstant: 90),
            
            completedTrackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedTrackersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackersLabel.topAnchor.constraint(equalTo: perfectDaysLabel.bottomAnchor, constant: 12),
            completedTrackersLabel.heightAnchor.constraint(equalToConstant: 90),
            
            averageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            averageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            averageLabel.topAnchor.constraint(equalTo: completedTrackersLabel.bottomAnchor, constant: 12),
            averageLabel.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func showPlaceholder() {
        emptyStateImageView.isHidden = false
        emptyStateLabel.isHidden = false
        bestPeriodLabel.isHidden = true
        perfectDaysLabel.isHidden = true
        completedTrackersLabel.isHidden = true
        averageLabel.isHidden = true
    }
    
    private func hidePlaceholder() {
        emptyStateImageView.isHidden = true
        emptyStateLabel.isHidden = true
        bestPeriodLabel.isHidden = false
        perfectDaysLabel.isHidden = false
        completedTrackersLabel.isHidden = false
        averageLabel.isHidden = false
    }
    
    private func fetchStats() {
        let trackersCompleted = trackerRecordStore.getNumberOfCompletedTrackers()
        if trackersCompleted == 0 {
            showPlaceholder()
            return
        } else {
            if let stats = trackerRecordStore.getStats() {
                hidePlaceholder()
                let perfectDays = stats[0]
                perfectDaysLabel.updateView(number: "\(perfectDays)", name: NSLocalizedString("Perfect days", comment: ""))
                
                completedTrackersLabel.updateView(number: "\(trackersCompleted)", name: NSLocalizedString("Trackers completed", comment: ""))
                
                let average = stats[1]
                averageLabel.updateView(number: "\(average)", name: NSLocalizedString("Average value", comment: ""))
                
                let bestPeriod = stats[2]
                bestPeriodLabel.updateView(number: "\(bestPeriod)", name: NSLocalizedString("Best period", comment: ""))
            }
        }
    }
}
