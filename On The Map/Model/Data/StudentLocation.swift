//
//  StudentInformation.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation

struct StudentLocation: Codable {
   let createdAt: String
   let firstName: String
   let lastName: String
   var latitude: Double
   var longitude: Double
   var mapString: String
   var mediaURL: String
   let objectId: String
   let uniqueKey: String
   var updatedAt: String
    
    init(createRequest: CreateStudentLocationRequest, createdAt: String, updatedAt: String, objectId: String) {
        self.createdAt = createdAt
        self.firstName = createRequest.firstName
        self.lastName = createRequest.lastName
        self.latitude = createRequest.latitude
        self.longitude = createRequest.longitude
        self.mapString = createRequest.mapString
        self.mediaURL = createRequest.mediaURL
        self.objectId = objectId
        self.uniqueKey = createRequest.uniqueKey
        self.updatedAt = updatedAt
    }
    
    mutating func update(request: CreateStudentLocationRequest, updatedAt: String) {
        mapString = request.mapString
        latitude = request.latitude
        longitude = request.longitude
        mediaURL = request.mediaURL
        self.updatedAt = updatedAt
    }
}
