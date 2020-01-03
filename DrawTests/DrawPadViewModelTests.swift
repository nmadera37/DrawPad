//
//  DrawPadViewModelTests.swift
//  DrawTests
//
//  Created by Nate Madera on 1/2/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import XCTest
@testable import Draw

class DrawPadViewModelTests: XCTestCase {

    func testColorAtIndethPath() {
        let colors: [UIColor] = [.red, .white, .blue]
        let viewModel = DrawPadViewModel(colors: colors)
        
        let expected = UIColor.white
        let actual = viewModel.color(at: IndexPath(item: 1, section: 0))
        
        XCTAssertEqual(expected, actual)
    }
    
    func testIndexPathForSelectedColor() {
        let colors: [UIColor] = [.red, .white, .blue]
        var viewModel = DrawPadViewModel(colors: colors)
        viewModel.didSelectColor(at: IndexPath(item: 2, section: 0))
        
        let expected = IndexPath(item: 2, section: 0)
        let actual = viewModel.indexPathForSelectedColor()
        
        XCTAssertEqual(expected, actual)
    }
    
    func testNumberOfItems() {
        let colors: [UIColor] = [.red, .white, .blue]
        let viewModel = DrawPadViewModel(colors: colors)
        
        
        let expected = colors.count
        let actual = viewModel.numberOfItems()
        
        XCTAssertEqual(expected, actual)
    }
}
