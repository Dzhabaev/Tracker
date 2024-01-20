//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Chingiz on 17.12.2023.
//

import UIKit

// MARK: - NewCategoryViewControllerDelegate

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ category: TrackerCategory)
}


// MARK: - NewCategoryViewController

final class NewCategoryViewController: UIViewController {
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .trBackgroundDay
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.addLeftPadding(16)
        textField.placeholder = "Введите название категории"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.smartInsertDeleteType = .no
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushDoneButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        setupNavBar()
        setupView()
        setupConstraints()
        doneButton.isEnabled = false
        doneButton.backgroundColor = .trGray
    }
    
    // MARK: - Actions
    
    @objc private func pushDoneButton() {
        if let text = textField.text, !text.isEmpty {
            let category = TrackerCategory(categoryTitle: text, trackers: [])
            delegate?.didCreateCategory(category)
        }
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        navigationItem.title = "Новая категория"
    }
    
    private func setupView() {
        [textField,
         doneButton
        ].forEach {
            view.addSubview($0)
        }
        textField.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, !text.isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .trBlack
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .trGray
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

