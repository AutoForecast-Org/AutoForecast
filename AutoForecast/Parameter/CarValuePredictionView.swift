//
//  CarValuePredictionCardView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct CarValuePredictionCardView: View {
    @EnvironmentObject var searchManager: SearchManager
    @Environment(\.navigate) private var navigate
    
    @FocusState private var kmFieldFocused: Bool
    
    @State private var selectedBrand: String? = nil
    @State private var selectedModel: String? = nil
    @State private var selectedEngine: String? = nil
    @State private var selectedActualKm: Int = 50_000
    @State private var selectedYear: String? = nil
    
    @State private var selectedVersion: String? = nil
    @State private var selectedColor: String? = nil
    @State private var selectedZone: String? = nil
    @State private var numberOfOwners: Int = 2
    @State private var selectedMaintenance: String? = nil
    @State private var selectedOptionals: [String] = []
    
    @State private var currentValue: Int? = nil
    @State private var futureValue: Int? = nil
    
    @State private var showOptionalParameters = false
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
    // MARK: - Computed Variables
    var availableBrands: [String] {
        Array(Set(searchManager.carsDataset.map { $0.brand })).sorted()
    }
    
    var availableModels: [String] {
        guard let brand = selectedBrand else { return [] }
        return Array(Set(searchManager.carsDataset.filter { $0.brand == brand }.map { $0.model })).sorted()
    }
    
    var availableEngines: [String] {
        guard let brand = selectedBrand, let model = selectedModel else { return [] }
        return Array(Set(searchManager.carsDataset
            .filter { $0.brand == brand && $0.model == model }
            .map { $0.engine })).sorted()
    }
    
    var availableVersions: [String] {
        guard let brand = selectedBrand,
              let model = selectedModel,
              let engine = selectedEngine,
              let stringYear = selectedYear,
              let year = Int(stringYear) else { return [] }
        
        return Array(Set(searchManager.carsDataset
            .filter { $0.brand == brand && $0.model == model && $0.engine == engine && $0.year == year }
            .map { $0.version ?? "" })).sorted()
    }
    
    var availableColors : [String] {
        return Array(Set(searchManager.coefficientColors.map { $0.color })).sorted()
    }
    
    var availableZones : [String] {
        return Array(Set(searchManager.coefficientLocations.map { $0.location })).sorted()
    }
    
    var availableOwners : ClosedRange<Int> {
        let ownersArray = Array(Set(searchManager.coefficientNumberOfOwners.map { $0.owners })).sorted()
        if let first = ownersArray.first {
            if let last = ownersArray.last {
                return first...last
            }
        }
        return 1...1
    }
    
    var availableMaintenanceOptions : [String] {
        return Array(Set(searchManager.coefficientMaintenances.map { $0.maintenance })).sorted()
    }
    
    var availableOptionals : [String] {
        return Array(Set(searchManager.coefficientOptionals.map { $0.optional })).sorted()
    }
    
    var availableYears: [Int] {
        guard let brand = selectedBrand,
              let model = selectedModel,
              let engine = selectedEngine else { return [] }

        return Array(Set(searchManager.carsDataset
            .filter { $0.brand == brand && $0.model == model && $0.engine == engine}
            .map { $0.year })).sorted()
    }
    
    var isOptionalParametersEnabled: Bool {
        return selectedBrand != nil &&
        selectedModel != nil &&
        selectedEngine != nil &&
        selectedYear != nil
    }
    
    // MARK: - MainView
    var body: some View {
        
        ScrollView {
            VStack(spacing: 16) {
                
//                Text("Identifica la tua auto")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.top)
//                    .foregroundColor(ColorLayout.primary.auto)
                
                // MARK: - Brand
                NavigationLink(destination: SearchableSelectionListView(
                    title: "Brand",
                    items: availableBrands,
                    showFeedbackLabel: true,
                    selectedItem: Binding(
                        get: { selectedBrand ?? "Select Brand" },
                        set: { newValue in
                            selectedBrand = newValue
                            selectedModel = nil
                            selectedEngine = nil
                            selectedYear = nil
                            selectedVersion = nil
                            showOptionalParameters = false
                        }
                    )
                )) {
                    CardRow(title: "Brand", value: selectedBrand ?? "Seleziona il brand", icon: "car.side")
                }
                
                // MARK: - Model
                if selectedBrand != nil {
                    let models = availableModels
                    NavigationLink(destination: SearchableSelectionListView(
                        title: "Modello",
                        items: models,
                        showFeedbackLabel: true,
                        selectedItem: Binding(
                            get: { selectedModel ?? "Selezione modello" },
                            set: { newValue in
                                selectedModel = newValue
                                selectedEngine = nil
                                selectedYear = nil
                                selectedVersion = nil
                                showOptionalParameters = false
                            }
                        )
                    )) {
                        CardRow(title: "Modello", value: selectedModel ?? "Seleziona il modello", icon: "text.page.badge.magnifyingglass")
                    }
                } else {
                    CardRow(title: "Modello", value: "Seleziona il modello", icon: "text.page.badge.magnifyingglass")
                        .opacity(0.4)
                }
                
                // MARK: - Engine
                if selectedBrand != nil && selectedModel != nil {
                    let engines = availableEngines
                    NavigationLink(destination: SearchableSelectionListView(
                        title: "Motore",
                        items: engines,
                        showFeedbackLabel: true,
                        selectedItem: Binding(
                            get: { selectedEngine ?? "Selezione motore" },
                            set: { newValue in
                                selectedEngine = newValue
                                autoSelectYear()
                                selectedVersion = nil
                                showOptionalParameters = false
                            }
                        )
                    )) {
                        CardRow(title: "Motore", value: selectedEngine ?? "Seleziona il motore", icon: "engine.combustion")
                    }
                } else {
                    CardRow(title: "Motore", value: "Seleziona il motore", icon: "engine.combustion")
                        .opacity(0.4)
                }
                
                // MARK: - Year
                if selectedBrand != nil && selectedModel != nil && selectedEngine != nil {
                    let years = availableYears.map { String($0) }
                    NavigationLink(destination: SearchableSelectionListView(
                        title: "Anno di 1° immatricolaziuone",
                        items: years,
                        showFeedbackLabel: false,
                        selectedItem: Binding(
                            get: { selectedYear ?? "Seleziona l'anno" },
                            set: { newValue in
                                selectedYear = newValue
                                selectedVersion = nil
                                showOptionalParameters = false
                            }
                        )
                    )) {
                        CardRow(title: "Anno di 1° immatricolazione", value: selectedYear ?? "Seleziona l'anno", icon: "calendar")
                    }
                } else {
                    CardRow(title: "Anno di 1° immatricolazione", value: "Seleziona l'anno", icon: "calendar")
                        .opacity(0.4)
                }
                
                
                // MARK: - Actual Km
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "numbers.rectangle")
                            .foregroundColor(ColorLayout.primary.auto)
                        Text("Km Attuali")
                            .font(.subheadline)
                            .foregroundColor(ColorLayout.gray3.auto)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(selectedActualKm) },
                            set: { selectedActualKm = Int($0) }
                        ),
                        in: 0...300_000,
                        step: 1_000
                    )
                    .accentColor(ColorLayout.secondary.auto)

                    HStack(spacing: 16) {
                        Text("\(selectedActualKm) km")
                            .font(.headline)
                            .foregroundColor(ColorLayout.primary.auto)
                            .frame(width: 100, alignment: .leading)
                        
                        Spacer()
                        
                        Stepper(value: $selectedActualKm, in: 0...300_000, step: 500) {
                            Text("± 500 km")
                                .font(.caption)
                        }
                    }
                    
                    Text("Usa lo slider per spostarti rapidamente e i pulsanti per i piccoli aggiustamenti.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(ColorLayout.cardRowBackgroud.auto)
                .cornerRadius(12)
                .disabled(selectedYear == nil)
                .opacity(selectedYear == nil ? 0.4 : 1)
                
                // MARK: - Additional Parameters
//                Button(action: {
//                    withAnimation {
//                        showOptionalParameters.toggle()
//                    }
//                }) {
//                    HStack {
//                        Image(systemName: "slider.horizontal.3")
//                            .foregroundColor(ColorLayout.primary.auto)
//                            .frame(width: 24)
//                        VStack (alignment: .leading, spacing: 8) {
//                            Text("Altri parametri (facoltativo)")
//                                .font(.headline)
//                                .foregroundColor(ColorLayout.primary.auto)
//                            Text("Inserisci ulteriori dettagli per rendere l'elaborazione piú accurata")
//                                .font(.caption)
//                                .foregroundColor(.primary)
//                        }
//                        Spacer()
//                        Image(systemName: showOptionalParameters ? "chevron.up" : "chevron.down")
//                            .foregroundColor(ColorLayout.gray3.auto)
//                    }
//                    .padding()
//                    .background(ColorLayout.cardRowBackgroud.auto)
//                    .cornerRadius(12)
//                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
//                }
//                .disabled(!isOptionalParametersEnabled)
//                .opacity(isOptionalParametersEnabled ? 1 : 0.4)
//                
//                if showOptionalParameters {
//                    OptionalInfoView(
//                        selectedBrand: $selectedBrand,
//                        selectedModel: $selectedModel,
//                        selectedEngine: $selectedEngine,
//                        availableVersions: availableVersions,
//                        selectedVersion: $selectedVersion,
//                        selectedColor: $selectedColor,
//                        selectedZone: $selectedZone,
//                        numberOfOwners: $numberOfOwners,
//                        selectedMaintenance: $selectedMaintenance,
//                        selectedOptionals: $selectedOptionals,
//                        colors: availableColors,
//                        zones: availableZones,
//                        ownersRange: availableOwners,
//                        maintenanceOptions: availableMaintenanceOptions,
//                        optionals: availableOptionals
//                        
//                    )
//                    .frame(maxHeight: showOptionalParameters ? .infinity : 0)
//                    .clipped()
//                    .animation(.easeInOut, value: showOptionalParameters)
//                }
                
                Button(action: {
                    guard
                        let brand = selectedBrand,
                        let model = selectedModel,
                        let engine = selectedEngine,
                        let strYear = selectedYear,
                        let year = Int(strYear)
                    else { return }
                    
                    let userCar = UserCar(
                        brand: brand,
                        model: model,
                        engine: engine,
                        registrationYear: year,
                        actualKm: selectedActualKm,
                        version: selectedVersion,
                        color: selectedColor,
                        zone: selectedZone,
                        certifiedManintenance: selectedMaintenance,
                        optionals: selectedOptionals,
                        numberOfOwners: numberOfOwners
                    )
                    
                    navigate.append(.optionalParameters(userCar))
                }) {
                    Text("PROSEGUI")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedYear == nil ? ColorLayout.gray3.auto : ColorLayout.primary.auto)
                        .foregroundColor(ColorLayout.white.auto)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .disabled(selectedBrand == nil || selectedModel == nil || selectedEngine == nil || selectedYear == nil)
                .padding(.top)
                
                Spacer()
            }
            .padding()
        }
        .background(ColorLayout.appBackround.auto)
        .navigationTitle("Identifica la tua auto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)       
    }
    
    private func autoSelectYear() {
        let years = availableYears
        
        if years.count == 1 {
            selectedYear = years.first.map { String($0) }
        } else {
            selectedYear = nil
        }
    }
}

