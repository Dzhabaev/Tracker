//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Chingiz on 15.12.2023.
//

import UIKit

// MARK: - TrackerCollectionViewCellDelegate

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func competeTracker(id: UUID)
    func uncompleteTracker(id: UUID)
}

// MARK: - TrackerCollectionViewCell

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    var isCompleted: Bool?
    var trackerID: UUID?
    var indexPath: IndexPath?
    
    // MARK: - Private Properties
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
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
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let completedDaysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .trBlack
        return label
    }()
    
    private let counterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .trWhite
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.contentMode = .center
        button.addTarget(self, action: #selector(completionButtonTapped), for: .touchUpInside)
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
    
    // MARK: - Public Methods
    
    func setupUI(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerID = tracker.id
        self.isCompleted = isCompletedToday
        self.indexPath = indexPath
        
        containerView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        updateCounterLabelText(completedDays: completedDays)
        
        let image = isCompleted! ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        counterButton.backgroundColor = isCompletedToday ? tracker.color.withAlphaComponent(0.3) : tracker.color
        nameLabel.backgroundColor = tracker.color
        for view in self.counterButton.subviews {
            view.removeFromSuperview()
        }
        counterButton.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: counterButton.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: counterButton.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc func completionButtonTapped() {
        guard let isCompleted = isCompleted,
              let trackerID = trackerID
        else {
            return
        }
        if isCompleted {
            delegate?.uncompleteTracker(id: trackerID)
        } else {
            delegate?.competeTracker(id: trackerID)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        [containerView,
         completedDaysLabel,
         counterButton
        ].forEach { contentView.addSubview($0) }
        
        [emojiLabel,
         nameLabel
        ].forEach { containerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            completedDaysLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            completedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            completedDaysLabel.heightAnchor.constraint(equalToConstant: 18),
            
            counterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            counterButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            counterButton.heightAnchor.constraint(equalToConstant: 34),
            counterButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func updateCounterLabelText(completedDays: Int){
        let remainder = completedDays % 100
        if (11...14).contains(remainder) {
            completedDaysLabel.text = "\(completedDays) дней"
        } else {
            switch remainder % 10 {
            case 1:
                completedDaysLabel.text = "\(completedDays) день"
            case 2...4:
                completedDaysLabel.text = "\(completedDays) дня"
            default:
                completedDaysLabel.text = "\(completedDays) дней"
            }
        }
    }
}
