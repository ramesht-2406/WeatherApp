//
//  APIHandler.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import Foundation

class APIHandler {
    
    let apiHandler: NetworkHandler
    let parseHandler: ResponseHandler
    
    init(apiHandler: NetworkHandler, parseHandler: ResponseHandler) {
        self.apiHandler = apiHandler
        self.parseHandler = parseHandler
    }
    
    //MARK: - URLSession Requests
    func createGETRequestwithUrlSession<T>(withUrl url: String, completionHandler:@escaping (T?, String?) -> Void)  where T: Codable {
        self.apiHandler.requestDataToAPI(url: url) { data, error in
            self.parseHandler.parseResponse(data: data) { (modelObject: T?, error)  in
                completionHandler(modelObject, error)
            }
        }
    }
}

struct NetworkHandler {
    //Set a Timeout Interval for Webservice Call
    //If the timeout expires and the work hasn't completed
    let timeoutInterval: Double = 60.0
    
    func requestDataToAPI(url: String, completionHandler:@escaping (Data?, String?) -> Void) {
        // Network request and wait the response
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as String
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "GET"
        request.timeoutInterval = timeoutInterval
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                completionHandler(nil, error?.localizedDescription ?? "Unknown error")// handle network error
                return
            }
            completionHandler(data, nil)
            self.showResponse(data)
        }
        task.resume()
    }
    
    func showResponse(_ data: Data) {
#if DEBUG
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print("\n---> response json: " + String(decoding: jsonData, as: UTF8.self))
        } else {
            print("=========> json data malformed")
        }
#endif
    }
}

struct ResponseHandler {
    
    func parseResponse<T>(data: Data?, completionHandler:@escaping (T?, String?) -> Void)  where T: Decodable {
        guard let data = data else {
            completionHandler(nil, "Data not found")
            return
        }
        do {
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let jsonObject = json {
                let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any, options: .prettyPrinted)
                do {
                    let response = try? JSONDecoder().decode(T.self, from: jsonData!)
                    if response == nil {
                        if let jsonParam = jsonObject as? [String: Any] {
                            completionHandler(response, jsonParam["message"] as? String ?? "")
                        }
                    }
                    completionHandler(response, "")
                } catch(let error) {
                    completionHandler(nil, "\(error.localizedDescription)")
                    print("JSON error: \(error.localizedDescription)")
                }
            } else {
                print("Json object is not formed")
                completionHandler(nil, "Json object is not formed")
            }
        } catch (let error) {
            print("JSON error: \(error.localizedDescription)")
            completionHandler(nil, "\(error.localizedDescription)")
        }
    }
}
