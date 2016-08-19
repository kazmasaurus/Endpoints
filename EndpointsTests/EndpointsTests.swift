//
//  EndpointsTests.swift
//  EndpointsTests
//
//  Created by Zak Remer on 8/10/16.
//  Copyright © 2016 Opal. All rights reserved.
//

import XCTest
@testable import Endpoints

class EndpointsTests: XCTestCase {

    func testEmptyStore() {
        let data = datum(from: "EmptyStore".jsonFixture)!
        let store = Store(json: data)
        XCTAssertNotNil(store)
        XCTAssertEqual(store?.head.id, "1")
        XCTAssertEqual(store?.name, "empty store")
    }

    func testFullStore() {
        let data = datum(from: "FullStore".jsonFixture)!
        let store = Store(json: data)
        XCTAssertNotNil(store)
        XCTAssertEqual(store?.head.id, "2")
        XCTAssertEqual(store?.name, "full store")

        let expectedPointers = Array<Int>(1...11).map { Pointer(id: String($0), type: "books") }
        guard let pointers = store?.bookRelationships.data.asUnfetched else { XCTFail(); return }
        XCTAssertEqual(pointers, expectedPointers)
    }
}

func datum(from: JSON) -> JSON! { return from["data"] as? JSON }
