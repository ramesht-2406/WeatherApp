//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import Foundation
import CoreLocation
import UIKit

class WeatherViewModel: NSObject {
    
    let apiHandler = APIHandler(apiHandler: NetworkHandler(), parseHandler: ResponseHandler())
    
    private var lang = Locale.current.language.languageCode?.identifier
    
    var aryCities: [CityModel] = []
    
    var dailyWeather: DailyWeather?
    var weather: WeatherModel?
    
    var showAlertMessage: ((String) -> Void)?
    var tabelViewReloadData: (() -> Void)?
    var setDataintoFields: (() -> Void)?
    var getDailyWeatherDetails: (() -> Void)?
    var latlongFetchedfromUserLocation:((CoordCity) -> Void)?
    
    //MARK: - vars/lets
    var cityName = Bindable<String?>(nil)
    var currentTemperature = Bindable<String?>(nil)
    var currentDescription =  Bindable<String?>(nil)
    var currentMinWeather = Bindable<String?>(nil)
    var currentMaxWeather = Bindable<String?>(nil)
    var currentSunriseAgo = Bindable<String?>(nil)
    var currentSunsetIn = Bindable<String?>(nil)
    var currentSunriseTime = Bindable<String?>(nil)
    var currentSunsetTime = Bindable<String?>(nil)
    var currentHumidity = Bindable<String?>(nil)
    var currentPressure = Bindable<String?>(nil)
    var currentFeelsLikeWeather = Bindable<String?>(nil)
    var currentVisibility = Bindable<String?>(nil)
    var backgroundImageView = Bindable<UIImage?>(nil)
    var currentImageWeather = Bindable<String?>(nil)
    
    
    //API Call
    func getCityNamesbySearch(_ cityName: String) {
        //We are calling APIHandler Shared,
        //And calling GET Request function
        self.apiHandler.createGETRequestwithUrlSession(withUrl: Constants.GET_CITIES(cityName)) { [weak self] (modelObject: [CityModel]?, error) in
            if modelObject == nil {
                print(error ?? "")
                self?.showAlertMessage?(error ?? "")
            } else {
                self?.aryCities = modelObject ?? []
                self?.tabelViewReloadData?()
            }
        }
    }
    
    //MARK: - flow func
    func addWeatherSettings() {
        guard let currentWeather = self.weather else { return }
        self.cityName.value = currentWeather.name
        self.currentTemperature.value = "\(currentWeather.main?.temp?.doubleToString() ?? "")°"
        self.currentMaxWeather.value = "H: \(currentWeather.main?.tempMax?.doubleToString() ?? "")°"
        self.currentMinWeather.value = "L: \(currentWeather.main?.tempMin?.doubleToString() ?? "")°"
        
        self.currentFeelsLikeWeather.value = "\(currentWeather.main?.feelsLike.doubleToString() ?? "")°"
        self.currentPressure.value = "\(currentWeather.main?.pressure ?? 0)"
        self.currentVisibility.value = "\((currentWeather.visibility ?? 0)/1000)"
        self.currentHumidity.value = "\(currentWeather.main?.humidity?.doubleToString() ?? "")"
        
        let dateSunRise = Utils.getDatefromUnixTimeStamp(currentWeather.sys?.sunrise ?? 0)
        var strSunRise = Utils.getTimeDifference(dateSunRise)
        self.currentSunriseAgo.value = strSunRise.getStringforDatetime()
        
        let dateSunset = Utils.getDatefromUnixTimeStamp(currentWeather.sys?.sunset ?? 0)
        var strSunSet = Utils.getTimeDifference(dateSunset)
        self.currentSunsetIn.value = strSunSet.getStringforDatetime()
        
        self.currentSunriseTime.value = Utils.dateFormater(date: currentWeather.sys?.sunrise ?? 0, dateFormat: "hh:mm a", timezone: currentWeather.timezone ?? 0)
        
        self.currentSunsetTime.value = Utils.dateFormater(date: currentWeather.sys?.sunset ?? 0, dateFormat: "hh:mm a", timezone: currentWeather.timezone ?? 0)
        
        if let weather = currentWeather.weather, weather.count > 0 {
            self.currentImageWeather.value = Constants.get_ImageUrl(iconID: weather[0].icon ?? "")
            self.currentDescription.value = weather[0].description
            self.backgroundImageView.value = UIImage(named: "\(weather[0].icon ?? "")-2")
        }
        
        self.setDataintoFields?()
    }
    
