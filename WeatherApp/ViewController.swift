//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import UIKit
import SDWebImage
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var imgViewBackGround: UIImageView!
    @IBOutlet weak var vw_Base: UIView! {
        didSet {
            vw_Base.isHidden = true
        }
    }
    
    @IBOutlet weak var imgView_Icon: UIImageView!
    @IBOutlet weak var lbl_CityName: UILabel!
    @IBOutlet weak var lbl_Temp: UILabel!
    @IBOutlet weak var lbl_Main: UILabel!
    @IBOutlet weak var lbl_MaxTemp: UILabel!
    @IBOutlet weak var lbl_MinTemp: UILabel!
    @IBOutlet weak var lbl_SunriseAgo: UILabel!
    @IBOutlet weak var lbl_SunsetIn: UILabel!
    @IBOutlet weak var lbl_SunriseTime: UILabel!
    @IBOutlet weak var lbl_SunsetTime: UILabel!
    @IBOutlet weak var lbl_Humidity: UILabel!
    @IBOutlet weak var lbl_Pressure: UILabel!
    @IBOutlet weak var lbl_FeelsLike: UILabel!
    @IBOutlet weak var lbl_Visibility: UILabel!
    
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    
    //created an instance on ViewModel
    private let weatherViewModel = WeatherViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(callWeatherAPIwithLatLong), name: Notification.Name(CITY_IDENTIFIER), object: nil)
        
        //Check wheather Last City Searched is there or not,
        //here i have used "if let" conditional operator to check userdefaults has a value or not
        if let lastCitySearched = Utils.retriveDatafromUserDefaults() {
        //if there call API to get weather details of last city searched
            weatherViewModel.getWeatherDetailsbyLatLong("\(lastCitySearched.lat ?? 0)", long: "\(lastCitySearched.long ?? 0)")
            weatherViewModel.getDailyWeather("\(lastCitySearched.lat ?? 0)", long: "\(lastCitySearched.long ?? 0)")
        }
        
        //ViewMode Handlers
        self.viewModelHandlers()
        
    }
    
    
    @objc func callWeatherAPIwithLatLong(_ notification: Notification) {
        let model = notification.object
        if let coordCity = model as? CoordCity {
            Utils.saveDataintoUserDefaults(coordCity)
            weatherViewModel.getWeatherDetailsbyLatLong("\(coordCity.lat ?? 0)", long: "\(coordCity.long ?? 0)")
            weatherViewModel.getDailyWeather("\(coordCity.lat ?? 0)", long: "\(coordCity.long ?? 0)")
        }
    }
    
    func viewModelHandlers() {
        //View Model handlers as I have implemented closures in order to bind data from View Model to View
        weatherViewModel.setDataintoFields = { [weak self] in
            //For weak self handle nil condition as we may expect nil sometimes
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                //Setting Data into UI
                self.setDataFieldsintoUI()
            }
        }
        
        weatherViewModel.showAlertMessage = { [weak self] (message) in
            //For weak self handle nil condition as we may expect nil sometimes
            //Here in closure we are expecting a message
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                Utils.showAlert(vc: self, message: message)
            }
        }
        
        weatherViewModel.getDailyWeatherDetails = { [weak self] in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                //Setting Data into UI
                self.hourlyCollectionView.reloadData()
                self.dailyCollectionView.reloadData()
            }
        }
    }
    
    func setDataFieldsintoUI() {
        //Loading Model class fields into UI fields
        self.vw_Base.isHidden = false
        
        self.weatherViewModel.cityName.bind { [weak self] cityName in
            self?.lbl_CityName.text = cityName
        }
        
        self.weatherViewModel.currentTemperature.bind { [weak self] currentTemperature in
            self?.lbl_Temp.text = currentTemperature
        }
        
        self.weatherViewModel.currentDescription.bind { [weak self] description in
            self?.lbl_Main.text = description
        }
        
        self.weatherViewModel.currentMinWeather.bind { [weak self] currentMinWeather in
            self?.lbl_MinTemp.text = currentMinWeather
        }
        
        self.weatherViewModel.currentMaxWeather.bind { [weak self] currentMaxWeather in
            self?.lbl_MaxTemp.text = currentMaxWeather
        }
        
        self.weatherViewModel.currentSunriseAgo.bind { [weak self] currentSunriseAgo in
            self?.lbl_SunriseAgo.text = currentSunriseAgo
        }
        
        self.weatherViewModel.currentSunsetIn.bind { [weak self] currentSunsetIn in
            self?.lbl_SunsetIn.text = currentSunsetIn
        }
        
        self.weatherViewModel.currentSunriseTime.bind { [weak self] currentSunriseTime in
            self?.lbl_SunriseTime.text = currentSunriseTime
        }
        
        self.weatherViewModel.currentSunsetTime.bind { [weak self] currentSunsetTime in
            self?.lbl_SunsetTime.text = currentSunsetTime
        }
        
        self.weatherViewModel.currentHumidity.bind { [weak self] currentHumidity in
            self?.lbl_Humidity.text = currentHumidity
        }
        
        self.weatherViewModel.currentPressure.bind { [weak self] currentPressure in
            self?.lbl_Pressure.text = currentPressure
        }
        
        self.weatherViewModel.currentFeelsLikeWeather.bind { [weak self] currentFeelsLikeWeather in
            self?.lbl_FeelsLike.text = currentFeelsLikeWeather
        }
        
        self.weatherViewModel.currentVisibility.bind { [weak self] currentVisibility in
            self?.lbl_Visibility.text = currentVisibility
        }
        
        self.weatherViewModel.currentImageWeather.bind { [weak self] currentImageWeather in
            self?.imgView_Icon.sd_setImage(with: URL(string: currentImageWeather ?? ""), placeholderImage: UIImage(named: "default"))
        }
        
        self.weatherViewModel.backgroundImageView.bind { [weak self] backgroundImageView in
            self?.imgViewBackGround.image = backgroundImageView
        }

        self.actualWeatherAnimate()
        self.backgroundImageAnimate()
    }
    
    private func backgroundImageAnimate() {
        self.imgViewBackGround.frame.origin.x = 0
        UIView.animate(withDuration: 10, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.imgViewBackGround.frame.origin.x -= 100
        }, completion: nil)
    }
    
    private func actualWeatherAnimate() {
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.imgView_Icon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: nil)
        
    }
}

//collection View
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dailyCollectionView {
            return weatherViewModel.numberOfDailyCells
        } else {
            return weatherViewModel.numberOfHourlyCells
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == hourlyCollectionView {
            guard let hourlyCell = hourlyCollectionView.dequeueReusableCell(withReuseIdentifier: HourlyCollectionViewCell.identifier, for: indexPath) as? HourlyCollectionViewCell
            else { return UICollectionViewCell()}
            return weatherViewModel.hourlyConfigureCell(cell: hourlyCell, indexPath: indexPath)
        } else {
            guard let dailyCell = dailyCollectionView.dequeueReusableCell(withReuseIdentifier: DailyCollectionViewCell.identifier, for: indexPath) as? DailyCollectionViewCell
            else { return UICollectionViewCell ()}
            return weatherViewModel.dailyConfigureCell(cell: dailyCell, indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == dailyCollectionView {
            return CGSize(width: 128, height: 50)
        } else {
            return CGSize(width: 70, height: 100)
        }
    }
    
}


