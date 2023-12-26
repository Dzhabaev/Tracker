//
//  UITextField+Extension.swift
//  Tracker
//
//  Created by Chingiz on 16.12.2023.
//

import UIKit

extension UITextField {
    func addLeftPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
