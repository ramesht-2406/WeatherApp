//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import Foundation

class WeatherModel: Codable {
    var base: String?
    var id: Int?
    var dt: TimeInterval?
    var main: Main?
    var coord: Coord?
    var wind: Wind?
    var sys: Sys?
    var weather: [Weather]?
    var visibility: Int?
    var clouds: Clouds?
    var timezone: Int?
    var cod: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case base
        case id
        case dt
        case main
        case coord
        case wind
        case sys
        case weather
        case visibility
        case clouds
        case timezone
        case cod
        case name
    }
}

class Main: Codable {
    var tempMax: Double?
    var humidity: Double?
    var feelsLike: Double
    var tempMin: Double?
    var temp: Double?
    var pressure: Int?
    
    enum CodingKeys: String, CodingKey {
        case tempMax = "temp_max"
        case humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case temp
        case pressure
    }
}

struct Coord: Codable {
    var lon: Double?
    var lat: Double?
}

struct Wind: Codable {
    var speed: Double?
    var deg: Int?
}

struct Sys: Codable {
    var id: Int?
    var country: String
    var sunset: TimeInterval?
    var type: Int?
    var sunrise: TimeInterval?
}

struct Weather: Codable {
    var id: Int?
    var main: String?
    var icon: String?
    var description: String?
}

struct Clouds: Codable {
    var all: Int?
}

struct CityModel: Codable {
    var lat: Double?
    var country: String?
    var name: String?
    var lon: Double?
    var state: String?
    
    enum CodingKeys: String, CodingKey {
        case lat
        case country
        case name
        case lon
        case state
    }
}
