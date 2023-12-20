//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Chingiz on 18.12.2023.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CustomTableViewCell"
    
    // MARK: - Private Properties
    
    private let customLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.addSubview(customLabel)
        
        NSLayoutConstraint.activate([
            customLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