// MARK: - Reusable Card Row
struct CardRow: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorLayout.primary.auto)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(ColorLayout.gray3.auto)
                Text(value)
                    .font(.headline)
                    .foregroundColor(ColorLayout.primary.auto)
                    
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(ColorLayout.gray3.auto)
        }
        .padding()
        .background(ColorLayout.cardRowBackgroud.auto)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Searchable List View (search bar sempre visibile)
struct SearchableSelectionListView: View {
    let title: String
    let items: [String]
    let showFeedbackLabel: Bool
    @Binding var selectedItem: String
    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = ""
    
    var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var isSelectionValid: Bool {
        return items.contains(selectedItem)
    }
    
    var body: some View {
        VStack {
            List(filteredItems, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(item == selectedItem ? .subheadline.bold() : .subheadline)
                        .foregroundColor(item == selectedItem ? ColorLayout.primary.auto : .primary)
                    Spacer()
                    if item == selectedItem {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorLayout.primary.auto)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItem = item
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .listStyle(.plain)
            
            if showFeedbackLabel {
                NavigationLink {
                    FeedbackView()
                } label: {
                    if title.lowercased() == "Versione".lowercased() {
                        Text("Non trovi la \(title.lowercased()) che stavi cercando? Scrivici →")
                            .font(.subheadline)
                            .foregroundColor(ColorLayout.primary.auto)
                    } else {
                        Text("Non trovi il \(title.lowercased()) che stavi cercando? Scrivici →")
                            .font(.subheadline)
                            .foregroundColor(ColorLayout.primary.auto)
                    }
                }
                .padding()
            }
                
        }
        .navigationTitle(title)
    }
}

// MARK: - Searchable List MULTI View (search bar sempre visibile)
struct SearchableSelectionListMultiView: View {
    let title: String
    let items: [String]
    @Binding var selectedItems: [String]
    
    @State private var searchText = ""
    @Environment(\.presentationMode) private var presentationMode
    
    var filteredItems: [String] {
        searchText.isEmpty
        ? items
        : items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filteredItems, id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    
                    // Se selezionato → checkmark
                    if selectedItems.contains(item) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorLayout.primary.auto)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggle(item)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle(title)
        .toolbar {
            Button("Fatto") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func toggle(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.removeAll { $0 == item }
        } else {
            selectedItems.append(item)
        }
    }
}


//struct CarValuePredictionCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CarValuePredictionCardView()
//    }
//}
