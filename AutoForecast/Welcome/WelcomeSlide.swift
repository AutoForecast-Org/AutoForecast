//
//  WelcomeSlide.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct WelcomeSlide: Identifiable {
    let id = UUID()
    let imageName: String
    let systemImage: String
    let title: String
    let description: String
    let highlights: [String]
    let footerNote: String?
}

let slides = [
    WelcomeSlide(
        imageName: "Placeholder",
        systemImage: "car.front.waves.up",
        title: "Benvenuto in AutoForecast",
        description: "Stimiamo il valore attuale e futuro della tua auto per aiutarti a scegliere quando vendere, tenere o confrontare il veicolo.",
        highlights: [
            "Analisi guidata in pochi passaggi",
            "Valutazione in euro anno per anno",
            "Risultato semplice da leggere"
        ],
        footerNote: "Le stime sono indicative e si aggiornano in base ai dati inseriti."
    ),
    WelcomeSlide(
        imageName: "Placeholder",
        systemImage: "chart.line.uptrend.xyaxis",
        title: "Come funziona la previsione",
        description: "L'algoritmo combina anno, km, alimentazione, manutenzione e altri parametri per calcolare la curva di svalutazione del tuo veicolo.",
        highlights: [
            "Scenario centrale, ottimistico e pessimista",
            "Focus su valore odierno e anno selezionato",
            "Scostamento percentuale dal prezzo di listino"
        ],
        footerNote: nil
    ),
    WelcomeSlide(
        imageName: "Placeholder",
        systemImage: "arrow.left.arrow.right",
        title: "Confronta e salva nel Garage",
        description: "Confronta auto simili per capire quale svaluta meno nel tempo e salva le ricerche importanti nel tuo Garage personale.",
        highlights: [
            "Confronto diretto tra modelli simili",
            "Dettaglio perdita in percentuale",
            "Recupero rapido delle ricerche salvate"
        ],
        footerNote: "Puoi sempre modificare i parametri e rigenerare la previsione."
    ),
    WelcomeSlide(
        imageName: "Placeholder",
        systemImage: "flag.checkered.2.crossed",
        title: "Pronto a iniziare",
        description: "Inserisci i dati della tua auto e scopri subito la previsione completa con grafico, sintesi e suggerimenti operativi.",
        highlights: [
            "Prima analisi in meno di un minuto",
            "Report di esempio sempre disponibile",
            "Esperienza pensata per decisioni veloci"
        ],
        footerNote: nil
    )
]
