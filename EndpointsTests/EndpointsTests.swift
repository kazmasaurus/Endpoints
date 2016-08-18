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
}

func datum(from: JSON) -> JSON! { return from["data"] as? JSON }
