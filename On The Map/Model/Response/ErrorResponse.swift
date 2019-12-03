//
//  ErrorResponse.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let status: Int
    let error: String
}


extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
