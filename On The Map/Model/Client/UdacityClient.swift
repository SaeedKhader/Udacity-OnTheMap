//
//  UdacityClient.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // MARK: - Auth
    struct Auth {
        static var userId = ""
        static var sessionId = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    // MARK: - Endpoints
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case studentLocations
        case updateStudentLocation
        case userData
        
        
        var stringValue: String {
            switch self {
            case .session:
                return Endpoints.base + "/session"
            case .studentLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .updateStudentLocation:
                return Endpoints.base + "/StudentLocation/" + Auth.objectId
            case .userData:
                return Endpoints.base + "/users/" + Auth.userId
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    // MARK: - HTTP Methods
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, dataNeedsAdjustment: Bool, completion: @escaping (ResponseType?, Error?)->Void ) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var newData = data
            if dataNeedsAdjustment {
                let range = Range(uncheckedBounds: (lower: 5, upper: data.count))
                newData = data.subdata(in: range)
            }
            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errrorResponse = try JSONDecoder().decode(ErrorResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, errrorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, method: String,HTTPHeaders: [String], body: RequestType, responseType: ResponseType.Type,dataNeedsAdjustment: Bool, completion: @escaping (ResponseType?, Error?)->Void ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        for HTTPHeader in HTTPHeaders {
            request.addValue("application/json", forHTTPHeaderField: HTTPHeader)
        }
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var newData = data
            if dataNeedsAdjustment {
                let range = Range(uncheckedBounds: (lower: 5, upper: data.count))
                newData = data.subdata(in: range)
            }
            do {
                let responseObject = try JSONDecoder().decode(responseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            } catch {
                do {
                    let errrorResponse = try JSONDecoder().decode(ErrorResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, errrorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: - Client Functions
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        taskForPOSTRequest(url: Endpoints.session.url, method: "POST", HTTPHeaders: ["Accept", "Content-Type"], body: LoginRequest(udacity: Udacity(username: username, password: password)), responseType: LoginResponse.self, dataNeedsAdjustment: true) { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.userId = response.account.key
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func getStudentLocations(completion: @escaping ([StudentLocation], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.studentLocations.url, responseType: StudentLocationsResponse.self, dataNeedsAdjustment: false) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getPublicUserData(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.userData.url, responseType: UserPublicDataResponse.self, dataNeedsAdjustment: true) { (response, error) in
            if let response = response {
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void ) {
        let body = CreateStudentLocationRequest(uniqueKey: Auth.userId, firstName: Auth.firstName, lastName: Auth.lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        
        taskForPOSTRequest(url: Endpoints.studentLocations.url, method: "POST", HTTPHeaders: ["Content-Type"], body: body , responseType: CreateStudentLocationResponse.self, dataNeedsAdjustment: false) { (response, error) in
            if let response = response {
                Auth.objectId = response.objectId
                OTMModel.myLocation = StudentLocation(createRequest: body, createdAt: response.createdAt, updatedAt: response.createdAt, objectId: response.objectId)
                OTMModel.studentLocations.insert(OTMModel.myLocation!, at: 0)
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func updateStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void ) {
        let body = CreateStudentLocationRequest(uniqueKey: Auth.userId, firstName: Auth.firstName, lastName: Auth.lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        
        taskForPOSTRequest(url: Endpoints.updateStudentLocation.url, method: "PUT", HTTPHeaders: ["Content-Type"], body: body, responseType: UpdateStudentLocationResponse.self, dataNeedsAdjustment: false) { (response, error) in
            if let response = response {
                OTMModel.myLocation!.update(request: body, updatedAt: response.updatedAt)
                var index: Int?
                for (i, location) in OTMModel.studentLocations.enumerated() {
                    if location.objectId == OTMModel.myLocation!.objectId {
                        index = i
                        break
                    }
                }
                if let index = index {
                    OTMModel.studentLocations[index].update(request: body, updatedAt: response.updatedAt)
                }
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            Auth.sessionId = ""
            Auth.userId = ""
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        task.resume()
    }
    
}
