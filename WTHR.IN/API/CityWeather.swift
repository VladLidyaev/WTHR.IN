//
//  CityWeatherDecodable.swift
//  WTHR.IN
//
//  Created by Vlad on 20.11.2020.
//

import Foundation

struct coord : Decodable {
    let lon: Double
    let lat: Double
}

struct weather : Decodable {
    let id: Double
    let main: String
    let description: String
    let icon: String
}

struct main : Decodable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Double
}

struct wind : Decodable {
    let speed: Double
    let deg: Double
}

struct clouds : Decodable {
    let all: Double
}

struct CityWeatherDecodable : Decodable {          // Struct for decodable City Info
    let coord: coord
    let weather: [weather]
    let base: String
    let main: main
    let visibility: Double
    let wind: wind
    let clouds: clouds
    let dt: Double
    let timezone: Double
    let id: Double
    let name: String
    let cod: Double
}
