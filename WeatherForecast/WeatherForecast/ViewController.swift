//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class ViewController: UIViewController {
    private var weatherDataManager: WeatherDataManagerDelegate?
    private var weatherJSON: WeatherJSON?
    private let imageCache: NSCache<NSString, UIImage> = NSCache()
    
    private var tempUnit: TempUnit = .metric
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.weatherDataManager = WeatherDataManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = MainView(delegate: self,
                        tableViewDelegate: self,
                        tableViewDataSource: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
}

extension ViewController {
    @objc private func changeTempUnit() {
        switch tempUnit {
        case .imperial:
            tempUnit = .metric
            navigationItem.rightBarButtonItem?.title = "섭씨"
        case .metric:
            tempUnit = .imperial
            navigationItem.rightBarButtonItem?.title = "화씨"
        }
        refresh()
    }
    
    @objc private func refresh() {
        weatherDataManager?.fetchWeatherData(completion: {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    self?.weatherJSON = info
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }
    
    private func updateUI() {
        navigationItem.title = weatherJSON?.city.name
        (view as? MainView)?.refreshEnd()
    }
    
    private func initialSetUp() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "화씨", image: nil, target: self, action: #selector(changeTempUnit))
    }
}

// MARK: - MainViewDelegate
extension ViewController: MainViewDelegate {
    func refreshTableView() {
        refresh()
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherJSON?.weatherForecast.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        
        guard let cell: WeatherTableViewCell = cell as? WeatherTableViewCell,
              let weatherForecastInfo = weatherJSON?.weatherForecast[indexPath.row]
        else {
            return cell
        }
        
        cell.configure(with: weatherForecastInfo,
                       tempUnit: tempUnit,
                       imageCache: imageCache)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let weatherDetailInfo: WeatherDetailInfo = .init(
            weatherForecastInfo: weatherJSON?.weatherForecast[indexPath.row],
            cityInfo: weatherJSON?.city,
            tempUnit: tempUnit)
        
        showDetailViewController(with: weatherDetailInfo)
    }
    
    private func showDetailViewController(with weatherDetailInfo: WeatherDetailInfo?) {
        let detailViewController: WeatherDetailViewController = .init(weatherDetailInfo: weatherDetailInfo)
        navigationController?.show(detailViewController, sender: self)
    }
}
