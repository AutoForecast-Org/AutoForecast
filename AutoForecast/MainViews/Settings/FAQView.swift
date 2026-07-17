//
//  FAQView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct FAQView: View {
    
    // MARK: - Domande e risposte
    struct FAQItem: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
    }
    
    let faqItems: [FAQItem] = [
        FAQItem(
            question: "Come funziona la previsione di valutazione dell'auto?",
            answer: "La valutazione si basa su modello, anno, chilometraggio e stato dell'auto. L'algoritmo stima il valore di mercato attuale e futuro."
        ),
        FAQItem(
            question: "Posso salvare più auto?",
            answer: "Sì, puoi salvare al massimo 5 auto. Le trovi nella sezione 'Preferiti' della Home."
        ),
        FAQItem(
            question: "Come posso inviare un feedback?",
            answer: "Vai nella sezione Impostazioni → Supporto → Invia feedback. Puoi inviare suggerimenti o segnalare problemi."
        ),
        FAQItem(
            question: "L'app è gratuita?",
            answer: "Sì, l'app è completamente gratuita. Alcune funzionalità avanzate potrebbero richiedere un account premium in futuro."
        )
    ]
    
    @State private var expandedItems: Set<UUID> = []
    
    var body: some View {
        List {
            ForEach(faqItems) { item in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedItems.contains(item.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedItems.insert(item.id)
                            } else {
                                expandedItems.remove(item.id)
                            }
                        }
                    ),
                    content: {
                        Text(item.answer)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    },
                    label: {
                        Text(item.question)
                            .font(.headline)
                    }
                )
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("FAQ")
    }
}

// MARK: - Preview
//struct FAQView_Previews: PreviewProvider {
//    static var previews: some View {
//        FAQView()
//    }
//}
