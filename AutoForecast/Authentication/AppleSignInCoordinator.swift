//
//  AppleSignInCoordinator.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import AuthenticationServices
import CryptoKit
import UIKit

struct AppleSignInCredentials {
    let identityToken: String
    let nonce: String
}

@MainActor
final class AppleSignInCoordinator: NSObject {
    private static var activeCoordinator: AppleSignInCoordinator?

    private var continuation: CheckedContinuation<AppleSignInCredentials, Error>?

    static func signIn() async throws -> AppleSignInCredentials {
        let coordinator = AppleSignInCoordinator()
        activeCoordinator = coordinator

        return try await withCheckedThrowingContinuation { continuation in
            coordinator.continuation = continuation

            let nonce = Self.randomNonce()
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = Self.sha256(nonce)

            coordinator.nonce = nonce

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = coordinator
            controller.presentationContextProvider = coordinator
            controller.performRequests()
        }
    }

    private var nonce = ""

    private func finish(with result: Result<AppleSignInCredentials, Error>) {
        let continuation = continuation
        self.continuation = nil
        Self.activeCoordinator = nil

        switch result {
        case let .success(credentials):
            continuation?.resume(returning: credentials)
        case let .failure(error):
            continuation?.resume(throwing: error)
        }
    }

    private static func randomNonce(length: Int = 32) -> String {
        let characters = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var nonce = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            guard SecRandomCopyBytes(kSecRandomDefault, 1, &random) == errSecSuccess else {
                fatalError("Impossibile generare un nonce sicuro per Sign in with Apple.")
            }

            if random < characters.count {
                nonce.append(characters[Int(random)])
                remainingLength -= 1
            }
        }

        return nonce
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else {
                finish(with: .failure(AppleSignInError.missingIdentityToken))
                return
            }

            finish(with: .success(.init(identityToken: identityToken, nonce: nonce)))
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            finish(with: .failure(error))
        }
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
}

private enum AppleSignInError: LocalizedError {
    case missingIdentityToken

    var errorDescription: String? {
        "Apple non ha restituito un token di accesso valido. Riprova."
    }
}
