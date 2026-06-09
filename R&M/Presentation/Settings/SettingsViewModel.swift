//
//  SettingsViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation
import LocalAuthentication

@Observable
final class SettingsViewModel {

    enum BiometricStatus {
        case authorized
        case denied
        case notEnrolled
        case notAvailable
        case locked
    }

    private(set) var biometricStatus: BiometricStatus = .notAvailable
    private(set) var biometryType: LABiometryType = .none
    private(set) var isAuthenticating = false

    // App-level preference stored in UserDefaults
    var isFaceIDEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "rm_faceIDEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "rm_faceIDEnabled") }
    }

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

        // OS permission lost/denied — keep app preference in sync
		if self.biometricStatus != .authorized {
			self.isFaceIDEnabled = false
        }
    }

    func enableFaceID(reason: String) async {
		guard self.biometricStatus != .notAvailable else { return }
		self.isAuthenticating = true

        let context = LAContext()
        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
			self.checkBiometricStatus()
			if self.biometricStatus == .authorized {
				self.isFaceIDEnabled = true
            }
        } catch {
			self.checkBiometricStatus()
			self.isFaceIDEnabled = false
        }

		self.isAuthenticating = false
    }

    func disableFaceID() {
		self.isFaceIDEnabled = false
    }
}
