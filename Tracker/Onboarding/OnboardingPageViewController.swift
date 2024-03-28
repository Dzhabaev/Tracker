//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Chingiz on 28.03.2024.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    
    // MARK: - Properties
    
    private let imageName: String
    private let labelText: String
    
    // MARK: - UI Elements
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .trBlackAny
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    // MARK: - Initialization
    
    init(imageName: String, labelText: String) {
        self.imageName = imageName
        self.labelText = labelText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        backgroundImageView.image = UIImage(named: imageName)
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        textLabel.text = labelText
    }
}
