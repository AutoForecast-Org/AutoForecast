//
//  AuthStore.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import Foundation
import AuthenticationServices
import Supabase

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var session: Session?
    @Published private(set) var isLoading = true
    @Published private(set) var isAuthenticating = false
    @Published var errorMessage: String?

    private let client: SupabaseClient
    private var authStateTask: Task<Void, Never>?

    var user: User? { session?.user }
    var isAuthenticated: Bool { session != nil }

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client

        authStateTask = Task { [weak self] in
            for await (_, session) in client.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                self?.session = session
                self?.isLoading = false
            }
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    func signInWithApple() async {
        guard !isAuthenticating else { return }

        isAuthenticating = true
        errorMessage = nil
        defer { isAuthenticating = false }

        do {
            let credentials = try await AppleSignInCoordinator.signIn()
            try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: credentials.identityToken,
                    nonce: credentials.nonce
                )
            )
        } catch let error as ASAuthorizationError where error.code == .canceled {
            // The user deliberately dismissed the native Apple authorization sheet.
        } catch {
            errorMessage = "Non è stato possibile completare l'accesso con Apple. Riprova."
        }
    }

    func signOut() async {
        errorMessage = nil

        do {
            try await client.auth.signOut()
        } catch {
            errorMessage = "Non è stato possibile uscire dall'account. Riprova."
        }
    }

    /// Deletes the authenticated user and all associated server-side data.
    /// The Edge Function validates the JWT and uses the service role only on the server.
    func deleteAccount() async -> Bool {
        guard isAuthenticated else { return true }

        errorMessage = nil
        do {
            try await client.functions.invoke("delete-account")
            try? await client.auth.signOut()
            session = nil
            return true
        } catch {
            errorMessage = "Non è stato possibile eliminare l'account. Riprova più tardi."
            return false
        }
    }
}
