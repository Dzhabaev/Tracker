//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Chingiz on 09.04.2024.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: String)
    func didDeselectFilter()
}

// MARK: - FiltersViewController

final class FiltersViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: FiltersViewControllerDelegate?
    var currentFilter: String?
    
    // MARK: - Private Properties
    private let filters = [
        NSLocalizedString("All trackers", comment: ""),
        NSLocalizedString("Trackers for today", comment: ""),
        NSLocalizedString("Completed", comment: ""),
        NSLocalizedString("Not completed", comment: "")
    ]
    
    private let viewTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Black")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("viewTitle.text", comment: "")
        return label
    }()
    
    private let filtersTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .trWhite
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = .trGray
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersTable.dataSource = self
        filtersTable.delegate = self
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        view.backgroundColor = .trWhite
        view.addSubview(viewTitle)
        view.addSubview(filtersTable)
        
        viewTitle.translatesAutoresizingMaskIntoConstraints = false
        filtersTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            viewTitle.heightAnchor.constraint(equalToConstant: 22),
            
            filtersTable.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 24),
            filtersTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTable.heightAnchor.constraint(equalToConstant: 300),
            
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .trBackground
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        cell.textLabel?.text = filters[indexPath.row]
        
        if currentFilter == filters[indexPath.row] {
            self.filtersTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            cell.isSelected = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        
        if currentFilter == selectedFilter {
            self.dismiss(animated: true)
            return
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        delegate?.didSelectFilter(selectedFilter)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
