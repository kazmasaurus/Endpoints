//
//  TestBundle.swift
//  OpalKit
//
//  Created by Zak Remer on 6/23/16.
//  Copyright © 2016 Opal Labs. All rights reserved.
//

import Foundation

private class DumbClass {}

extension NSBundle {
    static var testBundle: NSBundle {
        return NSBundle(forClass: DumbClass.self)
    }
}
