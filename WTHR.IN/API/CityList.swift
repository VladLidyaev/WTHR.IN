//
//  CityListDecodable.swift
//  WTHR.IN
//
//  Created by Vlad on 20.11.2020.
//

import Foundation           //Struct for decodable List of Cities

struct CityList : Decodable {
    let name: String
    let id: Int
    let country: String
}
