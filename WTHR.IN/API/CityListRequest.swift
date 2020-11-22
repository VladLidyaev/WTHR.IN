//
//  CityListRequest.swift
//  WTHR.IN
//
//  Created by Vlad on 20.11.2020.
//

import Foundation

enum CityListError: Error {
    case NoDataAvailable
    case CanNotProcessData
}

struct CityListRequest {            // Get List of Cities ( > 20.000)
    
    let resourceURL : URL
    
    init(){
        let resourceString = "https://raw.githubusercontent.com/VladLidyaev/CitiesList/main/CITIES.json"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func getCityList (completion: @escaping(Result<[CityList], CityListError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            do{
                let decoder = JSONDecoder()
                let CityListAns = try decoder.decode([CityList].self, from: jsonData)
                completion(.success(CityListAns))
            } catch {
                completion(.failure(.CanNotProcessData))
            }
        }
        dataTask.resume()
    }
}
