//
//  DrawPadViewModel.swift
//  Draw
//
//  Created by Nate Madera on 1/1/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import UIKit

// MARK: ViewModel Protocol
protocol DrawPadViewModelProtocol {
    func numberOfItems() -> Int
    func color(at indexPath: IndexPath) -> UIColor?
    func indexPathForSelectedColor() -> IndexPath?
    mutating func didSelectColor(at indexPath: IndexPath)
}

// MARK: - DrawPadViewModel
struct DrawPadViewModel: DrawPadViewModelProtocol {
    
    // MARK: Properties
    private var colors: [UIColor]
    private var strokeColor: UIColor
    
    // MARK: Initializer
    init(colors: [UIColor] = [.black, .darkGray, .white, .brown, .red, .orange, .yellow, .magenta, .purple, .green, .blue]) {
        self.colors = colors
        self.strokeColor = colors.first ?? .black
    }
    
    // MARK: Protocol Functions
    func numberOfItems() -> Int {
        return colors.count
    }
    
    func color(at indexPath: IndexPath) -> UIColor? {
        guard colors.indices.contains(indexPath.row) else { return nil }
        
        return colors[indexPath.row]
    }
    
    func indexPathForSelectedColor() -> IndexPath? {
        guard let index = colors.firstIndex(of: strokeColor) else { return nil }
        
        return IndexPath(item: index, section: 0)
    }
    
    mutating func didSelectColor(at indexPath: IndexPath) {
        guard let color = color(at: indexPath) else { return }
        
        strokeColor = color
    }
}
