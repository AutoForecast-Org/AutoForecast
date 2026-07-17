//
//  CarValueWizardView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

//import SwiftUI

// MARK: - Wizard
//struct CarValueWizardView: View {
//    enum Step: Int, CaseIterable {
//        case brand, model, version, year, optionalInfo, review
//        var title: String {
//            switch self {
//            case .brand: return "Marchio"
//            case .model: return "Modello"
//            case .version: return "Versione"
//            case .year: return "Anno di registrazione"
//            case .optionalInfo: return "Altri parametri"
//            case .review: return "Riepilogo"
//            }
//        }
//    }
//
//    @Environment(\.colorScheme) private var colorScheme
//    
//    @State private var step: Step = .brand
//    @State private var selectedBrand: String? = nil
//    @State private var selectedModel: String? = nil
//    @State private var selectedVersion: String? = nil
//    @State private var selectedYear: Int? = nil
//
//    // Nuovi parametri opzionali
//    @State private var kmAttuali: Int? = 50_000
//    @State private var selectedColor: String? = nil
//    @State private var selectedZone: String? = nil
//    @State private var numberOfOwners: Int? = nil
//    @State private var certifiedMaintenance: Bool = false
//
//    @State private var currentValue: Int? = nil
//    @State private var futureValue: Int? = nil
//    
//    @State private var showCalculation = false
//    
//    private func resetAfterBrandChange() {
//        selectedModel = nil
//        selectedVersion = nil
//        selectedYear = nil
//        resetOptionalInfo()
//        currentValue = nil
//        futureValue = nil
//    }
//    private func resetAfterModelChange() {
//        selectedVersion = nil
//        selectedYear = nil
//        resetOptionalInfo()
//        currentValue = nil
//        futureValue = nil
//    }
//    private func resetAfterVersionChange() {
//        selectedYear = nil
//        resetOptionalInfo()
//        currentValue = nil
//        futureValue = nil
//    }
//    private func resetAfterYearChange() {
//        resetOptionalInfo()
//        currentValue = nil
//        futureValue = nil
//    }
//    private func resetOptionalInfo() {
//        kmAttuali = nil
//        selectedColor = nil
//        selectedZone = nil
//        numberOfOwners = nil
//        certifiedMaintenance = false
//    }
//
//    let brands = ["Renault", "Volkswagen", "BMW", "Audi", "Toyota", "Fiat", "Ford", "Mercedes", "Peugeot", "Opel", "Kia", "Hyundai"]
//
//    let modelsByBrand: [String: [String]] = [
//        "Renault": ["Clio", "Captur", "Megane", "Scenic"],
//        "Volkswagen": ["Golf", "Polo", "Tiguan", "Passat"],
//        "BMW": ["1 Series", "3 Series", "X1", "X3", "X5"],
//        "Audi": ["A1", "A3", "A4", "Q3", "Q5"],
//        "Toyota": ["Aygo X", "Yaris", "Corolla", "C-HR", "RAV4"],
//        "Fiat": ["Panda", "500", "Tipo", "500X"],
//        "Ford": ["Fiesta", "Focus", "Puma", "Kuga"],
//        "Mercedes": ["A-Class", "C-Class", "GLA", "GLC"],
//        "Peugeot": ["208", "308", "2008", "3008"],
//        "Opel": ["Corsa", "Astra", "Mokka"],
//        "Kia": ["Picanto", "Ceed", "Sportage", "Niro"],
//        "Hyundai": ["i10", "i20", "i30", "Tucson", "Kona"]
//    ]
//
//    let versionsByModel: [String: [String]] = [
//        // Renault
//        "Clio": ["1.5 dCi 90 CV Zen", "1.0 TCe 100 CV Intens", "1.3 TCe 130 CV RS Line"],
//        "Captur": ["1.5 dCi 95 CV Intens", "1.3 TCe 140 CV Business", "E-Tech Hybrid 145 CV"],
//        "Megane": ["1.5 Blue dCi 115 CV Sporter", "1.3 TCe 140 CV Intens", "RS 300 CV"],
//        "Scenic": ["1.6 dCi 130 CV Bose", "1.3 TCe 140 CV Intens"],
//
//        // Volkswagen
//        "Golf": ["1.0 TSI 110 CV Life", "2.0 TDI 150 CV Style", "GTI 245 CV"],
//        "Polo": ["1.0 MPI 80 CV Trendline", "1.0 TSI 95 CV Comfortline"],
//        "Tiguan": ["2.0 TDI 150 CV Business", "1.5 TSI 130 CV Life", "R 320 CV"],
//        "Passat": ["2.0 TDI 150 CV DSG Business", "1.5 TSI 150 CV Elegance"],
//
//        // BMW
//        "1 Series": ["118i 136 CV Advantage", "120d 190 CV Sport"],
//        "3 Series": ["318d 150 CV Business", "320i 184 CV M Sport", "330e Plug-in Hybrid"],
//        "X1": ["sDrive18i 136 CV Advantage", "xDrive20d 190 CV Sport", "xDrive25e Plug-in Hybrid"],
//        "X3": ["xDrive20i 184 CV Business", "xDrive30d 286 CV Luxury"],
//        "X5": ["xDrive30d 286 CV M Sport", "xDrive45e Plug-in Hybrid"],
//
//        // Audi
//        "A1": ["25 TFSI 95 CV Attraction", "30 TFSI 110 CV S line"],
//        "A3": ["30 TFSI 110 CV", "35 TDI 150 CV Business", "S3 310 CV"],
//        "A4": ["35 TDI 163 CV", "40 TFSI 204 CV S tronic"],
//        "Q3": ["35 TFSI 150 CV", "35 TDI 150 CV quattro"],
//        "Q5": ["35 TDI 163 CV quattro", "45 TFSI 265 CV quattro S line"],
//
//        // Toyota
//        "Aygo X": ["1.0 VVT-i 72 CV Active"],
//        "Yaris": ["1.0 VVT-i Active", "1.5 Hybrid 116 CV Trend", "GR Yaris 261 CV"],
//        "Corolla": ["1.8 Hybrid 122 CV Active", "2.0 Hybrid 180 CV Style"],
//        "C-HR": ["2.0 Hybrid 184 CV Trend", "1.8 Hybrid 140 CV Lounge"],
//        "RAV4": ["2.5 Hybrid 218 CV Active", "2.5 Hybrid 222 CV AWD Lounge", "Plug-in Hybrid 306 CV"],
//
//        // Fiat
//        "Panda": ["1.0 FireFly Hybrid 70 CV City Life", "0.9 TwinAir 85 CV 4x4"],
//        "500": ["1.0 Hybrid 70 CV Dolcevita", "Elettrica 118 CV Icon"],
//        "Tipo": ["1.6 Multijet 120 CV City Life", "1.0 T3 100 CV Cross"],
//        "500X": ["1.0 T3 120 CV Cross", "1.6 Multijet 130 CV Sport"],
//
//        // Ford
//        "Fiesta": ["1.1 75 CV Trend", "1.0 EcoBoost 100 CV Titanium"],
//        "Focus": ["1.0 EcoBoost 125 CV ST-Line", "1.5 EcoBlue 120 CV Titanium"],
//        "Puma": ["1.0 EcoBoost Hybrid 125 CV", "ST 200 CV"],
//        "Kuga": ["1.5 EcoBoost 150 CV ST-Line", "2.5 Plug-in Hybrid 225 CV"],
//
//        // Mercedes
//        "A-Class": ["A180 136 CV Business", "A200d 150 CV Sport"],
//        "C-Class": ["C200 204 CV Mild Hybrid", "C220d 200 CV AMG Line"],
//        "GLA": ["GLA 200 163 CV", "GLA 220d 190 CV 4Matic"],
//        "GLC": ["GLC 220d 197 CV 4Matic", "GLC 300e Plug-in Hybrid"],
//
//        // Peugeot
//        "208": ["1.2 PureTech 75 CV Active", "e-208 136 CV Allure"],
//        "308": ["1.2 PureTech 130 CV", "1.5 BlueHDi 130 CV"],
//        "2008": ["1.2 PureTech 100 CV", "e-2008 136 CV GT"],
//        "3008": ["1.2 PureTech 130 CV", "Hybrid4 300 CV"],
//
//        // Opel
//        "Corsa": ["1.2 75 CV", "e-Corsa 136 CV"],
//        "Astra": ["1.2 Turbo 130 CV", "1.5 Diesel 130 CV"],
//        "Mokka": ["1.2 Turbo 130 CV", "Mokka-e 136 CV"],
//
//        // Kia
//        "Picanto": ["1.0 67 CV Urban", "1.2 84 CV Style"],
//        "Ceed": ["1.0 T-GDi 120 CV", "1.6 CRDi 136 CV"],
//        "Sportage": ["1.6 T-GDi 150 CV", "HEV 230 CV", "PHEV 265 CV"],
//        "Niro": ["HEV 141 CV", "PHEV 183 CV", "EV 204 CV"],
//
//        // Hyundai
//        "i10": ["1.0 MPI 67 CV", "1.2 MPI 84 CV"],
//        "i20": ["1.2 MPI 84 CV", "1.0 T-GDi 100 CV"],
//        "i30": ["1.0 T-GDi 120 CV", "1.5 T-GDi 160 CV"],
//        "Tucson": ["1.6 CRDi 136 CV", "HEV 230 CV", "PHEV 265 CV"],
//        "Kona": ["1.0 T-GDi 120 CV", "EV 204 CV"]
//    ]
//    
//    let years = Array(2000...2024)
//
//    // New data for optional parameters
//    let colors = ["Nero", "Grigio", "Argento", "Bianco", "Blu/Azzurro", "Giallo", "Lilla", "Rosso", "Arancione", "Verde", "Oro", "Marrone", "Bronzo", "Beige"]
//    let zones = ["Nord", "Centro", "Sud & Isole"]
//    let ownersRange = 1...5
//
//    var body: some View {
//        VStack {
//            ZStack {
//                (colorScheme == .dark ? Color("1C1C1E") : Color("F2F2F7"))
//                    .ignoresSafeArea()
//
//                VStack(spacing: 24) {
//                    VStack(alignment: .leading, spacing: 24) {
////                        Text(step.title)
////                            .font(.title3)
////                            .fontWeight(.semibold)
////                            .foregroundColor(.primary)
////                            .padding(.top, 8)
////                            .padding(.bottom, 4)
//
//                        StepProgressView(totalSteps: Step.allCases.count, currentStep: step.rawValue)
//                            .frame(height: 24)
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(alignment: .center, spacing: 4) {
//                                Pill(text: selectedBrand ?? "Marchio")
//                                    .font(.caption2)
//                                    .padding(.vertical, 4)
//                                    .padding(.horizontal, 4)
//                                Pill(text: selectedModel ?? "Modello")
//                                    .font(.caption2)
//                                    .padding(.vertical, 4)
//                                    .padding(.horizontal, 4)
//                                Pill(text: selectedVersion ?? "Versione")
//                                    .font(.caption2)
//                                    .padding(.vertical, 4)
//                                    .padding(.horizontal, 4)
//                                Pill(text: selectedYear.map(String.init) ?? "Anno")
//                                    .font(.caption2)
//                                    .padding(.vertical, 4)
//                                    .padding(.horizontal, 4)
//                            }
//                            .padding(.vertical, 2)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 16)
//
//                    Group {
//                        switch step {
//                        case .brand:
////                            ModernSelection(image: "car", title: "Seleziona il marchio", items: brands, selectedItem: $selectedBrand) {
////                                resetAfterBrandChange()
////                            }
//                        case .model:
//                            ModernSelection(image: "car.badge.gearshape", title: "Selezioona il modello", items: modelsByBrand[selectedBrand ?? ""] ?? [], selectedItem: $selectedModel) {
//                                resetAfterModelChange()
//                            }
//                        case .version:
//                            ModernSelection(image: "engine.combustion", title: "Seleziona la versione", items: versionsByModel[selectedModel ?? ""] ?? [], selectedItem: $selectedVersion) {
//                                resetAfterVersionChange()
//                            }
//                        case .year:
//                            ModernSelection(image: "calendar", title: "Seleziona l'anno di registrazione", items: years.reversed().map { String($0) }, selectedItem: Binding(
//                                get: { selectedYear.map(String.init) },
//                                set: { new in selectedYear = new.flatMap(Int.init) }
//                            )) {
//                                resetAfterYearChange()
//                            }
//                        case .optionalInfo:
//                            OptionalInfoView(
//                                kmAttuali: $kmAttuali,
//                                selectedColor: $selectedColor,
//                                selectedZone: $selectedZone,
//                                numberOfOwners: $numberOfOwners,
//                                certifiedMaintenance: $certifiedMaintenance,
//                                colors: colors,
//                                zones: zones,
//                                ownersRange: ownersRange
//                            )
//                        case .review:
//                            ReviewCard(
//                                brand: selectedBrand!,
//                                model: selectedModel!,
//                                version: selectedVersion!,
//                                year: selectedYear!,
//                                currentValue: currentValue,
//                                futureValue: futureValue,
//                                kmAttuali: kmAttuali,
//                                selectedColor: selectedColor,
//                                selectedZone: selectedZone,
//                                numberOfOwners: numberOfOwners,
//                                certifiedMaintenance: certifiedMaintenance
//                            )
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding(.horizontal)
//                }
//                
//                NavigationLink(
//                    destination: ForecastView(
//                        brand: selectedBrand ?? "",
//                        model: selectedModel ?? "",
//                        version: selectedVersion ?? "",
//                        engine: "",
//                        registrationYear: selectedYear ?? 2000,
//                        kmAttuali: kmAttuali,
//                        color: selectedColor ?? "",
//                        zone: selectedZone,
//                        owners: 1,
//                        certifiedMaintenance: certifiedMaintenance
//                    ),
//                    isActive: $showCalculation
//                ) {
//                    EmptyView()
//                }
//                .hidden()
//            }
//            .navigationTitle(step.title)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                // Title
//                ToolbarItem(placement: .principal) {
//                    Text(step.title)
//                        .font(.headline)
//                }
//
//                // Back iOS native button
//                ToolbarItem(placement: .navigationBarLeading) {
//                    if step != .brand {
//                        Button(action: { withAnimation { goBack() } }) {
//                            Label("Indietro", systemImage: "chevron.left")
//                        }
//                    }
//                }
//
//                // Next button
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    if step != .review {
//                        Button(action: { withAnimation { goNext() } }) {
//                            Text("Avanti")
//                                .bold()
//                        }
//                        .disabled(!canProceed)
//                    } else {
//                        Button(action: {
//                            withAnimation {
//                                calculateValues()
//                                showCalculation = true
//                            }
//                        }) {
//                            Text("Calcola")
//                                .bold()
//                        }
//                        .disabled(!canProceed)
//                    }
//                }
//            }
//        }
//    }
//
//    private var canProceed: Bool {
//        switch step {
//        case .brand: return selectedBrand != nil
//        case .model: return selectedModel != nil
//        case .version: return selectedVersion != nil
//        case .year: return selectedYear != nil
//        case .optionalInfo: return true
//        case .review: return true
//        }
//    }
//
//    private var primaryButtonTitle: String {
//        switch step {
//        case .brand, .model, .version: return "Avanti"
//        case .year: return "Avanti"
//        case .optionalInfo: return "Rivedi"
//        case .review: return "Calcola"
//        }
//    }
//
//    private func goNext() {
//        switch step {
//        case .brand:
//            step = .model
//            resetAfterBrandChange()
//        case .model:
//            step = .version
//            resetAfterModelChange()
//        case .version:
//            step = .year
//            resetAfterVersionChange()
//        case .year:
//            step = .optionalInfo
//            resetOptionalInfo()
//        case .optionalInfo:
//            step = .review
//        case .review:
//            break
//        }
//    }
//
//    private func goBack() {
//        switch step {
//        case .review:
//            step = .optionalInfo
//        case .optionalInfo:
//            step = .year
//        case .year:
//            step = .version
//        case .version:
//            step = .model
//        case .model:
//            step = .brand
//        case .brand:
//            break
//        }
//    }
//
//    private func calculateValues() {
////        currentValue = Int.random(in: 8_000...50_000)
////        futureValue = currentValue.map { Int(Double($0) * 0.7) }
//    }
//}

//struct ModernSelection: View {
//    let image: String
//    let title: String
//    let items: [String]
//    @Binding var selectedItem: String?
//    var onChange: (() -> Void)? = nil
//
//    @Environment(\.colorScheme) private var colorScheme
//    @State private var searchText: String = ""
//
//    private var filteredItems: [String] {
//        guard !searchText.isEmpty else { return items }
//        return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(spacing: 8) {
//                Image(systemName: image)
//                    .foregroundColor(.blue)
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//            }
//            List(filteredItems, id: \.self) { item in
//                HStack {
//                    Text(item)
//                        .font(item == selectedItem ? .subheadline.bold() : .subheadline)
//                        .foregroundColor(item == selectedItem ? Color.accentColor : .primary)
//                    Spacer()
//                    if item == selectedItem {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Color.accentColor)
//                    }
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    if selectedItem != item {
//                        selectedItem = item
//                        onChange?()
//                    }
//                }
//                .listRowBackground(Color.clear)
//            }
//            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
//            .listStyle(PlainListStyle())
//        }
//        .padding(.horizontal, 8)
//    }
//}

//struct ReviewCard: View {
//    let brand: String
//    let model: String
//    let version: String?
//    let year: Int
//    let currentValue: Int?
//    let futureValue: Int?
//
//    // Optional parameters
//    let kmAttuali: Int?
//    let selectedColor: String?
//    let selectedZone: String?
//    let numberOfOwners: Int?
//    let certifiedMaintenance: Bool
//
//    @Environment(\.colorScheme) private var colorScheme
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Info Base auto
//                HStack(spacing: 12) {
//                    Image(systemName: "car.fill")
//                        .foregroundColor(Color.accentColor)
//                        .font(.title2)
//                    Text("\(brand) \(model)")
//                        .font(.title3).bold()
//                    Spacer()
//                }
//                HStack(spacing: 12) {
//                    Image(systemName: "gearshape.fill")
//                        .foregroundColor(Color.accentColor)
//                    Text(version ?? "-")
//                        .font(.subheadline)
//                    Spacer()
//                }
//                HStack(spacing: 12) {
//                    Image(systemName: "calendar")
//                        .foregroundColor(Color.accentColor)
//                    Text("Year: \(year)")
//                        .font(.subheadline)
//                    Spacer()
//                }
//
//                Divider()
//
//                // Optional parameters
//                VStack(alignment: .leading, spacing: 8) {
//                    if let km = kmAttuali {
//                        Text("Km Attuali: \(km) km")
//                    }
//                    if let color = selectedColor {
//                        Text("Colore: \(color)")
//                    }
//                    if let zone = selectedZone {
//                        Text("Zona geografica: \(zone)")
//                    }
//                    if let owners = numberOfOwners {
//                        Text("Numero di proprietari: \(owners)")
//                    }
//                    Text("Manutenzione certificata: \(certifiedMaintenance ? "Sì" : "No")")
//                }
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding()
//            .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color.white)
//            .cornerRadius(20)
//            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.25), radius: 5)
//        }
//    }
//}

//struct Pill: View {
//    let text: String
//    @Environment(\.colorScheme) private var colorScheme
//
//    var body: some View {
//        Text(text)
//            .font(.caption).bold()
//            .foregroundColor(Color.accentColor)
//            .padding(.vertical, 6)
//            .padding(.horizontal, 14)
//            .background(
//                colorScheme == .dark
//                ? Color.accentColor.opacity(0.15)
//                : Color.accentColor.opacity(0.1)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 30)
//                    .stroke(Color.accentColor, lineWidth: 1)
//            )
//            .cornerRadius(30)
//    }
//}

//struct StepProgressView: View {
//    let totalSteps: Int
//    let currentStep: Int
//
//    @Environment(\.colorScheme) private var colorScheme
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.gray.opacity(0.4))
//                .frame(height: 2)
//                .cornerRadius(1)
//                .padding(.horizontal, 24)
//
//            HStack(spacing: 0) {
//                ForEach(0..<totalSteps - 1, id: \.self) { index in
//                    Rectangle()
//                        .fill(index < currentStep ? Color.accentColor : Color.clear)
//                        .frame(height: 2)
//                        .cornerRadius(1)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//            .padding(.horizontal, 24)
//
//            HStack {
//                ForEach(0..<totalSteps, id: \.self) { index in
//                    ZStack {
//                        Circle()
//                            .fill(index <= currentStep ? Color.accentColor : Color.white)
//                            .frame(width: 24, height: 24)
//                            .overlay(
//                                Circle()
//                                    .stroke(index <= currentStep ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: 2)
//                            )
//                        Text("\(index + 1)")
//                            .font(.caption2).bold()
//                            .foregroundColor(index <= currentStep ? .white : .gray)
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//            .padding(.horizontal, 16)
//        }
//        .frame(height: 24)
//        .padding(.vertical, 8)
//    }
//}
