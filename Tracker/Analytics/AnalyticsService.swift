//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Chingiz on 09.04.2024.
//

import YandexMobileMetrica

final class AnalyticsService {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "255b6c53-7665-49da-9a77-37575dd3977a") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func reportEvent(event: String, parameters: [String: String]) {
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
