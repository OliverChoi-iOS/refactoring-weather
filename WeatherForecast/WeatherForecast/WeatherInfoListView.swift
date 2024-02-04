//
//  WeatherInfoListView.swift
//  WeatherForecast
//
//  Created by kodirbek on 1/31/24.
//

import UIKit

protocol WeatherInfoListViewProtocol: AnyObject {
    func fetchCityName(_ cityName: String)
    func fetchWeatherDetailVC(_ detailVC: WeatherDetailVC)
}

final class WeatherInfoListView: UIView {

    // MARK: - Properties
    private var fetchDataManager: FetchDataManagerProtocol
    private var weatherData: WeatherData?
    private var tempUnit: TemperatureUnit = .metric
    private var tableView: UITableView!
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    weak var delegate: WeatherInfoListViewProtocol?
    
    var imageManager: ImageManagerProtocol
    
    // MARK: - Init
    init(delegate: WeatherInfoListViewProtocol, fetchDataManager: FetchDataManagerProtocol, imageManager: ImageManagerProtocol) {
        self.delegate = delegate
        self.fetchDataManager = fetchDataManager
        self.imageManager = imageManager
        super.init(frame: .zero)
        layoutTableView()
        setUpTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupUI
    private func layoutTableView() {
        let safeArea: UILayoutGuide = safeAreaLayoutGuide
        tableView = .init(frame: .zero, style: .plain)
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    private func setUpTableView() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: WeatherTableViewCell.cellId)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Methods
    func changeTempUnit(to tempUnit: TemperatureUnit) {
        self.tempUnit = tempUnit
    }
    
    @objc func refresh() {
        fetchDataManager.fetchWeatherData { [weak self] weatherData in
            if let data = weatherData {
                self?.weatherData = data
                self?.tableView.reloadData()
                self?.delegate?.fetchCityName(data.city.name)
            } else {
                print("Fetching weather data failed! Try refreshing again.")
            }
        }
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableViewDataSource method
extension WeatherInfoListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherData?.weatherForecast.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        
        guard let cell: WeatherTableViewCell = cell as? WeatherTableViewCell,
              let weatherForecastInfo = weatherData?.weatherForecast[indexPath.row] else {
            return cell
        }
        
        DispatchQueue.main.async {
            cell.updateCellUI(with: weatherForecastInfo, tempUnit: self.tempUnit, imageManager: self.imageManager)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate method
extension WeatherInfoListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let weatherData = weatherData else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailViewController: WeatherDetailVC = WeatherDetailVC(weatherForecastInfo: weatherData.weatherForecast[indexPath.row],
                                                                    cityInfo: weatherData.city,
                                                                    tempUnit: tempUnit)
        
        delegate?.fetchWeatherDetailVC(detailViewController)
    }
}
