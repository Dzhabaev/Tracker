//
//  Tracker.swift
//  Tracker
//
//  Created by Chingiz on 13.12.2023.
//

import UIKit

// Структура для хранения информации о трекере

struct Tracker {
    let id: UUID // Уникальный идентификатор трекера
    let name: String // Название трекера
    let color: UIColor // Цвет трекера
    let emoji: String // Эмоджи для трекера
    let schedule: [WeekDay] // Расписание трекера
}
