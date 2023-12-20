//
//  CreatingTrackerViewController.swift
//  Tracker
//
//  Created by Chingiz on 15.12.2023.
//

import UIKit

final class CreatingTrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let regularButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Привычка", for: .normal)
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
        button.setTitle("Нерегулярные событие", for: .normal)
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
        let newRegularViewController = UINavigationController(rootViewController: NewRegularViewController())
        present(newRegularViewController, animated: true)
    }
    
    @objc private func irregularButtonClicked() {
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar(){
        navigationItem.title = "Создание трека"
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
