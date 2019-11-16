//
//  Future+ChainAccess.swift
//  Properations
//
//  Created by Benedict Cohen on 28/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


public extension Future {

    func getFuture(_ handler: (Future<Success>) -> Void) -> Future<Success> {
        handler(self)
        return self
    }
}
