//
//  BiometricAuthManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation
import LocalAuthentication

struct ArithmeticChallenge: Identifiable {
    let id = UUID()
    let question: String
    let answer: Int
}

@Observable
final class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    static let maxAttempts = 3

    private(set) var failureCount = 0
    private(set) var isLocked = false
    private(set) var pendingChallenge: ArithmeticChallenge?

    private var challengeContinuation: CheckedContinuation<Bool, Never>?

    private init() {}

    var isFaceIDEnabled: Bool {
        UserDefaults.standard.bool(forKey: "rm_faceIDEnabled")
    }

    func authorizeRemoval(reason: String) async -> Bool {
        guard !self.isLocked else { return false }
        if isFaceIDEnabled, await tryFaceID(reason: reason, trackFailures: true) {
            return true
        }
        return await waitForChallenge()
    }

    func authenticate(reason: String) async -> Bool {
        if isFaceIDEnabled, await tryFaceID(reason: reason, trackFailures: false) {
            return true
        }
        return await waitForChallenge()
    }

    func resetLock() {
        self.failureCount = 0
        self.isLocked = false
    }

    func submitChallengeAnswer(_ answer: Int) {
		guard let challenge = self.pendingChallenge else { return }
        let correct = answer == challenge.answer
		self.pendingChallenge = nil
		self.challengeContinuation?.resume(returning: correct)
		self.challengeContinuation = nil
    }

    func cancelChallenge() {
		self.pendingChallenge = nil
		self.challengeContinuation?.resume(returning: false)
		self.challengeContinuation = nil
    }

    // MARK: - Private

    private func tryFaceID(reason: String, trackFailures: Bool) async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            if trackFailures { self.failureCount = 0 }
            return true
        } catch {
            if trackFailures {
                self.failureCount += 1
                if self.failureCount >= Self.maxAttempts { self.isLocked = true }
            }
            return false
        }
    }

    private func waitForChallenge() async -> Bool {
        await withCheckedContinuation { continuation in
            self.challengeContinuation = continuation
            self.pendingChallenge = self.generateChallenge()
        }
    }

    private func generateChallenge() -> ArithmeticChallenge {
        let stDigit = Int.random(in: 1...20)
        let ndDigit = Int.random(in: 1...20)
        if Bool.random() {
            return ArithmeticChallenge(question: "\(stDigit) + \(ndDigit) = ?", answer: stDigit + ndDigit)
        } else {
            let big = max(stDigit, ndDigit), small = min(stDigit, ndDigit)
            return ArithmeticChallenge(question: "\(big) − \(small) = ?", answer: big - small)
        }
    }
}
