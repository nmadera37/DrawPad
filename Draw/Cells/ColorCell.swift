//
//  ColorCell.swift
//  Draw
//
//  Created by Nate Madera on 1/1/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    // MARK: Properties
    private var colorView: UIView!
    
    // MARK: Constants
    enum Constants {
        static let selectedBorderWidth = CGFloat(5.0)
        static let unselectedBorderWidth = CGFloat(2.0)
    }
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                colorView.layer.borderWidth = Constants.selectedBorderWidth
            } else {
                colorView.layer.borderWidth = Constants.unselectedBorderWidth
            }
        }
    }
}

// MARK: - Public Functions
extension ColorCell {
    func set(color: UIColor?) {
        colorView.backgroundColor = color
    }
}

// MARK: - Private Setup
private extension ColorCell {
    func setupView() {
        backgroundColor = .clear
        
        setupColorView()
    }
    
    func setupColorView() {
        let aView = UIView()
        aView.layer.masksToBounds = true
        aView.layer.cornerRadius = 6.0
        aView.layer.borderWidth = Constants.unselectedBorderWidth
        aView.layer.borderColor = UIColor.lightGray.cgColor
        
        colorView = aView
        
        addSubview(colorView)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: topAnchor),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
