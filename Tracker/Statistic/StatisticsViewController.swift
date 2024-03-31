//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Chingiz on 29.11.2023.
//

import UIKit

// MARK: - StatisticsViewController
final class StatisticsViewController: UIViewController {
    
    private let statisticsLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.font = .boldSystemFont(ofSize: 34)
        trackerLabel.textColor = .trBlack
        return trackerLabel
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "disappointedFace")
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .trBlack
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        [statisticsLabel,
         emptyStateImageView,
         emptyStateLabel
        ].forEach { view.addSubview($0) }
        
        let statisticsLabelText = NSLocalizedString("statisticsLabel.text", comment: "")
        statisticsLabel.text = statisticsLabelText
        let emptyStateStatisticsText = NSLocalizedString("emptyStateStatistics.text", comment: "")
        emptyStateLabel.text = emptyStateStatisticsText
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
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
