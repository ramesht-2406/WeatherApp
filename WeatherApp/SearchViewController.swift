//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import UIKit

class SearchViewController: UIViewController {

    // We keep track of the pending work item as a property
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let weatherViewModel = WeatherViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(UINib.init(nibName:CityTableViewCell.nibName,bundle: nil), forCellReuseIdentifier: CityTableViewCell.identifier)
        
        self.tableView.register(UINib.init(nibName:SelfLocationTableViewCell.nibName,bundle: nil), forCellReuseIdentifier: SelfLocationTableViewCell.identifier)
        
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = 800
        self.viewModelHandlers()
    }

    func viewModelHandlers() {
        weatherViewModel.tabelViewReloadData = { [weak self] in
            //For weak self handle nil condition as we may expect nil sometimes
            guard let self = self else {
                return
            }
            //Loading Tableview on Main Theard to avoid retain cyclces
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
        weatherViewModel.latlongFetchedfromUserLocation = { [weak self] coordCity in
            guard let self = self else {
                return
            }
            NotificationCenter.default.post(name: Notification.Name(CITY_IDENTIFIER), object: coordCity)
            //Navigate back on Main Theard to avoid retain cyclces
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - Search Bar
    //Setting up searchbar for searching City
    func searchBarView() {
        self.searchBar.cancelButtonColor     = .gray
        self.searchBar.searchIconColor       = .gray
        self.searchBar.placeholderColor      = .gray
        self.searchBar.textColor             = UIColor.black
        self.searchBar.capabilityButtonColor = .gray
        self.searchBar.searchTextField.backgroundColor = .white
        self.definesPresentationContext = true
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = false
        self.searchBar.backgroundColor = .clear
    }
}

extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Cancel the currently pending item
        pendingRequestWorkItem?.cancel()
        
        var checkEmptyStr = ""
        var searchTxt = ""
        
        checkEmptyStr = (self.searchBar.text?.replacingOccurrences(of: "", with: ""))!
        searchTxt = self.searchBar.text!
        
        if checkEmptyStr.isEmpty {
            return
        }
        
        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem { [weak self] in
            //Checking
            guard let self = self else {
                return
            }
            self.filterDataBasedOnSearchKey(searchKey: searchTxt)
        }
        
        // Save the new work item and execute it after 250 ms
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10),
                                      execute: requestWorkItem)
        
    }
    
    // Filter based on search
    func filterDataBasedOnSearchKey(searchKey: String) {
        if searchKey != "" {
            weatherViewModel.getCityNamesbySearch(searchKey)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        let checkEmptyStr = (self.searchBar.text?.replacingOccurrences(of: "", with: ""))!
        if checkEmptyStr.isEmpty {
            if searchText == "" {
                searchBar.resignFirstResponder()
                searchBar.showsCancelButton = false
            } else {
                return
            }
        }
        self.filterDataBasedOnSearchKey(searchKey: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        if searchBar.text != nil || !searchBar.text!.isEmpty{
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
        }
        self.filterDataBasedOnSearchKey(searchKey: searchBar.text ?? "")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Returning number of cities from View Model class
        return weatherViewModel.numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if weatherViewModel.filteredCityIsEmpty() {
            guard let locationCell = tableView.dequeueReusableCell(withIdentifier: SelfLocationTableViewCell.identifier, for: indexPath) as? SelfLocationTableViewCell else { return UITableViewCell() }
            locationCell.configure()
            return locationCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier, for: indexPath) as! CityTableViewCell
        //Getting model class object for indexpath from View Model
        let modelClass = weatherViewModel.cellForRow(indexPath: indexPath)
        cell.lbl_CityName.text = "\(modelClass.name ?? ""), \(modelClass.state ?? ""), \(modelClass.country ?? "")"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*Once City is Selected hide the tableview and
         make a call to get weather deatils from API
         Also resign the textfiled keyboard */
        if weatherViewModel.filteredCityIsEmpty() {
            weatherViewModel.fetchUserLocation()
            return
        }
        tableView.isHidden = true
        searchBar.searchTextField.text = ""
        searchBar.searchTextField.resignFirstResponder()
        let modelClass = weatherViewModel.cellForRow(indexPath: indexPath)
        //Setting in Userdefaults the last city searched
        let coordModel = CoordCity(lat: modelClass.lat, long: modelClass.lon)
        NotificationCenter.default.post(name: Notification.Name(CITY_IDENTIFIER), object: coordModel)
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
