//
//  ForecastView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ForecastView: View {
    
    // MARK: - Environment
    @EnvironmentObject var searchManager: SearchManager
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - UI State
    @State private var showSavedToast = false
    @State private var showDuplicateAlert = false
    @State private var pendingSearch: SavedSearch?
    @State private var selectedYear: Int
    @State private var showAllInfoCards = false
    @State private var selectedInfoCard: ForecastInfoCard?
    
    // MARK: - Chart Display Mode
    @State private var displayMode: ForecastDisplayMode = .all
  
    // MARK: - Report
    @State private var reportToPreview: IdentifiableURL?
    
    // MARK: - Input
    let userCarForecast: UserCarForecast
    @Namespace private var aiNamespace
    
    // MARK: - Init
    init(userCarForecast: UserCarForecast) {
        self.userCarForecast = userCarForecast
        let currentYear = Calendar.current.component(.year, from: Date())
        _selectedYear = State(initialValue: currentYear)
    }

    // MARK: - Computed values
    private var vehicleName: String {
        "\(userCarForecast.userCar.brand) \(userCarForecast.userCar.model)"
    }

    private var vehicleListPrice: String {
        let price = userCarForecast.purchasePrice
            .formatted(.currency(code: "EUR"))
        return String(localized: "Prezzo di listino: \(price)")
    }

    private var versionAndEngine: String {
        if let version = userCarForecast.userCar.version {
            return "\(version) • \(userCarForecast.userCar.engine)"
        } else {
            return userCarForecast.userCar.engine
        }
    }

    private var yearAndKms: String {
        String(localized: "Anno: \(userCarForecast.userCar.registrationYear) • Km: \(userCarForecast.userCar.actualKm) km")
    }

    private var yearRange: ClosedRange<Double> {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endYear = userCarForecast.userCar.registrationYear + 20
        return Double(currentYear)...Double(endYear)
    }

    private var bestSellingPoint: DepreciationPoint? {
        let currentYear = Calendar.current.component(.year, from: Date())

        return userCarForecast.data
            .filter { $0.year >= currentYear }
            .max(by: { $0.value < $1.value })
    }
    
    private var depreciationTrend: DepreciationTrend? {
        let currentYear = Calendar.current.component(.year, from: Date())

        let futureData = userCarForecast.data
            .filter { $0.year >= currentYear }
            .sorted(by: { $0.year < $1.year })

        guard futureData.count >= 2 else { return nil }

        let first = futureData.first!
        let last = futureData.last!

        let years = Double(last.year - first.year)
        guard years > 0 else { return nil }

        let totalChange = (last.value - first.value) / first.value
        let annualChange = totalChange / years

        return DepreciationTrend.from(annualChange: annualChange)
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
//                sliderSection
//                chartSection
                forecastSection
//                oscillationSection
                bestSellingSection
//                depreciationIndicatorSection
                explanationSection
                comparisonSection
                actionsSection
            }
            .background(ColorLayout.appBackround.auto)

//            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .scrollContentBackground(.hidden)
        .background(ColorLayout.appBackround.auto)
        .navigationTitle("Valore futuro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if !userCarForecast.isSaved && !userCarForecast.isExmample {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            navigate.popToRoot()
                        } label: {
                            Image(systemName: "house.fill")
                                .padding(8)
                        }
                        Button {
                            navigate.pop(3)
                        } label: {
                            Image(systemName: "pencil")
                                .padding(8)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .overlay(toastOverlay)
        .alert("Ricerca già salvata", isPresented: $showDuplicateAlert) {
            Button("Sovrascrivi", role: .destructive) {
                if let s = pendingSearch {
                    _ = searchManager.saveSearch(s, forceReplace: true)
                    showToast()
                }
            }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Hai già una ricerca con questi parametri. Vuoi sovrascriverla?")
        }
    }

    // MARK: - HEADER
