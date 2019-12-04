//
//  LoginResponse.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let account:Account
    let session:Session
}


struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}
