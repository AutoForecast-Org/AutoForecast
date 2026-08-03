//
//  ProfileView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeletionConfirmation = false
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Email", value: authStore.user?.email ?? "Non disponibile")
                    LabeledContent("ID utente", value: authStore.user?.id.uuidString ?? "Non disponibile")
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Section {
                    Button("Esci", systemImage: "rectangle.portrait.and.arrow.right") {
                        Task {
                            await authStore.signOut()
                            dismiss()
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeletionConfirmation = true
                    } label: {
                        Label("Elimina account", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                    .disabled(isDeleting)
                } footer: {
                    Text("L'eliminazione rimuove definitivamente l'account e i dati associati dal server. Questa operazione non può essere annullata.")
                }

                if let errorMessage = authStore.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fine") { dismiss() }
                }
            }
            .confirmationDialog(
                "Eliminare definitivamente l'account?",
                isPresented: $showDeletionConfirmation,
                titleVisibility: .visible
            ) {
                Button("Elimina definitivamente", role: .destructive) {
                    Task {
                        isDeleting = true
                        let wasDeleted = await authStore.deleteAccount()
                        isDeleting = false
                        if wasDeleted { dismiss() }
                    }
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Perderai definitivamente l'accesso e tutti i dati associati al tuo account.")
            }
            .overlay {
                if isDeleting {
                    ProgressView("Eliminazione account…")
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }
}