    func getWeatherDetailsbyLatLong(_ lat: String, long: String) {
        //We are calling APIHandler Shared,
        //And calling POST Request function
        let url = Constants.GET_WEATHER_BYLATLONG(lat, long: long, lang: lang ?? "")
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as String
        self.apiHandler.createGETRequestwithUrlSession(withUrl: urlString) { [weak self] (modelObject: WeatherModel?, error) in
            if modelObject == nil {
                print("Model object is nil")
                self?.showAlertMessage?(error ?? "")
            } else {
                self?.weather = modelObject
                self?.addWeatherSettings()
            }
        }
    }
    
    func getDailyWeather(_ lat:String, long:String) {
        let url = Constants.GET_DAILY_WEATHER(lat, long: long, lang: lang ?? "")
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as String
        self.apiHandler.createGETRequestwithUrlSession(withUrl: urlString) { [weak self] (modelObject: DailyWeather?, error) in
            if modelObject == nil {
                print("Model object is nil")
                self?.showAlertMessage?(error ?? "")
            } else {
                if let modelClass = modelObject {
                    self?.dailyWeather = modelClass
                    self?.getDailyWeatherDetails?()
                } else {
                    self?.showAlertMessage?("Cannot convert to model class")
                }
            }
        }
    }
    
    //MARK: - Fetch User Location
    func fetchUserLocation() {
        LocationManager.shared.getLocation { (location:CLLocation?, error:NSError?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let location = location else {
                return
            }
            
            //Once user allows location access,
            //Getting his current co-ordinates,
            var coordCity: CoordCity = CoordCity()
            coordCity.long = location.coordinate.longitude
            coordCity.lat = location.coordinate.latitude
            self.latlongFetchedfromUserLocation?(coordCity)
        }
    }
    
    //MARK: - TableView Methods
    func numberOfRow() -> Int {
        if aryCities.isEmpty {
            return 1
        }
        return aryCities.count
    }
    
    func cellForRow(indexPath: IndexPath) -> CityModel {
        return self.aryCities[indexPath.row]
    }
    
    func filteredCityIsEmpty() -> Bool {
        aryCities.isEmpty
    }
    
    //MARK: - CollectionView Methods
    var numberOfDailyCells: Int {
        if let dailyWeather = dailyWeather {
            return dailyWeather.daily.count
        }
        return 0
    }
    
    var numberOfHourlyCells: Int {
        if let dailyWeather = dailyWeather {
            return dailyWeather.hourly.count
        }
        return 0
    }
    
    //MARK: - collection cells configure
    func dailyConfigureCell (cell: DailyCollectionViewCell, indexPath: IndexPath) -> DailyCollectionViewCell {
        cell.configure(daily: dailyWeather!.daily[indexPath.row], indexPath: indexPath.row)
        cell.dailyDate.text = Utils.dateFormater(date: (dailyWeather!.daily[indexPath.row].dt), dateFormat: "E d MMM", timezone: weather?.timezone ?? 0)
        return cell
    }
    
    
    func hourlyConfigureCell (cell: HourlyCollectionViewCell, indexPath: IndexPath) -> HourlyCollectionViewCell {
        cell.configure(hourly: dailyWeather!.hourly[indexPath.row], indexPath: indexPath.row)
        cell.hourlyTime.text = Utils.dateFormater(date: (dailyWeather!.hourly[indexPath.row].dt), dateFormat: "HH:mm", timezone: weather?.timezone ?? 0)
        return cell
    }
}
