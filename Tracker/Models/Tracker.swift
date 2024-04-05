//
//  Tracker.swift
//  Tracker
//
//  Created by Chingiz on 13.12.2023.
//

import UIKit

struct Tracker {
    let idTracker: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let isPinned: Bool
}
