//
//  WeatherViewController.swift
//  Weather App
//
//  Created by Alejandrina Patron on 11/1/16.
//  Copyright © 2016 Georgia Tech iOS Club. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherLocation: UILabel!
    @IBOutlet weak var weatherIcon: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = String(format: "%.2f", location.coordinate.latitude)
            let longitude = String(format: "%.2f", location.coordinate.longitude)
            reverseGeocoding(location: location)
            getWeather(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showLocationErrorAlert()
    }
    
    // MARK: - Helper
    
    
    /// Gets weather of current location and updates UI
    ///
    /// - Parameters:
    ///     - latitude: location's latitude coordinate
    ///     - longitude: location's longitude coordinate
    func getWeather(latitude: String, longitude: String) {
        DarkSkyService.weatherForCoordinates(latitude: latitude, longitude: longitude, completion: { data, error in
            if let _ = error {
                self.showErrorAlert()
            } else if let weather = data {
                self.weatherIcon.text = weather.icon.getEmoji()
                self.temperature.text = weather.temperature
                self.weatherDescription.text = weather.description
            }
        })
    }
    
    /// Gets city name of given location and updates UI
    ///
    /// - Parameters:
    ///     - location: location to be reverse geocoded
    func reverseGeocoding(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if let _ = error {
                self.weatherLocation.text = ""
                return
            } else if let placemarks = placemarks {
                let pm = placemarks[0]
                let locality = pm.locality ?? ""
                self.weatherLocation.text = locality
            }
        })
    }
    
    // MARK: - IBAction

    /// Requests user's location and updates UI
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        locationManager.requestLocation()
    }
    
    // MARK: - Alerts
    
    /// Shows error alert when something goes wron with a network request
    func showErrorAlert() {
        let alert = UIAlertController(title: "Oops!", message: "Something went wrong, please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Shows error alert when a user's location could not be determined
    func showLocationErrorAlert() {
        let alert = UIAlertController(title: "Oops!", message: "I could not determine your location.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension String {
    
    /// Get a forecast icon's corresponding emoji
    func getEmoji() -> String {
        switch self {
        case "clear-day":
            return "☀️"
        case "clear-night":
            return "🌙"
        case "rain":
            return "☔️"
        case "snow":
            return "❄️"
        case "sleet":
            return "🌨"
        case "wind":
            return "🌬"
        case "fog":
            return "🌫"
        case "cloudy":
            return "☁️"
        case "partly-cloudy-day":
            return "🌤"
        case "partly-cloudy-night":
            return "🌥"
        default:
            return "❓"
        }
    }
}
