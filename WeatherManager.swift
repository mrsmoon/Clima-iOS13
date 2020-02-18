//
//  WeatherManager.swift
//  Clima
//
//  Created by Sera on 2/17/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=4c420360916f233137a351ca21b990e5&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityname: String) {
        let urlString = "\(weatherURL)&q=\(cityname)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //1. create a URL
        if let url = URL(string: urlString) {
        //2. create a url session
            let session = URLSession(configuration: .default)
        //3. give the session a task
            //let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            // for completion handler, using closure instead of func handle
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safedata = data {
                    if let weather = self.parseJSON(safedata) {
                        self.delegate?.didUpdateWeather(weather)
                    }
                }
            }
            //4. start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            //let conditionName = weather.conditionName
            return weather
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
   
    /* func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }
        if let safedata = data {
            let dataString = String(data: safedata, encoding: .utf8)
            print(dataString)
        }
    }*/
}

