//
//  Fixtures.swift
//  Endpoints
//
//  Created by Zak Remer on 8/17/16.
//  Copyright © 2016 Opal. All rights reserved.
//

import Foundation


extension String {
    var jsonFixture: [String : AnyObject] {
        let path = Bundle.testBundle.path(forResource: self, ofType: "json")!
        let data = FileManager.default.contents(atPath: path)!
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        return json as! [String : AnyObject]
    }
}

// Load from the correct bundle
private class DumbClass {}

extension Bundle {
    static var testBundle: Bundle {
        return .init(for: DumbClass.self)
    }
}
