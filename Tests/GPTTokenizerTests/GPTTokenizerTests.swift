//
//  GPTTokenizerTests.swift
//  
//
//  Created by Adam Wulf on 5/12/23.
//

import XCTest
@testable import GPTTokenizer

final class GPTTokenizerTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(try GPTTokenizer.Encode("hello world").count, 2)
        XCTAssertEqual(try GPTTokenizer.Encode("hello world"), [15339, 1917])
    }
}