//    private var headerSection: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(vehicleName)
//                .font(.title)
//                .fontWeight(.bold)
//
//            Text(versionAndEngine)
//                .font(.title3)
//
//            Text(vehicleListPrice)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//            Text(yearAndKms)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//    }

    // MARK: - HEADER
    private var headerSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionTitle("Informazioni veicolo", systemImage: "car.fill")

            SectionCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Informazioni veicolo")
                        .font(.title2)
                        .fontWeight(.bold)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(vehicleName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(versionAndEngine)
                            .font(.subheadline)
                        
                        Text(vehicleListPrice)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(yearAndKms)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
//        }
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            //            SectionTitle("Quanto varrà la tua auto?", systemImage: "chart.line.uptrend.xyaxis")
            
            SectionCard {
                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quanto varrà la tua auto?")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Scorri gli anni per conoscerne la valutazione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            ForecastChartExpandedView(
                                forecast: userCarForecast,
                                yearRange: yearRange,
                                selectedYear: selectedYear
                            )
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.headline)
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // CHART
                    ForecastChartView(
                        data: userCarForecast.data,
                        pessimisticData: userCarForecast.pessimisticData,
                        optimisticData: userCarForecast.optimisticData,
                        yearRange: yearRange,
                        selectedYear: $selectedYear,
                        desiredYaxisStepLabels: 8,
                        desiredXaxisStepLabels: 2,
                        baselinePrice: userCarForecast.purchasePrice
                    )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("Oscillazione del valore")
                            .font(.title2)
                        //  .foregroundColor(.secondary)
                        
                        Text("Abbiamo analizzato i dati a nostra disposizione e abbiamo calcolato un'intervallo di valori tra cui potrebbe trovarsi la tua auto. Ricorda che le cifre potrebbero variare a seconda di fattori esterni quali le condizioni generali del veicolo, i chilometri percorsi e altre caratteristiche.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let point = userCarForecast.data.first(where: { $0.year == selectedYear }) {
                            OscillationValueView(
                                selectedYear: $selectedYear,
                                minValue: point.value * 0.90,
                                baseValue: point.value,
                                maxValue: point.value * 1.10
                            )
                        }
                        
                        Text("Valore nel tempo")
                            .font(.title2)
                        
                        Text("Esplora la valutazione del tuo veicolo anno per anno tramite una tabella semplice e immediata, pensata per rendere la lettura dei dati più chiara.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        NavigationLink {
                            ForecastDetailedTableView(data: userCarForecast.data)
                        } label: {
                            Label("Visualizza i dati", systemImage: "tablecells")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(.vertical, 24)
                }
            }
            
        }
        
    }

    // MARK: - SLIDER
//    private var sliderSection: some View {
//        VStack(spacing: 16) {
//
//            Text("QUANTO VARRÀ LA TUA AUTO DOMANI?")
//                .font(.subheadline)
//                .fontWeight(.bold)
//
//            Text("Scorri gli anni per vedere la valutazione della tua auto")
//                .font(.caption)
//                .foregroundColor(.secondary)
//
//            HStack {
//                Text("Anno \(selectedYear)")
//                    .font(.headline)
//
//                Slider(
//                    value: Binding(
//                        get: { Double(selectedYear) },
//                        set: { selectedYear = Int($0) }
//                    ),
//                    in: yearRange,
//                    step: 1
//                )
//            }
//        }
//        .padding()
//        .background(Color.blue.opacity(0.08))
//        .cornerRadius(16)
//    }
//
//    // MARK: - CHART
//    private var chartSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//
//            Text("VALUTAZIONE VEICOLO NEGLI ANNI")
//                .font(.subheadline)
//                .fontWeight(.bold)
//
//            ForecastChartView(
//                data: userCarForecast.data,
//                pessimisticData: userCarForecast.pessimisticData,
//                optimisticData: userCarForecast.optimisticData,
//                selectedYear: $selectedYear
//            )
//        }
//    }

    // MARK: - OSCILLATION
