//
//  WeatherByCityRequest.swift
//  WTHR.IN
//
//  Created by Vlad on 21.11.2020.
//

import Foundation

enum DetailInfoError: Error {
    case NoDataAvailable
    case CanNotProcessData
}

struct DetailInfoRequest {          // Get Info by City ID
    
    let resourceURL : URL
    
    init(id: String){
        let resourceString = "https://api.openweathermap.org/data/2.5/weather?id=\(id)&appid=27a2032694c81983b3de00a0c2a981b5"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func getWeatherById (completion: @escaping(Result<CityWeatherDecodable, DetailInfoError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            do{
                let decoder = JSONDecoder()
                let WetherAns = try decoder.decode(CityWeatherDecodable.self, from: jsonData)
                completion(.success(WetherAns))
            } catch {
                completion(.failure(.CanNotProcessData))
            }
        }
        dataTask.resume()
    }
}
