//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Chingiz on 13.12.2023.
//

import Foundation

// Структура для хранения трекеров по категориям

struct TrackerCategory {
    let title: String // Заголовок категории
    var trackers: [Tracker] // Массив трекеров, относящихся к этой категории
}