//    private var oscillationSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionTitle("Oscillazione del valore", systemImage: "waveform.path.ecg")
//
//            SectionCard {
//                if let point = userCarForecast.data.first(where: { $0.year == selectedYear }) {
//                    OscillationValueView(
//                        minValue: point.value * 0.90,
//                        baseValue: point.value,
//                        maxValue: point.value * 1.10
//                    )
//                }
//            }
//        }
//    }
    
    // MARK: - BEST SELLING
    private var bestSellingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let best = bestSellingPoint {
                SectionCard {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quando conviene vendere")
                            .font(.title2)
                            .fontWeight(.bold)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Anno migliore")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(best.year))
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(Int(best.value.rounded()), format: .currency(code: "EUR"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(ColorLayout.green.auto)
                                Text("Valore stimato")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let trend = depreciationTrend {
                            VStack(alignment: .leading, spacing: 16) {
                                
                                Text("Andamento del valore")
                                    .font(.title2)
                                //  .foregroundColor(.secondary)
                                
                                Text("Analizzando i dati in nostro possesso di ogni anno, abbiamo assegnato questo indice per il tuo veicolo")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 16) {
                                    Image(systemName: trend.systemImage)
                                        .font(.title2)
                                        .foregroundColor(trend.color)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trend.title)
                                            .font(.headline)
                                            .foregroundColor(trend.color)
                                        
                                        Text(trend.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }

//                        NavigationLink(destination: ForecastHowCalculateDataInfoView()) {
//                            HStack(spacing: 6) {
//                                Spacer()
//                                Text("Per scoprirlo, clicca qui")
//                                    .font(.subheadline)
//                                    .fontWeight(.medium)
//                                    .foregroundColor(ColorLayout.primary.auto)
//
//                                Image(systemName: "chevron.right")
//                                    .font(.subheadline)
//                                    .fontWeight(.medium)
//                                    .foregroundColor(ColorLayout.primary.auto)
//                                Spacer()
//                            }
//                            .foregroundColor(.accentColor)
//                            .padding(.vertical, 8)
//                        }
//                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - DEPRECIATION INDICATOR
//    private var depreciationIndicatorSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionTitle("Andamento del valore", systemImage: "chart.line.downtrend.xyaxis")
//
//            if let trend = depreciationTrend {
//                SectionCard {
//                    HStack(spacing: 16) {
//                        Image(systemName: trend.systemImage)
//                            .font(.title2)
//                            .foregroundColor(trend.color)
//
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(trend.title)
//                                .font(.headline)
//                                .foregroundColor(trend.color)
//
//                            Text(trend.description)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//
//                        Spacer()
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - COMPARISON SECTION
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Come l'AI ci aiuta a calcolare i dati?")
                        .font(.title2)
                    
                    Text("Scopri come l'AI ci aiuta a calcolare i dati per aiutarti a prendere sempre la migliore decisione ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    aiExplanationSection
                        .popover(item: $selectedInfoCard) { card in
                            InfoCardPopupView(card: card)
                                .presentationCompactAdaptation(.sheet)
                        }
                }
            }
        }
    }
    
    
    // MARK: - EXPLANATION SECTION
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Confronto auto")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Scopri come si posiziona la tua auto rispetto ai modelli piu simili selezionati dall'app.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Match per alimentazione, segmento e fascia prezzo", systemImage: "line.3.horizontal.decrease.circle")
                        Label("Confronto del valore stimato anno per anno", systemImage: "chart.line.uptrend.xyaxis")
                        Label("Badge rapidi: Piu conveniente e Piu stabile", systemImage: "sparkles")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    NavigationLink {
                        VehicleComparisonView(referenceForecast: userCarForecast)
                    } label: {
                        Label("Apri confronto", systemImage: "arrow.left.arrow.right")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    // MARK: - ACTIONS
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
//            SectionTitle("Altro", systemImage: "ellipsis.circle")
            
//            NavigationLink {
//                ForecastDetailedTableView(data: userCarForecast.data)
//            } label: {
//                Label("Visualizza tabella di svalutazione", systemImage: "tablecells")
//            }
//            .buttonStyle(PrimaryButtonStyle())
            
            if !userCarForecast.isSaved && !userCarForecast.isExmample {
                Button {
                    saveSearchAction()
                } label: {
                    Label("Aggiungi al tuo garage", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
            }
            
//            NavigationLink(destination: ForecastHowCalculateDataInfoView()) {
//                Text("Come l'AI ci aiuta a calcolare i dati?")
//                    .font(.subheadline)
//                    .foregroundColor(.blue)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(.ultraThinMaterial)
//                    .cornerRadius(16)
//                    .shadow(radius: 2, y: 1)
//            }

            if userCarForecast.isExmample {
                Button {
                    if let url = StaticReportProvider.exampleReportURL() {
                        reportToPreview = IdentifiableURL(url: url)
                    }
                } label: {
                    Label("Scarica report", systemImage: "doc.text.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
                .sheet(item: $reportToPreview) { item in
                    NavigationStack {
                        PDFPreviewView(url: item.url)
                            .navigationTitle("Report")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    ShareLink(item: item.url) {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Info CARDS
    private var aiExplanationSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            if !showAllInfoCards {
                // 🔹 ICON PREVIEW (solo compatto)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(forecastInfoCards) { card in
                            ZStack {
                                Circle()
                                    .fill(ColorLayout.primary.auto.opacity(0.1))
                                    .frame(width: 48, height: 48)

                                Image(systemName: card.icon)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(ColorLayout.primary.auto)
                            }
                            .matchedGeometryEffect(id: card.id, in: aiNamespace)
                            .contentShape(Circle())
                            .onTapGesture {
                                selectedInfoCard = card
                            }
                        }

                    }
                }
                .transition(.opacity)
            }

            // 🔹 EXPANDED CONTENT
            if showAllInfoCards {
                VStack(spacing: 12) {
                    ForEach(forecastInfoCards) { card in
                        HStack(spacing: 12) {

                            ZStack {
                                Circle()
                                    .fill(ColorLayout.primary.auto.opacity(0.1))
                                    .frame(width: 44, height: 44)

                                Image(systemName: card.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(ColorLayout.primary.auto)
                            }
                            .matchedGeometryEffect(
                                id: card.id,
                                in: aiNamespace
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.title)
                                    .font(.headline)

                                Text(card.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(ColorLayout.cardRowBackgroud.auto)
                        .cornerRadius(16)
                    }
                }
                .transition(.opacity)
            }


            // 🔹 CTA
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showAllInfoCards.toggle()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(showAllInfoCards ? "Mostra meno" : "Scopri di più")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Image(systemName: showAllInfoCards ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                    Spacer()
                }
                .foregroundColor(ColorLayout.primary.auto)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        
    }

    // MARK: - Overlay
    private var toastOverlay: some View {
        Group {
            if showSavedToast {
                Label("GARAGE AGGIORNATO", systemImage: "door.garage.closed")
//                Text("GARAGE AGGIORNATO")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Actions
    private func saveSearchAction() {
        let search = SavedSearch(
            brand: userCarForecast.userCar.brand,
            model: userCarForecast.userCar.model,
            engine: userCarForecast.userCar.engine,
            registrationYear: userCarForecast.userCar.registrationYear,
            actualKm: userCarForecast.userCar.actualKm,
            version: userCarForecast.userCar.version,
            color: userCarForecast.userCar.color,
            zone: userCarForecast.userCar.zone,
            certifiedManintenance: userCarForecast.userCar.certifiedManintenance,
            optionals: userCarForecast.userCar.optionals,
            numberOfOwners: userCarForecast.userCar.numberOfOwners ?? 1,
            purchasePrice: userCarForecast.purchasePrice,
            data: userCarForecast.data,
            optmisticData: userCarForecast.optimisticData,
            pessimisticData: userCarForecast.pessimisticData
        )

        switch searchManager.saveSearch(search) {
        case .saved, .replaced:
            showToast()
        case .duplicate:
            pendingSearch = search
            showDuplicateAlert = true
        }
    }

    private func showToast() {
        withAnimation {
            showSavedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSavedToast = false
            }
        }
    }
}


//struct ForecastView: View {
//    @EnvironmentObject var searchManager: SearchManager
//
//    var userCarForecast: UserCarForecast
//
//    // UI state
//    @State private var showSavedToast = false
//    @State private var showDuplicateAlert = false
//    @State private var pendingSearch: SavedSearch?
//
//    @State private var selectedYear: Int
//
//    init(userCarForecast: UserCarForecast) {
//        self.userCarForecast = userCarForecast
//        let currentYear = Calendar.current.component(.year, from: Date())
//        _selectedYear = State(initialValue: currentYear)
//    }
//
//    var vehicleName: String {
//        "\(userCarForecast.userCar.brand) \(userCarForecast.userCar.model)"
//    }
//
//    var versionAndEngine: String {
//        if let version = userCarForecast.userCar.version {
//            return "\(version) • \(userCarForecast.userCar.engine)"
//        } else {
//            return userCarForecast.userCar.engine
//        }
//    }
//
//    var yearAndKms: String {
//        "\(userCarForecast.userCar.registrationYear) • \(userCarForecast.userCar.actualKm) km"
//    }
//
//    var currentValue: Double {
//        userCarForecast.data.first?.value ?? userCarForecast.purchasePrice
//    }
//
//    var body: some View {
//
//        let currentYear = Calendar.current.component(.year, from: Date())
//        let startYearRange = currentYear
//        let endYearRange = userCarForecast.userCar.registrationYear + 20
//
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
////            VStack(spacing: 20) {
//
//                //MARK: - HEADER
//                VStack(alignment: .leading, spacing: 6.0) {
//                    Text(vehicleName)
//                        .font(.title)
//                        .fontWeight(.bold)
//                    Text(versionAndEngine)
//                        .font(.title3)
//                    Text(yearAndKms)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//
//                //MARK: - SLIDER
//                Text("QUANTO VARRÀ LA TUA AUTO DOMANI?")
//                    .font(.subheadline)
//                    .fontWeight(.bold)
//
//                VStack(spacing: 16) {
//                    Text("Scorri gli anni per vedere la valutazione della tua auto")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//
//                    HStack {
//                        Text("Anno \(selectedYear)")
//                            .font(.headline)
//
//                        Slider(
//                            value: Binding(
//                                get: { Double(selectedYear) },
//                                set: { newVal in selectedYear = Int(newVal) }
//                            ),
//                            in: Double(startYearRange)...Double(endYearRange),
//                            step: 1
//                        )
//                    }
//                }
//                .padding()
//                .background(Color.blue.opacity(0.08))
//                .cornerRadius(16)
//
//                //MARK: - CHART
//                Text("VALUTAZIONE VEICOLO NEGLI ANNI")
//                    .font(.subheadline)
//                    .fontWeight(.bold)
//                ForecastChartView(
//                    data: userCarForecast.data,
//                    pessimisticData: userCarForecast.pessimisticData,
//                    optimisticData: userCarForecast.optimisticData,
//                    selectedYear: $selectedYear
//                )
//
//                //MARK: - EXTREMES VALUE
//                Text("OSCILLAZIONE DEL VALORE")
//                    .font(.subheadline)
//                    .fontWeight(.bold)
//
//                if let point = userCarForecast.data.first(where: { $0.year == Int(selectedYear) }) {
//                    OscillationValueView(
//                        minValue: point.value * 0.90,
//                        baseValue: point.value,
//                        maxValue: point.value * 1.10
//                    )
//                }
//
//                //MARK: - BUTTTONS
//                if !userCarForecast.isExampleOrSaved {
//                    Button(action: saveSearchAction) {
//                        Label("Aggiungi al tuo garage", systemImage: "square.and.arrow.down")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(.thinMaterial)
//                            .cornerRadius(16)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .stroke(Color.teal, lineWidth: 1.5)
//                            )
//                    }
//                    .shadow(radius: 2, y: 1)
//                }
//
//                NavigationLink(destination: ForecastHowCalculateDataInfoView()) {
//                    Text("Come l'AI ci aiuta a calcolare i dati?")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(16)
//                        .shadow(radius: 2, y: 1)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical)
//        }
//        .navigationTitle("Valore futuro")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            Button("Modifica") {
//                print("modifica")
//            }
//        }
//
//        .overlay(
//            Group {
//                if showSavedToast {
//                    Text("✅ Ricerca salvata")
//                        .font(.headline)
//                        .padding(.horizontal, 24)
//                        .padding(.vertical, 14)
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(16)
//                        .shadow(radius: 6)
//                        .transition(.scale.combined(with: .opacity))
//                        .zIndex(1)
//                }
//            },
//            alignment: .center
//        )
//
//        // Duplicate Alert
//        .alert("Ricerca già salvata", isPresented: $showDuplicateAlert) {
//            Button("Sovrascrivi", role: .destructive) {
//                if let s = pendingSearch {
//                    _ = searchManager.saveSearch(s, forceReplace: true)
//                    showToast()
//                }
//            }
//            Button("Annulla", role: .cancel) {}
//        } message: {
//            Text("Hai già una ricerca con questi parametri. Vuoi sovrascriverla?")
//        }
//    }
//
//    private func saveSearchAction() {
//        let search = SavedSearch(
//            brand: userCarForecast.userCar.brand,
//            model: userCarForecast.userCar.model,
//            engine: userCarForecast.userCar.engine,
//            registrationYear: userCarForecast.userCar.registrationYear,
//            actualKm: userCarForecast.userCar.actualKm,
//            version: userCarForecast.userCar.version,
//            color: userCarForecast.userCar.color,
//            zone: userCarForecast.userCar.zone,
//            certifiedManintenance: userCarForecast.userCar.certifiedManintenance,
//            optionals: userCarForecast.userCar.optionals,
//            numberOfOwners: userCarForecast.userCar.numberOfOwners ?? 1,
//            purchasePrice: userCarForecast.purchasePrice,
//            data: userCarForecast.data,
//            optmisticData: userCarForecast.optimisticData,
//            pessimisticData: userCarForecast.pessimisticData
//        )
//
//        switch searchManager.saveSearch(search) {
//        case .saved, .replaced:
//            showToast()
//        case .duplicate:
//            pendingSearch = search
//            showDuplicateAlert = true
//        }
//    }
//
//    private func showToast() {
//        withAnimation {
//            showSavedToast = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation {
//                showSavedToast = false
//            }
//        }
//    }
//}
