//
//  CreatingTrackerViewController.swift
//  Tracker
//
//  Created by Chingiz on 15.12.2023.
//

import UIKit

protocol CreatingTrackerViewControllerDelegate: AnyObject {
    func createTracker(tracker: Tracker, categoryTitle: String)
    func cancelCreateTracker()
}

// MARK: - CreatingTrackerViewController

final class CreatingTrackerViewController: UIViewController {
    
    weak var delegate: TrackersViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let regularButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("regularButton.setTitle", comment: ""), for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let irregularButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("irregularButton.setTitle", comment: ""), for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupConstraints()
        setupButtons()
        view.backgroundColor = .trWhite
    }
    
    // MARK: - Actions
    
    @objc private func regularButtonClicked() {
        let newRegularViewController = NewRegularViewController()
        newRegularViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newRegularViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func irregularButtonClicked() {
        let newIrregularViewController = NewIrregularViewController()
        newIrregularViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newIrregularViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar(){
        navigationItem.title = NSLocalizedString("creatingNavigationItem.title", comment: "")
    }
    
    private func setupButtons() {
        regularButton.addTarget(self, action: #selector(regularButtonClicked), for: .touchUpInside)
        irregularButton.addTarget(self, action: #selector(irregularButtonClicked), for: .touchUpInside)
        stackView.addArrangedSubview(regularButton)
        stackView.addArrangedSubview(irregularButton)
    }
    
    private func setupConstraints() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
}

// MARK: - CreatingTrackerViewControllerDelegate

extension CreatingTrackerViewController: CreatingTrackerViewControllerDelegate {
    func createTracker(tracker: Tracker, categoryTitle: String) {
        delegate?.createdTracker(tracker: tracker, categoryTitle: categoryTitle)
        dismiss(animated: true)
        cancelCreateTracker()
    }
    
    func cancelCreateTracker() {
        dismiss(animated: true)
    }
}
