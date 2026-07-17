//
//  OptionalInfoView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

// MARK: - Optional Info View
struct OptionalInfoView: View {
    @Binding var selectedBrand: String?
    @Binding var selectedModel: String?
    @Binding var selectedEngine: String?
    var availableVersions: [String]
    @Binding var selectedVersion: String?
    @Binding var selectedColor: String?
    @Binding var selectedZone: String?
    @Binding var numberOfOwners: Int
    @Binding var selectedMaintenance: String?
    @Binding var selectedOptionals: [String]
    
    let colors: [String]
    let zones: [String]
    let ownersRange: ClosedRange<Int>
    let maintenanceOptions: [String]
    let optionals: [String]

    @State private var showVersionSelection = false
    @State private var showColorSelection = false
    @State private var showZoneSelection = false
    @State private var showMaintenanceSelection = false
    @State private var showOptionalsSelection = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Version
                VStack(spacing: 0) {
                    Button {
                        showVersionSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "car.badge.gearshape")
                                .foregroundColor(ColorLayout.primary.auto)
                                .frame(width: 24)
                            Text("Versione")
                                .foregroundColor(ColorLayout.primary.auto)
                            Spacer()
                            Text(selectedVersion ?? "Nessuna selezione")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        .padding()
                        .background(ColorLayout.cardRowBackgroud.auto)
                        .cornerRadius(12)
                    }

                    NavigationLink(
                        destination: SearchableSelectionListView(
                            title: "Versione",
                            items: availableVersions,
                            showFeedbackLabel: true,
                            selectedItem: Binding(
                                get: { selectedVersion ?? "" },
                                set: { selectedVersion = $0 }
                            )
                        ),
                        isActive: $showVersionSelection
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                
                // Colors
                VStack(spacing: 0) {
                    Button {
                        showColorSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(ColorLayout.primary.auto)
                                .frame(width: 24)
                            Text("Colore")
                                .foregroundColor(ColorLayout.primary.auto)
                            Spacer()
                            Text(selectedColor ?? "Nessuna selezione")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        .padding()
                        .background(ColorLayout.cardRowBackgroud.auto)
                        .cornerRadius(12)
                    }

                    NavigationLink(
                        destination: SearchableSelectionListView(
                            title: "Selezione Colore",
                            items: colors,
                            showFeedbackLabel: false,
                            selectedItem: Binding(
                                get: { selectedColor ?? "" },
                                set: { selectedColor = $0 }
                            )
                        ),
                        isActive: $showColorSelection
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }

                // Location zone
                VStack(spacing: 0) {
                    Button {
                        showZoneSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "map")
                                .foregroundColor(ColorLayout.primary.auto)
                                .frame(width: 24)
                            Text("Zona geografica")
                                .foregroundColor(ColorLayout.primary.auto)
                            Spacer()
                            Text(selectedZone ?? "Nessuna selezione")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        .padding()
                        .background(ColorLayout.cardRowBackgroud.auto)
                        .cornerRadius(12)
                    }

                    NavigationLink(
                        destination: SearchableSelectionListView(
                            title: "Zona",
                            items: zones,
                            showFeedbackLabel: false,
                            selectedItem: Binding(
                                get: { selectedZone ?? "" },
                                set: { selectedZone = $0 }
                            )
                        ),
                        isActive: $showZoneSelection
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }

                // Maintenance
                VStack(spacing: 0) {
                    Button {
                        showMaintenanceSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.seal.text.page")
                                .foregroundColor(ColorLayout.primary.auto)
                                .frame(width: 24)
                            Text("Manutenzione")
                                .foregroundColor(ColorLayout.primary.auto)
                            Spacer()
                            Text(selectedMaintenance ?? "Nessuna selezione")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        .padding()
                        .background(ColorLayout.cardRowBackgroud.auto)
                        .cornerRadius(12)
                    }

                    NavigationLink(
                        destination: SearchableSelectionListView(
                            title: "Manutenzione",
                            items: maintenanceOptions,
                            showFeedbackLabel: false,
                            selectedItem: Binding(
                                get: { selectedMaintenance ?? "" },
                                set: { selectedMaintenance = $0 }
                            )
                        ),
                        isActive: $showMaintenanceSelection
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                
                // Optionals
                VStack(spacing: 0) {
                    Button {
                        showOptionalsSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "menucard")
                                .foregroundColor(ColorLayout.primary.auto)
                                .frame(width: 24)
                            Text("Optionals")
                                .foregroundColor(ColorLayout.primary.auto)
                            Spacer()
                            
                            Text(selectedOptionals.isEmpty
                                 ? "Nessuna selezione"
                                 : "\(selectedOptionals.count) " + (selectedOptionals.count == 1 ? "selezionato" : "selezionati"))
                            .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        .padding()
                        .background(ColorLayout.cardRowBackgroud.auto)
                        .cornerRadius(12)
                    }

                    NavigationLink(
                        destination: SearchableSelectionListMultiView(
                            title: "Optionals",
                            items: optionals,
                            selectedItems: $selectedOptionals
                        ),
                        isActive: $showOptionalsSelection
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                
                // Owners
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "person.3.sequence")
                            .foregroundColor(ColorLayout.primary.auto)
                            .frame(width: 24)
                        Text("Numero di proprietari")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Stepper(value: Binding(
                        get: { numberOfOwners },
                        set: { numberOfOwners = $0 }
                    ), in: ownersRange) {
                        Text("\(numberOfOwners)")
                            .font(.headline)
                            .foregroundColor(ColorLayout.primary.auto)
                    }
                }
                .padding()
                .background(ColorLayout.cardRowBackgroud.auto)
                .cornerRadius(12)
            }
        }
    }
}

struct SelectionListSingleChoice: View {
    let title: String
    let items: [String]
    @Binding var selectedItem: String?

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List(items, id: \.self) { item in
            HStack {
                Text(item)
                Spacer()
                if selectedItem == item {
                    Image(systemName: "checkmark")
                        .foregroundColor(ColorLayout.secondary.auto)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedItem = item
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle(title)
    }
}
