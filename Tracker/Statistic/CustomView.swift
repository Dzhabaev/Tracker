//
//  CustomView.swift
//  Tracker
//
//  Created by Chingiz on 10.04.2024.
//

import UIKit

final class CustomView: UIView {
    
    // MARK: - Private Properties
    
    private let innerRect: UIView = {
        let innerRect = UIView()
        innerRect.backgroundColor = .trWhite
        innerRect.clipsToBounds = true
        innerRect.layer.cornerRadius = 15
        return innerRect
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .trBlack
        label.textAlignment = .left
        return label
    }()
    
    private let statsNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trBlack
        label.textAlignment = .left
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(named: "ColorSelection1")!.cgColor,
            UIColor(named: "ColorSelection9")!.cgColor,
            UIColor(named: "ColorSelection3")!.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    // MARK: - UIView Lifecycle
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Public Methods
    
    func updateView(number: String, name: String) {
        statsNameLabel.text = name
        statsLabel.text = number
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        clipsToBounds = true
        layer.cornerRadius = 16
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(innerRect)
        innerRect.addSubview(statsLabel)
        innerRect.addSubview(statsNameLabel)
        
        innerRect.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            innerRect.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            innerRect.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            innerRect.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            innerRect.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            
            statsLabel.leadingAnchor.constraint(equalTo: innerRect.leadingAnchor, constant: 11),
            statsLabel.topAnchor.constraint(equalTo: innerRect.topAnchor, constant: 11),
            statsLabel.heightAnchor.constraint(equalToConstant: 41),
            
            statsNameLabel.leadingAnchor.constraint(equalTo: innerRect.leadingAnchor, constant: 11),
            statsNameLabel.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 7),
            statsNameLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}

