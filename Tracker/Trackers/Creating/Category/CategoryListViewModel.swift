//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Chingiz on 26.03.2024.
//

import Foundation

class CategoryListViewModel {
    typealias Binding<T> = (T) -> Void
    
    private let categoryStore: TrackerCategoryStoreProtocol
    private var categories: [TrackerCategory] = []
    
    var updateHandler: (() -> Void)?
    
    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
    }
    
    func fetchCategories() {
        categoryStore.getCategories { [weak self] categories in
            self?.categories = categories
            self?.updateHandler?()
        }
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    func didSelectCategory(at index: Int) {
        updateHandler?()
    }
    
    func addCategory(_ category: TrackerCategory) {
        categoryStore.addCategory(category) { [weak self] error in
            if let error = error {
                print("Failed to add category with error: \(error)")
                return
            }
            self?.fetchCategories()
        }
    }
}
