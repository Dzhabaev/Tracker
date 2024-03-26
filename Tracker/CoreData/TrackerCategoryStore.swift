//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Chingiz on 07.01.2024.
//

import CoreData
import UIKit

// MARK: - Error enumeration

private enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case failedToInitializeTracker
    case failedToFetchCategory
}

// MARK: - TrackerStoreUpdate structure

struct TrackerCategoryStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
}

// MARK: - Protocols

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreProtocol {
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate)
    func getCategories(completion: @escaping ([TrackerCategory]) -> Void)
    func fetchCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData
    func addCategory(_ category: TrackerCategory, completion: @escaping (Error?) -> Void)
}

// MARK: - TrackerCategoryStore class

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private properties
    
    private lazy var trackerStore: TrackerStore = {
        TrackerStore(context: context)
    }()
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchedRequest = TrackerCategoryCoreData.fetchRequest()
        fetchedRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.categoryTitle, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchedRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: - Initializers
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Private methods
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    private func convertToTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.categoryTitle else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        guard let trackersSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        let trackerList = try trackersSet.compactMap { trackerCoreData in
            guard let tracker = try? trackerStore.fetchTracker(trackerCoreData) else {
                throw TrackerCategoryStoreError.failedToInitializeTracker
            }
            return tracker
        }
        return TrackerCategory(categoryTitle: title, trackers: trackerList)
    }
    
    private func fetchCategories() throws -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            throw TrackerCategoryStoreError.failedToFetchCategory
        }
        let categories = try objects.map { try convertToTrackerCategory(from: $0) }
        return categories
    }
    
    private func fetchTrackerCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCategoryCoreData.categoryTitle), category.categoryTitle
        )
        guard let categoryCoreData = try context.fetch(request).first else {
            throw TrackerCategoryStoreError.failedToFetchCategory
        }
        return categoryCoreData
    }
    
    private func ensureUniqueCategoryTitle(with title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCategoryCoreData.categoryTitle), title
        )
        let count = try context.count(for: request)
        guard count == 0 else {
            return
        }
    }
    
    private func addNewCategory(_ category: TrackerCategory) throws {
        try ensureUniqueCategoryTitle(with: category.categoryTitle)
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.categoryTitle = category.categoryTitle
        categoryCoreData.trackers = NSSet()
        try saveContext()
    }
}

// MARK: - TrackerCategoryStoreProtocol

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }
    
    func getCategories(completion: @escaping ([TrackerCategory]) -> Void) {
        do {
            let categories = try fetchCategories()
            completion(categories)
        } catch {
            print("Failed to fetch categories with error: \(error)")
            completion([])
        }
    }
    
    func fetchCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        do {
            let categoryCoreData = try fetchTrackerCategoryCoreData(for: category)
            return categoryCoreData
        } catch {
            throw error
        }
    }
    
    func addCategory(_ category: TrackerCategory, completion: @escaping (Error?) -> Void) {
        do {
            try addNewCategory(category)
            completion(nil)
        } catch {
            print("Failed to add category with error: \(error)")
            completion(error)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerCategoryStoreUpdate(
                insertedIndexPaths: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths
            )
        )
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}

