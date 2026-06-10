//
//  BiometricAuthManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation
import LocalAuthentication

@Observable
final class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    static let maxAttempts = 3

    private(set) var failureCount = 0
    private(set) var isLocked = false

    private init() {}

    var isFaceIDEnabled: Bool {
        UserDefaults.standard.bool(forKey: "rm_faceIDEnabled")
    }

    func authorizeRemoval(reason: String) async -> Bool {
		guard !self.isLocked else { return false }

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return true
        }

        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
			self.failureCount = 0
            return true
        } catch {
			self.failureCount += 1
			if self.failureCount >= Self.maxAttempts {
				self.isLocked = true
            }
            return false
        }
    }

    func resetLock() {
        self.failureCount = 0
        self.isLocked = false
    }

    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return true
        }
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return true
        } catch {
            return false
        }
    }
}
