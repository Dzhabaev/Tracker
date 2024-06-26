//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Chingiz on 07.01.2024.
//

import CoreData
import UIKit

// MARK: - Error enumeration

private enum TrackerRecordStoreError: Error {
    case failedToFetchTracker
    case failedToFetchRecord
}

// MARK: - TrackerRecordStoreProtocol

protocol TrackerRecordStoreProtocol {
    func recordsFetch(for tracker: Tracker) throws -> [TrackerRecord]
    func addRecord(with id: UUID, by date: Date) throws
    func deleteRecord(with id: UUID, by date: Date) throws
}

// MARK: - TrackerRecordStore class

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private let schedule: [WeekDay] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday
    ]
    
    // MARK: - Initializers
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public methods
    
    func getNumberOfCompletedTrackers() -> Int {
        return fetchCompletedRecords().count
    }
    
    func getStats() -> [Int]? {
        let recordsDict = getSortedRecords()
        let dates = recordsDict.compactMap { $0["date"] as? Date }
        let perfectDays = getPerfectDays(from: dates)
        let bestPeriod = checkStreak(of: dates)
        let average = getNumberOfCompletedTrackers() / recordsDict.count
        
        return [perfectDays, average, bestPeriod]
    }
    
    // MARK: - Private methods
    
    private func fetchRecords(_ tracker: Tracker) throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerRecordCoreData.trackerID), tracker.idTracker as CVarArg
        )
        let objects = try context.fetch(request)
        let records = objects.compactMap { object -> TrackerRecord? in
            guard let date = object.date, let id = object.trackerID else { return nil }
            return TrackerRecord(trackerID: id, date: date)
        }
        return records
    }
    
    private func fetchTrackerCoreData(for idTracker: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCoreData.idTracker), idTracker as CVarArg
        )
        return try context.fetch(request).first
    }
    
    private func fetchTrackerRecordCoreData(for idTracker: UUID, and date: Date) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(TrackerRecordCoreData.trackers.idTracker), idTracker as CVarArg,
            #keyPath(TrackerRecordCoreData.date), date as CVarArg
        )
        return try context.fetch(request).first
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    private func createNewRecord(id: UUID, date: Date) throws {
        guard let trackerCoreData = try fetchTrackerCoreData(for: id) else {
            throw TrackerRecordStoreError.failedToFetchTracker
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerID = id
        trackerRecordCoreData.date = date
        trackerRecordCoreData.trackers = trackerCoreData
        
        try saveContext()
    }
    
    private func removeRecord(idTracker: UUID, date: Date) throws {
        guard let trackerRecordCoreData = try fetchTrackerRecordCoreData(for: idTracker, and: date) else {
            throw TrackerRecordStoreError.failedToFetchRecord
        }
        context.delete(trackerRecordCoreData)
        try saveContext()
    }
    
    private func fetchCompletedRecords() -> [TrackerRecordCoreData] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    private func getPerfectDays(from dates: [Date]) -> Int {
        return dates.filter { date in
            let weekday = Calendar.current.component(.weekday, from: date)
            return schedule.contains(where: { $0.rawValue == weekday })
        }.count
    }
    
    private func getSortedRecords() -> [[String: Any]] {
        let keyPathExp = NSExpression(forKeyPath: "date")
        let expression = NSExpression(forFunction: "count:", arguments: [keyPathExp])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["date"]
        request.propertiesToFetch = ["date", countDesc]
        request.resultType = .dictionaryResultType
        
        do {
            let trackerRecords = try context.fetch(request) as! [NSDictionary]
            return trackerRecords.map { $0 as! [String: Any] }
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    private func checkStreak(of dateArray: [Date]) -> Int {
        let dates = dateArray.sorted()
        guard dates.count > 0 else { return 0 }
        let referenceDate = Calendar.current.startOfDay(for: dates.first!)
        let dayDiffs = dates.map { date in
            Calendar.current.dateComponents([.day], from: referenceDate, to: date).day!
        }
        return maximalConsecutiveNumbers(in: dayDiffs)
    }
    
    private func maximalConsecutiveNumbers(in array: [Int]) -> Int {
        var longest = 0
        var current = 1
        for (prev, next) in zip(array, array.dropFirst()) {
            if next > prev + 1 {
                current = 1
            } else if next == prev + 1 {
                current += 1
            }
            if current > longest {
                longest = current
            }
        }
        return longest
    }
}

// MARK: - TrackerRecordStoreProtocol

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    
    func recordsFetch(for tracker: Tracker) throws -> [TrackerRecord] {
        try fetchRecords(tracker)
    }
    
    func addRecord(with id: UUID, by date: Date) throws {
        try createNewRecord(id: id, date: date)
    }
    
    func deleteRecord(with id: UUID, by date: Date) throws {
        try removeRecord(idTracker: id, date: date)
    }
}
