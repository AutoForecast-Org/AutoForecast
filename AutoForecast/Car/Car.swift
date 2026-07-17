//
//  Car.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct Car: Codable, Identifiable {
    var id: Int?
    let brand: String
    let model: String
    let year: Int
    let fuel: String
    let engine: String
    let version: String?
    let category: String?
    let price: Int?
}

//public struct Car: Codable, Identifiable {
//    public var id = UUID()
//    public var brand: String
//    public var model: String
//    public var engine: String
//    public var version: String
//    public var registrationYears: [Int]
//}

//public let carsDataset: [Car] = [
//    // MARK: Renault
//    Car(brand: "Renault", model: "Clio", engine: "1.5 dCi 90 CV", version: "Zen", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Clio", engine: "1.0 TCe 100 CV", version: "Intens", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Clio", engine: "1.3 TCe 130 CV", version: "RS Line", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Renault", model: "Captur", engine: "1.5 dCi 95 CV", version: "Intens", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Captur", engine: "1.3 TCe 140 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Captur", engine: "E-Tech Hybrid 145 CV", version: "E-Tech", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Renault", model: "Megane", engine: "1.5 Blue dCi 115 CV", version: "Sporter", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Megane", engine: "1.3 TCe 140 CV", version: "Intens", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Megane", engine: "RS 300 CV", version: "RS", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Renault", model: "Scenic", engine: "1.6 dCi 130 CV", version: "Bose", registrationYears: Array(2000...2024)),
//    Car(brand: "Renault", model: "Scenic", engine: "1.3 TCe 140 CV", version: "Intens", registrationYears: Array(2000...2024)),
//
//    // MARK: Volkswagen
//    Car(brand: "Volkswagen", model: "Golf", engine: "1.0 TSI 110 CV", version: "Life", registrationYears: Array(2000...2024)),
//    Car(brand: "Volkswagen", model: "Golf", engine: "2.0 TDI 150 CV", version: "Style", registrationYears: Array(2000...2024)),
//    Car(brand: "Volkswagen", model: "Golf", engine: "GTI 245 CV", version: "GTI", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Volkswagen", model: "Polo", engine: "1.0 MPI 80 CV", version: "Trendline", registrationYears: Array(2000...2024)),
//    Car(brand: "Volkswagen", model: "Polo", engine: "1.0 TSI 95 CV", version: "Comfortline", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Volkswagen", model: "Tiguan", engine: "2.0 TDI 150 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Volkswagen", model: "Tiguan", engine: "1.5 TSI 130 CV", version: "Life", registrationYears: Array(2000...2024)),
//    Car(brand: "Volkswagen", model: "Tiguan", engine: "R 320 CV", version: "R", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Volkswagen", model: "Passat", engine: "2.0 TDI 150 CV DSG", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Volkswagen", model: "Passat", engine: "1.5 TSI 150 CV", version: "Elegance", registrationYears: Array(2000...2024)),
//
//    // MARK: BMW
//    Car(brand: "BMW", model: "1 Series", engine: "118i 136 CV", version: "Advantage", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "1 Series", engine: "120d 190 CV", version: "Sport", registrationYears: Array(2000...2024)),
//
//    Car(brand: "BMW", model: "3 Series", engine: "318d 150 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "3 Series", engine: "320i 184 CV", version: "M Sport", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "3 Series", engine: "330e", version: "Plug-in Hybrid", registrationYears: Array(2000...2024)),
//
//    Car(brand: "BMW", model: "X1", engine: "sDrive18i 136 CV", version: "Advantage", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "X1", engine: "xDrive20d 190 CV", version: "Sport", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "X1", engine: "xDrive25e", version: "Plug-in Hybrid", registrationYears: Array(2000...2024)),
//
//    Car(brand: "BMW", model: "X3", engine: "xDrive20i 184 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "X3", engine: "xDrive30d 286 CV", version: "Luxury", registrationYears: Array(2000...2024)),
//
//    Car(brand: "BMW", model: "X5", engine: "xDrive30d 286 CV", version: "M Sport", registrationYears: Array(2000...2024)),
//    Car(brand: "BMW", model: "X5", engine: "xDrive45e", version: "Plug-in Hybrid", registrationYears: Array(2000...2024)),
//
//    // MARK: Audi
//    Car(brand: "Audi", model: "A1", engine: "25 TFSI 95 CV", version: "Attraction", registrationYears: Array(2000...2024)),
//    Car(brand: "Audi", model: "A1", engine: "30 TFSI 110 CV", version: "S line", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Audi", model: "A3", engine: "30 TFSI 110 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Audi", model: "A3", engine: "35 TDI 150 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Audi", model: "A3", engine: "S3 310 CV", version: "S3", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Audi", model: "A4", engine: "35 TDI 163 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Audi", model: "A4", engine: "40 TFSI 204 CV", version: "S tronic", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Audi", model: "Q3", engine: "35 TFSI 150 CV", version: "quattro", registrationYears: Array(2000...2024)),
//    Car(brand: "Audi", model: "Q3", engine: "35 TDI 150 CV", version: "quattro", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Audi", model: "Q5", engine: "35 TDI 163 CV", version: "quattro", registrationYears: Array(2000...2024)),
//    Car(brand: "Audi", model: "Q5", engine: "45 TFSI 265 CV", version: "quattro S line", registrationYears: Array(2000...2024)),
//
//    // MARK: Toyota
//    Car(brand: "Toyota", model: "Aygo X", engine: "1.0 VVT-i 72 CV", version: "Active", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Toyota", model: "Yaris", engine: "1.0 VVT-i", version: "Active", registrationYears: Array(2000...2024)),
//    Car(brand: "Toyota", model: "Yaris", engine: "1.5 Hybrid 116 CV", version: "Trend", registrationYears: Array(2000...2024)),
//    Car(brand: "Toyota", model: "Yaris", engine: "GR Yaris 261 CV", version: "GR", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Toyota", model: "Corolla", engine: "1.8 Hybrid 122 CV", version: "Active", registrationYears: Array(2000...2024)),
//    Car(brand: "Toyota", model: "Corolla", engine: "2.0 Hybrid 180 CV", version: "Style", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Toyota", model: "C-HR", engine: "2.0 Hybrid 184 CV", version: "Trend", registrationYears: Array(2000...2024)),
//    Car(brand: "Toyota", model: "C-HR", engine: "1.8 Hybrid 140 CV", version: "Lounge", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Toyota", model: "RAV4", engine: "2.5 Hybrid 218 CV", version: "Active", registrationYears: Array(2000...2024)),
//    Car(brand: "Toyota", model: "RAV4", engine: "2.5 Hybrid 222 CV AWD", version: "Lounge", registrationYears: Array(2000...2024)),
//    Car(brand: "Toyota", model: "RAV4", engine: "Plug-in Hybrid 306 CV", version: "GR-Line", registrationYears: Array(2000...2024)),
//
//    // MARK: Fiat
//    Car(brand: "Fiat", model: "Panda", engine: "1.0 FireFly Hybrid 70 CV", version: "City Life", registrationYears: Array(2000...2024)),
//    Car(brand: "Fiat", model: "Panda", engine: "0.9 TwinAir 85 CV", version: "4x4", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Fiat", model: "500", engine: "1.0 Hybrid 70 CV", version: "Dolcevita", registrationYears: Array(2000...2024)),
//    Car(brand: "Fiat", model: "500", engine: "Elettrica 118 CV", version: "Icon", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Fiat", model: "Tipo", engine: "1.6 Multijet 120 CV", version: "City Life", registrationYears: Array(2000...2024)),
//    Car(brand: "Fiat", model: "Tipo", engine: "1.0 T3 100 CV", version: "Cross", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Fiat", model: "500X", engine: "1.0 T3 120 CV", version: "Cross", registrationYears: Array(2000...2024)),
//    Car(brand: "Fiat", model: "500X", engine: "1.6 Multijet 130 CV", version: "Sport", registrationYears: Array(2000...2024)),
//
//    // MARK: Ford
//    Car(brand: "Ford", model: "Fiesta", engine: "1.1 75 CV", version: "Trend", registrationYears: Array(2000...2024)),
//    Car(brand: "Ford", model: "Fiesta", engine: "1.0 EcoBoost 100 CV", version: "Titanium", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Ford", model: "Focus", engine: "1.0 EcoBoost 125 CV", version: "ST-Line", registrationYears: Array(2000...2024)),
//    Car(brand: "Ford", model: "Focus", engine: "1.5 EcoBlue 120 CV", version: "Titanium", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Ford", model: "Puma", engine: "1.0 EcoBoost Hybrid 125 CV", version: "", registrationYears: Array(2000...2024)),
//    Car(brand: "Ford", model: "Puma", engine: "ST 200 CV", version: "", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Ford", model: "Kuga", engine: "1.5 EcoBoost 150 CV", version: "ST-Line", registrationYears: Array(2000...2024)),
//    Car(brand: "Ford", model: "Kuga", engine: "2.5 Plug-in Hybrid 225 CV", version: "ST-Line", registrationYears: Array(2000...2024)),
//
//    // MARK: Mercedes
//    Car(brand: "Mercedes", model: "A-Class", engine: "A180 136 CV", version: "Business", registrationYears: Array(2000...2024)),
//    Car(brand: "Mercedes", model: "A-Class", engine: "A200d 150 CV", version: "Sport", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Mercedes", model: "C-Class", engine: "C200 204 CV", version: "Mild Hybrid", registrationYears: Array(2000...2024)),
//    Car(brand: "Mercedes", model: "C-Class", engine: "C220d 200 CV", version: "AMG Line", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Mercedes", model: "GLA", engine: "GLA 200 163 CV", version: "", registrationYears: Array(2000...2024)),
//    Car(brand: "Mercedes", model: "GLA", engine: "GLA 220d 190 CV", version: "4Matic", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Mercedes", model: "GLC", engine: "GLC 220d 197 CV", version: "4Matic", registrationYears: Array(2000...2024)),
//    Car(brand: "Mercedes", model: "GLC", engine: "GLC 300e", version: "Plug-in Hybrid", registrationYears: Array(2000...2024)),
//
//    // MARK: Peugeot
//    Car(brand: "Peugeot", model: "208", engine: "1.2 PureTech 75 CV", version: "Active", registrationYears: Array(2000...2024)),
//    Car(brand: "Peugeot", model: "208", engine: "e-208 136 CV", version: "Allure", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Peugeot", model: "308", engine: "1.2 PureTech 130 CV", version: "GT-Line", registrationYears: Array(2000...2024)),
//    Car(brand: "Peugeot", model: "308", engine: "1.5 BlueHDi 130 CV", version: "GT-Line", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Peugeot", model: "2008", engine: "1.2 PureTech 100 CV", version: "Base", registrationYears: Array(2000...2024)),
//    Car(brand: "Peugeot", model: "2008", engine: "e-2008 136 CV", version: "GT", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Peugeot", model: "3008", engine: "1.2 PureTech 130 CV", version: "", registrationYears: Array(2000...2024)),
//    Car(brand: "Peugeot", model: "3008", engine: "Hybrid4 300 CV", version: "", registrationYears: Array(2000...2024)),
//
//    // MARK: Opel
//    Car(brand: "Opel", model: "Corsa", engine: "1.2 75 CV", version: "Style", registrationYears: Array(2000...2024)),
//    Car(brand: "Opel", model: "Corsa", engine: "e-Corsa 136 CV", version: "Electric", registrationYears: Array(2000...2024)),
//
//    Car(brand: "Opel", model: "Astra", engine: "1.2 Turbo 130 CV", version: "Style", registrationYears: Array(2000...2024)),
//    Car(brand: "Opel", model: "Astra", engine: "1.5 Diesel 130 CV", version: "Style", registrationYears: Array(2000...2024))
//]

