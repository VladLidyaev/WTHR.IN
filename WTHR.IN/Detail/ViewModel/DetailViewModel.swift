//
//  DetailViewModel.swift
//  WTHR.IN
//
//  Created by Vlad on 22.11.2020.
//

import Foundation
import Concurrency
import RxCocoa
import RxSwift

class DetailViewModel {
    
    var date : String
    var cityName : String
    var feelLikeTemp : String
    var temp : String
    var icon : String
    var Info : String
    var InfoArray : [(String,String)]
    
    let dates = Date()
    let dateFormatter = DateFormatter()
    
    init(id: String) {
        
        self.cityName = "NONE"
        self.feelLikeTemp = "..."
        self.temp = "..."
        self.icon = ""
        self.date = "NONE"
        self.InfoArray = [(String,String)]()
        self.Info = "NONE"
        
        let initLatch = CountDownLatch(count: 1)            // Label for waiting answer from API
        
        DetailInfoRequest(id: id).getWeatherById{ result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let list):
                self.InfoArray = getDict(data: list)
                self.Info = InfoToString(list: self.InfoArray)
                self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.date = self.dateFormatter.string(from: self.dates)
                self.cityName = list.name
                self.feelLikeTemp = getTemperature(value: list.main.feels_like)
                self.temp = getTemperature(value: list.main.temp)
                self.icon = list.weather[0].icon
                initLatch.countDown()
            }
        }
        initLatch.await()
    }
    
}

private func InfoToString(list: [(String,String)]) -> String{       // Array of City Info to string for Label
    var ans = String()
    for i in (0...(list.count-1)){
        ans += (list[i].0 + "  " + list[i].1 + "\n")
    }
    return ans
}

private func getDict(data: CityWeatherDecodable) -> [(String,String)] {         // Get City info with titles
    var res = [(String,String)]()
    let a = CityInfo()
    res.append((a.coordlat,String(data.coord.lat)))
    res.append((a.coordlon,String(data.coord.lon)))
    res.append((a.temp,getTemperature(value: data.main.temp)))
    res.append((a.tempfeel,getTemperature(value: data.main.feels_like)))
    res.append((a.timezone,String(data.timezone)))
    res.append((a.weatherdescription,String(data.weather[0].description)))
    res.append((a.weathermain,String(data.weather[0].main)))
    res.append((a.windspeed,String(data.wind.speed)))
    return res
}

private func getTemperature(value: Double) -> String{           // Convert temperature
    let temp = Int(value - 273)
    if temp >= 0{
        return "+\(temp)"
    } else { return "\(temp)"}
}
