//
//  Constants.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import Foundation

public let MODEL_IDENTIFIER = "ModelIdentifier"
public let CITY_IDENTIFIER = "CityIdentifier"

//
class Constants {
    
    public static let LAST_CITYSEARCHED = "lastcitySearched"
    
    public static let API_KEY = "1c2ba745810db56a9f945361a2520a0a"
    
    public static let API_BASE_URL = "https://api.openweathermap.org/data/2.5/"
    public static let GET_WEATHER_BYCITY = API_BASE_URL + "weather?q="
    
    
    public static func GET_WEATHER_BYLATLONG(_ lat: String, long: String, lang: String) -> String {
        return API_BASE_URL + "weather?lat=\(lat)&lon=\(long)&lang=\(lang)&units=metric&appid=" + API_KEY
    }
    
    public static func GET_CITIES(_ cityName: String) -> String {
        return "http://api.openweathermap.org/geo/1.0/direct?q=\(cityName),US&limit=10&appid=\(API_KEY)"
    }
    
    public static func get_ImageUrl(iconID: String ) -> String {
        return "https://openweathermap.org/img/wn/\(iconID)@2x.png"
    }
    
    public static func GET_DAILY_WEATHER(_ lat: String, long: String, lang: String) -> String {
        return API_BASE_URL + "onecall?lat=\(lat)&lon=\(long)&lang=\(lang)&exclude=minutely&units=metric&appid=\(API_KEY)"
    }
    
}
