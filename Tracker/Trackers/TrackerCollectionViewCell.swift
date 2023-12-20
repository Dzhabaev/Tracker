//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Chingiz on 15.12.2023.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    // MARK: - Private Properties
    
    private let trackerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        view.backgroundColor = .colorSelection5
        
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        
        label.text = "❤️"
        
        return label
    }()
    
    private let trackerNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        
        label.text = "Поливать растения"
        
        return label
    }()
    
    private let dayCounterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .trBlack
        
        label.text = "1 день"
        
        return label
    }()
    
    private let counterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .trWhite
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.contentMode = .center
        button.addTarget(self, action: #selector(pushCounterButton), for: .touchUpInside)
        
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .colorSelection5
        
        return button
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func pushCounterButton() {
        print("Нажали на плюсик")
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        [trackerView,
         dayCounterLabel,
         counterButton
        ].forEach { contentView.addSubview($0) }
        
        [emojiLabel,
         trackerNameLabel
        ].forEach { trackerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            dayCounterLabel.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16),
            dayCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayCounterLabel.heightAnchor.constraint(equalToConstant: 18),
            
            counterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            counterButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            counterButton.heightAnchor.constraint(equalToConstant: 34),
            counterButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
}
