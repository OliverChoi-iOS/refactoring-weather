//
//  WeatherForecast - WeatherTableViewCell.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class WeatherTableViewCell: UITableViewCell {
    
    private var weatherIcon: UIImageView!
    private var dateLabel: UILabel!
    private var temperatureLabel: UILabel!
    private var weatherLabel: UILabel!
    private var dashLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    private var imageTask: Task<Void, Never>?
     
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        setUpLayout()
        reset()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func setUpViews() {
        weatherIcon = UIImageView()
        dateLabel = UILabel()
        temperatureLabel = UILabel()
        weatherLabel = UILabel()
        dashLabel = UILabel()
        descriptionLabel = UILabel()
        
        let labels: [UILabel] = [dateLabel, temperatureLabel, weatherLabel, dashLabel, descriptionLabel]
        
        labels.forEach { label in
            label.textColor = .black
            label.font = .preferredFont(forTextStyle: .body)
            label.numberOfLines = 1
        }
    }
    
    private func setUpLayout() {
        
        let weatherStackView: UIStackView = UIStackView(arrangedSubviews: [
            weatherLabel,
            dashLabel,
            descriptionLabel
        ])
        
        descriptionLabel.setContentHuggingPriority(.defaultLow,
                                                   for: .horizontal)
        
        weatherStackView.axis = .horizontal
        weatherStackView.spacing = 8
        weatherStackView.alignment = .center
        weatherStackView.distribution = .fill
        
        
        let verticalStackView: UIStackView = UIStackView(arrangedSubviews: [
            dateLabel,
            temperatureLabel,
            weatherStackView
        ])
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .leading
        
        let contentsStackView: UIStackView = UIStackView(arrangedSubviews: [
            weatherIcon,
            verticalStackView
        ])
               
        contentsStackView.axis = .horizontal
        contentsStackView.spacing = 16
        contentsStackView.alignment = .center
        contentsStackView.distribution = .fill
        contentsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(contentsStackView)
                 
        NSLayoutConstraint.activate([
            contentsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            weatherIcon.widthAnchor.constraint(equalTo: weatherIcon.heightAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}

extension WeatherTableViewCell {
    private func reset() {
        weatherIcon.image = UIImage(systemName: "arrow.down.circle.dotted")
        dateLabel.text = "0000-00-00 00:00:00"
        temperatureLabel.text = "00℃"
        weatherLabel.text = "~~~"
        descriptionLabel.text = "~~~~~"
        imageTask?.cancel()
    }
    
    public func setData(weatherForecastInfo: WeatherForecastInfo, tempUnit: TempUnit) {
        self.weatherLabel.text = weatherForecastInfo.weather.main
        self.descriptionLabel.text = weatherForecastInfo.weather.description
        
        let temp = weatherForecastInfo.main.temp
        let convertedTemp = tempUnit.convertedValue(temp: temp)
        self.temperatureLabel.text = "\(String(format: "%.1f", convertedTemp))\(tempUnit.expression)"
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd(EEEEE) a HH:mm"
        
        let date: Date = Date(timeIntervalSince1970: weatherForecastInfo.dt)
        self.dateLabel.text = dateFormatter.string(from: date)
    }
    
    public func setImage(urlString: String) {
        self.imageTask = Task {
            await ImageLoader.shared.performImageLoad(urlString: urlString) { [weak self] image in
                DispatchQueue.main.async {
                    self?.weatherIcon.image = image
                }
            }
        }
    }
}
