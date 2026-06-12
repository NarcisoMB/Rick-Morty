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

    enum Status {
        case authorized, denied, notEnrolled, notAvailable, locked
    }

    private(set) var failureCount = 0
    private(set) var isLocked = false
    private(set) var pendingChallenge: ArithmeticChallenge?
    private(set) var biometricStatus: Status = .notAvailable
    private(set) var biometryType: LABiometryType = .none
    private(set) var isAuthenticating = false

    private var challengeContinuation: CheckedContinuation<Bool, Never>?

    private init() {}

    var isFaceIDEnabled: Bool {
        UserDefaults.standard.bool(forKey: "rm_faceIDEnabled")
    }

    // MARK: - Status management

    func checkBiometricStatus() {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        self.biometryType = context.biometryType

        if available {
            self.biometricStatus = .authorized
            return
        }

        guard let laError = error as? LAError else {
            self.biometricStatus = .notAvailable
            return
        }

        switch laError.code {
        case .biometryNotEnrolled:
            self.biometricStatus = .notEnrolled
        case .biometryNotAvailable:
            self.biometricStatus = biometryType == .none ? .notAvailable : .denied
        case .biometryLockout:
            self.biometricStatus = .locked
        default:
            self.biometricStatus = .notAvailable
        }

        if self.biometricStatus != .authorized {
            UserDefaults.standard.set(false, forKey: "rm_faceIDEnabled")
        }
    }

    func enableFaceID(reason: String) async {
        guard self.biometricStatus != .notAvailable else { return }
        self.isAuthenticating = true

        let context = LAContext()
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            self.checkBiometricStatus()
            if self.biometricStatus == .authorized {
                UserDefaults.standard.set(true, forKey: "rm_faceIDEnabled")
            }
        } catch {
            self.checkBiometricStatus()
            UserDefaults.standard.set(false, forKey: "rm_faceIDEnabled")
        }

        self.isAuthenticating = false
    }

    func disableFaceID() {
        UserDefaults.standard.set(false, forKey: "rm_faceIDEnabled")
    }

    // MARK: - Auth

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

    // MARK: - Challenge

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
        let lhs = Int.random(in: 1...20)
        let rhs = Int.random(in: 1...20)
        if Bool.random() {
            return ArithmeticChallenge(question: "\(lhs) + \(rhs) = ?", answer: lhs + rhs)
        } else {
            let big = max(lhs, rhs), small = min(lhs, rhs)
            return ArithmeticChallenge(question: "\(big) − \(small) = ?", answer: big - small)
        }
    }
}
