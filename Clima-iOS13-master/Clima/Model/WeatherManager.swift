//
//  WeatherManager.swift
//  Clima
//
//  Created by Muhammd Rafa Al bani on 11/23/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherMeneger: WeatherManager, weather: WeatherModel)
    func didFailWihtError(error: Error)
}
struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=eb173fca8ef1cd098c59c94f6c349016&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    //Networking
    func performRequest(urlString: String){
        //1.Create URL
        if let url = URL(string: urlString){
            //2.Create URL Session
            let session = URLSession(configuration: .default)
            //3.give the session a task
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                
                if error != nil{
                    self.delegate?.didFailWihtError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(weatherMeneger: self, weather: weather)
                    }
                }
            }
            //4.start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(condition: id, name: name, temperature: temp)
            return weather
            
            
        }catch{
            delegate?.didFailWihtError(error: error)
            return nil
        }
    }
}
