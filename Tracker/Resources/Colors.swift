//
//  Colors.swift
//  Tracker
//
//  Created by Chingiz on 05.04.2024.
//

import UIKit

final class Colors {
    
    let tabBarSeparatorColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.trGray
        } else {
            return UIColor.black
        }
    }
}
