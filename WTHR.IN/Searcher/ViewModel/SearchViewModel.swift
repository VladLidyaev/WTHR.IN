//
//  SearchViewModel.swift
//  WTHR.IN
//
//  Created by Vlad on 19.11.2020.
//

import Foundation
import RxSwift
import RxCocoa
import Concurrency

class SearchViewModel {
    
    var searchText = BehaviorRelay(value: "")
    
    var dataCache : [SearchCityModel]           // Interpretation of Cache
    var currentcitieslist : [SearchCityModel]
    var showdata : BehaviorRelay<[SearchCityModel]>
    
    var visiblecellsindexpath : BehaviorRelay<Int>
    let DBag = DisposeBag()
    var status : BehaviorRelay<String>
    
    init(){
        
        self.status = BehaviorRelay<String>(value: "OK")
        if Reachability.isConnectedToNetwork(){
            self.status.accept("OK")
        }else{
            self.status.accept("ConnetionError")
        }
        
        let initLatch = CountDownLatch(count: 11)           // Label for waiting answer
        
        self.dataCache = [SearchCityModel]()
        self.currentcitieslist = [SearchCityModel]()
        self.showdata = BehaviorRelay<[SearchCityModel]>(value: [])
        self.visiblecellsindexpath = BehaviorRelay<Int>(value: Int())
        
        CityListRequest().getCityList { result in       // Get all cities List
            switch result{
            case .failure( _):
                self.status.accept("ServicesError")
            case .success(let list):
                list.forEach { (city) in
                    if self.testOnASCII(data: city.name){
                        self.dataCache.append(SearchCityModel(name: city.name, country: city.country, temperature: "...", icinname: "03.d", id: city.id, isDownload: false))
                        self.currentcitieslist = self.dataCache
                    }
                }
                self.showdata.accept(self.GetShowdata(ArrayIn: self.currentcitieslist, lbl: initLatch, from: 0, to: 10))
            }
        }
        initLatch.await()
        self.showdata.accept(currentcitieslist)
        
        visiblecellsindexpath           // Download to Cache for neighboring cells to the cell being viewed
            .asObservable()
            .distinctUntilChanged()
            .throttle(3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (positionindex) in
                DispatchQueue.global(qos: .background).async {
                    if positionindex > 10{
                        let Latch = CountDownLatch(count: 20)
                        self.showdata.accept(self.GetShowdata(ArrayIn: self.currentcitieslist, lbl: Latch, from: positionindex-9, to: positionindex+10))
                        Latch.await()
                    } else {
                        let Latch = CountDownLatch(count: 20)
                        self.showdata.accept(self.GetShowdata(ArrayIn: self.currentcitieslist, lbl: Latch, from: 0, to: 19))
                        Latch.await()
                    }
                    DispatchQueue.main.async {}}
            }).disposed(by: DBag)
        
        self.searchText         // Dynamic search
            .asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { search in
                self.currentcitieslist = self.letsearch(self.dataCache, search)
                DispatchQueue.global(qos: .background).async {
                    let Latch = CountDownLatch(count: 11)
                    self.showdata.accept(self.GetShowdata(ArrayIn: self.currentcitieslist, lbl: Latch, from: 0, to: 10))
                    Latch.await()
                    DispatchQueue.main.async {}
                }
            })
            .disposed(by: DBag)
    }
    
    // func get data for cell by identifier in currently cities list
    
    func GetShowdata(ArrayIn: [SearchCityModel],lbl: CountDownLatch, from: Int, to: Int) -> [SearchCityModel] {
        var Array = ArrayIn
        let count = Array.count
        if count != 0{
            if to >= count{
                for i in (from...(count-1)){
                    let res = conteinsStruct(data: self.dataCache, list: Array[i])
                    if res.1 {
                        Array[i] = self.dataCache[res.0]
                    } else {
                        DetailInfoRequest(id: String(Array[i].id)).getWeatherById{ result in
                            switch result{
                            case .failure(_):
                                self.status.accept("ServicesError")
                            case .success(let list): do {
                                Array[i] = SearchCityModel(name: list.name, country: Array[i].country, temperature: self.getTemperature(value: list.main.temp), icinname: list.weather[0].icon, id: Array[i].id, isDownload: true)
                                self.dataCache[res.0] = Array[i]
                                lbl.countDown()
                            }
                            }
                        }
                    }
                }
            } else {
                for i in (from...to){
                    let res = conteinsStruct(data: self.dataCache, list: Array[i])
                    if res.1 {
                        Array[i] = self.dataCache[res.0]
                    } else {
                        DetailInfoRequest(id: String(Array[i].id)).getWeatherById{ result in
                            switch result{
                            case .failure(_):
                                self.status.accept("ServicesError")
                            case .success(let list): do {
                                Array[i] = SearchCityModel(name: list.name, country: Array[i].country, temperature: self.getTemperature(value: list.main.temp), icinname: list.weather[0].icon, id: Array[i].id, isDownload: true)
                                self.dataCache[res.0] = Array[i]
                                lbl.countDown()
                            }
                            }
                        }
                    }
                }
            }
        }
        return Array
    }
    
    // func returned info about including element in Cache
    
    private func conteinsStruct(data: [SearchCityModel], list: SearchCityModel) -> (Int,Bool) {
        var index = 0
        var ans = false
        for i in (0...(data.count-1)){
            if (data[i].id == list.id){
                index = i
                if (data[i].isDownload == true) {
                    ans = true
                }
            }
        }
        return (index,ans)
    }
    
    // Temperature reforming
    
    private func getTemperature(value: Double) -> String{
        let temp = Int(value - 273)
        if temp >= 0{
            return "+\(temp)"
        } else { return "\(temp)"}
    }
    
    // Search in all data ( all cities List + Cache)
    
    private func letsearch (_ list: [SearchCityModel], _ str: String) -> ([SearchCityModel]){
        var returnlist = [SearchCityModel]()
        if list.count > 0 {
            if str.count > 0{
                for i in (0...(list.count)-1){
                    if list[i].name.contains(str){
                        returnlist.append(list[i])
                    }
                }
            } else { returnlist = list }
        }
        return returnlist
    }
    
    // function in order to avoid mistakes with the coding
    
    private func testOnASCII (data: String) -> Bool {
        var error = false
        data.forEach { (simbol) in
            if !simbol.isASCII {
                error = true
            }
        }
        return !error
    }
}
