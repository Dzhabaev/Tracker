//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Chingiz on 17.12.2023.
//

import UIKit

// MARK: - CategoryViewControllerDelegate

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

// MARK: - CategoryViewController

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var dataForTableView: [String] = []
    private var selectedCategoryIndex: Int?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = .trGray
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushAddCategoryButton), for: .touchUpInside)
        return button
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "glowingStar")
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = .trBlack
        return label
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        navigationItem.hidesBackButton = true
        setupNavBar()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func pushAddCategoryButton() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        navigationItem.title = "Категория"
    }
    
    private func setupView() {
        [tableView,
         addCategoryButton,
         emptyStateImageView,
         emptyStateLabel
        ].forEach { view.addSubview($0) }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func showEmptyStateImage() {
        emptyStateImageView.isHidden = false
        emptyStateLabel.isHidden = false
        tableView.isHidden = true
    }
    
    private func hideEmptyStateImage() {
        emptyStateImageView.isHidden = true
        emptyStateLabel.isHidden = true
        tableView.isHidden = false
    }
    
    private func updateEmptyStateVisibility() {
        if dataForTableView.isEmpty {
            showEmptyStateImage()
        } else {
            hideEmptyStateImage()
        }
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCategoryIndex = indexPath.row
        tableView.reloadData()
        
        let selectedCategory = dataForTableView[indexPath.row]
        delegate?.didSelectCategory(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath)
        guard cell is CustomTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = dataForTableView[indexPath.row]
        cell.backgroundColor = .trBackgroundDay
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0
        
        if dataForTableView.count == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == numberOfRows - 1 {
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.maskedCorners = []
            }
        }
        
        if indexPath.row == selectedCategoryIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - NewCategoryViewControllerDelegate

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didCreateCategory(_ category: String) {
        if !dataForTableView.contains(category) {
            dataForTableView.append(category)
            tableView.invalidateIntrinsicContentSize()
            tableView.layoutIfNeeded()
            tableView.reloadData()
            updateEmptyStateVisibility()
        }
    }
    
    func updatedCategoryList(_ categories: [String]) {
        dataForTableView = categories
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
}
