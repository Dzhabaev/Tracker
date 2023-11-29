//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Chingiz on 28.11.2023.
//

import UIKit

// MARK: - TrackersViewController
final class TrackersViewController: UIViewController {
    
    private let addTrackerButton: UIButton = {
        let addTrackerButton = UIButton.systemButton(
            with: UIImage(systemName: "plus")!,
            target: self,
            action: #selector(didTapAddTrackerButton))
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        addTrackerButton.accessibilityIdentifier = "TapAddTrackerButton"
        addTrackerButton.tintColor = .trBlack
        return addTrackerButton
    }()
    
    private let trackersLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.text = "Трекеры"
        trackerLabel.font = .boldSystemFont(ofSize: 34)
        trackerLabel.textColor = .trBlack
        return trackerLabel
    }()
    
    private let errorImageView: UIImageView = {
        let errorImageView = UIImageView()
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.image = UIImage(named: "errorImage")
        return errorImageView
    }()
    
    private let errorTextLabel: UILabel = {
        let errorTextLabel = UILabel()
        errorTextLabel.translatesAutoresizingMaskIntoConstraints = false
        errorTextLabel.text = "Что будем отслеживать?"
        errorTextLabel.font = .systemFont(ofSize: 12)
        errorTextLabel.textColor = .trBlack
        return errorTextLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        applyConstraints()
    }
    
    @objc private func didTapAddTrackerButton() {
        print("didTapAddTrackerButton")
    }
    
    private func addSubview() {
        view.addSubview(addTrackerButton)
        view.addSubview(trackersLabel)
        view.addSubview(errorImageView)
        view.addSubview(errorTextLabel)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            
            trackersLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 0),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            errorImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            errorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80),
            
            errorTextLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
            errorTextLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}

