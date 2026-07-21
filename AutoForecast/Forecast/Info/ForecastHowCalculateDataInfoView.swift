//
//  ForecastHowCalculateDataInfoView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ForecastInfoCard: Identifiable, Equatable {
    let id = UUID()
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let icon: String
}

let forecastInfoCards: [ForecastInfoCard] = [
    .init(title: "CHILOMETRAGGIO",
          description: "Il chilometraggio viene normalizzato rispetto alla percorrenza media annua e applicato come fattore correttivo sulla curva di valore residuo.",
          icon: "speedometer"),
    .init(title: "MANUTENZIONE CERTIFICATA",
          description: "La presenza di storico manutentivo verificabile riduce il coefficiente di svalutazione e migliora l’affidabilità della stima.",
          icon: "checkmark.seal.text.page"),
    .init(title: "NUMERO DI PROPRIETARI",
          description: "Il numero di intestazioni precedenti viene considerato come indicatore di continuità e incide negativamente sul valore residuo all’aumentare dei passaggi di proprietà.",
          icon: "person.3.sequence"),
    .init(title: "COLORE",
          description: "Il colore è ponderato in base alla liquidità di mercato e alla domanda storica per modello e segmento.",
          icon: "paintpalette"),
    .init(title: "ZONA DI VENDITA",
          description: "La stima tiene conto delle dinamiche territoriali di domanda e offerta, con correzioni legate al mercato locale.",
          icon: "map"),
    .init(title: "CATEGORIA AUTO",
          description: "Ogni categoria è associata a curve di svalutazione dedicate.",
          icon: "car.side"),
    .init(title: "ALIMENTAZIONE",
          description: "La tipologia di alimentazione influisce sulla previsione.",
          icon: "fuelpump"),
    .init(title: "OPTIONAL E DOTAZIONI",
          description: "La presenza di optional rilevanti contribuisce alla tenuta del valore.",
          icon: "menucard"),
    .init(title: "MODELLI PREDITTIVI AVANZATI",
          description: "Modelli AI e ML addestrati su grandi serie storiche.",
          icon: "brain")
]

// MARK: - Info CARDS
struct ForecastInfoCardView: View {
    let card: ForecastInfoCard

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ColorLayout.primary.auto.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: card.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ColorLayout.primary.auto)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.headline)

                Text(card.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
//        .background(ColorLayout.cardRowBackgroud.auto)
//        .cornerRadius(16)
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
//        )
    }
}

struct InfoCardPopupView: View {
    let card: ForecastInfoCard

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 12) {
                    Image(systemName: card.icon)
                        .font(.title2)
                        .foregroundColor(ColorLayout.primary.auto)
                    
                    Text("\(card.title)".uppercased())
                        .font(.headline)
                }
                
                Text(card.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                //                .fixedSize(horizontal: false, vertical: true)
                
            }
            .padding(24)
        }
//        .padding(24)
        .presentationDetents([.height(120)])
        .presentationDragIndicator(.hidden)
    }
}

//struct ForecastHowCalculateDataInfoView: View {
//
//    struct InfoCard: Identifiable {
//        let id = UUID()
//        let title: String
//        let description: String
//        let icon: String
//    }
//
//    let cards: [InfoCard] = [
//        .init(title: "CHILOMETRAGGIO",
//              description: "Il chilometraggio viene normalizzato rispetto alla percorrenza media annua e applicato come fattore correttivo sulla curva di valore residuo.",
//              icon: "speedometer"), // numbers.rectangle
//        .init(title: "MANUTENZIONE CERTIFICATA",
//              description: "La presenza di storico manutentivo verificabile riduce il coefficiente di svalutazione e migliora l’affidabilità della stima.",
//              icon: "checkmark.seal.text.page"),
//        .init(title: "NUMERO DI PROPRIETARI",
//              description: "Il numero di intestazioni precedenti viene considerato come indicatore di continuità e incide negativamente sul valore residuo all’aumentare dei passaggi di proprietà.",
//              icon: "person.3.sequence"),
//        .init(title: "COLORE",
//              description: "Il colore è ponderato in base alla liquidità di mercato e alla domanda storica per modello e segmento.",
//              icon: "paintpalette"),
//        .init(title: "ZONA DI VENDITA",
//              description: "La stima tiene conto delle dinamiche territoriali di domanda e offerta, con correzioni legate al mercato locale.",
//              icon: "map"),
//        .init(title: "CATEGORIA AUTO",
//              description: "Ogni categoria è associata a curve di svalutazione dedicate, derivate da andamenti storici e comportamenti di acquisto.", icon: "car.side"),
//        .init(title: "ALIMENTAZIONE",
//              description: "La tipologia di alimentazione influisce sulla previsione in funzione di normative, costi di esercizio e trend di mercato consolidati.", icon: "fuelpump"),
//        .init(title: "OPTIONAL E DOTAZIONI",
//              description: "La presenza di optional rilevanti e richiesti dal mercato contribuisce a migliorare la tenuta del valore, secondo pesi specifici per modello e segmento.", icon: "menucard"),
//        .init(title: "MODELLI PREDITTIVI AVANZATI",
//              description: "I dati vengono elaborati tramite modelli di intelligenza artificiale e machine learning, addestrati su grandi serie storiche e dati di mercato reali.\nQuesti modelli analizzano correlazioni, trend e anomalie, affinando nel tempo le curve di svalutazione e migliorando la precisione delle previsioni future.", icon: "brain")
//    ]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
////                Text("Come vengono calcolati i dati")
////                    .font(.title2)
////                    .fontWeight(.bold)
////                    .padding(.horizontal)
//
//                ForEach(cards) { card in
//                    HStack(alignment: .center, spacing: 12) {
//                        ZStack {
//                            Circle()
//                                .fill(ColorLayout.primary.auto.opacity(0.1))
//                                .frame(width: 44, height: 44)
//                            
//                            Image(systemName: card.icon)
//                                .font(.system(size: 20, weight: .semibold))
//                                .foregroundColor(ColorLayout.primary.auto)
//                        }
//                        .frame(width: 44, height: 44)
//                        
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(card.title)
//                                .font(.headline)
//                            Text(card.description)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
////                    .background(.ultraThinMaterial)
//                    .background(ColorLayout.cardRowBackgroud.auto)
//                    .cornerRadius(16)
////                    .shadow(radius: 3, y: 2)
//                    .padding(.horizontal)
//                }
//
//            }
//            .padding(.vertical)
//        }
//        .background(ColorLayout.appBackround.auto)
//        .navigationTitle("Come vengono calcolati i dati")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

