//
// SettingsView.swift
// R&M
//
// Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(BiometricAuthManager.self) private var biometricAuth
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    languageSection
                    securitySection
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .background(Color.rmBackground)
            .colorScheme(.dark)
            .task { biometricAuth.checkBiometricStatus() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { biometricAuth.checkBiometricStatus() }
            }
            .toolbar {
                ToolbarItem {
                    VStack(spacing: 2) {
                        Text("Rick & Morty")
                            .foregroundStyle(.white)
                        Text(self.lang.localized(LocalizationKeys.Settings.subtitle))
                            .foregroundStyle(.white)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .toolbarBackground(Color.rmBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Language section

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(self.lang.localized(LocalizationKeys.Settings.sectionLanguage))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.bottom, 6)

            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(self.lang.language == "en"
                         ? self.lang.localized(LocalizationKeys.Settings.languageEnglish)
                         : self.lang.localized(LocalizationKeys.Settings.languageSpanish))
                        .font(.headline)
                    Text(self.lang.localized(LocalizationKeys.Settings.languageSwitchHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { self.lang.language == "es" },
                    set: { _ in self.lang.setLanguage(lang.language == "en" ? "es" : "en") }
                ))
                .labelsHidden()
                .tint(Color.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(Color.rmCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Security section

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(self.lang.localized(LocalizationKeys.Settings.sectionSecurity))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.bottom, 6)

            biometricRow
        }
    }

    // MARK: - Biometric row

    private var biometricRow: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: biometricIcon)
                    .font(.title2)
                    .foregroundStyle(statusColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(biometricTitle)
                        .font(.headline)
                    Text(statusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { biometricAuth.isFaceIDEnabled },
                    set: { enabled in
                        if enabled {
                            let reason = self.lang.localized(LocalizationKeys.Settings.faceIDReason)
                            Task { await biometricAuth.enableFaceID(reason: reason) }
                        } else {
                            biometricAuth.disableFaceID()
                        }
                    }
                ))
                .labelsHidden()
                .tint(.green)
                .disabled(biometricAuth.biometricStatus == .notAvailable || biometricAuth.isAuthenticating)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)

            if biometricAuth.biometricStatus == .denied {
                Divider().background(.secondary.opacity(0.3))

                Button {
                    viewModel.openSystemSettings()
                } label: {
                    Label(LocalizationKeys.settingsOpenSettings(biometryName: biometricTitle, lang: lang),
                          systemImage: "gear")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .tint(Color.accentColor)
            }
        }
        .background(Color.rmCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Display helpers

    private var biometricIcon: String {
        switch biometricAuth.biometryType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default:       return "lock.slash"
        }
    }

    private var biometricTitle: String {
        switch biometricAuth.biometryType {
        case .faceID:  return lang.localized(LocalizationKeys.Settings.biometryFaceID)
        case .touchID: return lang.localized(LocalizationKeys.Settings.biometryTouchID)
        case .opticID: return lang.localized(LocalizationKeys.Settings.biometryOpticID)
        default:       return lang.localized(LocalizationKeys.Settings.biometryGeneric)
        }
    }

    private var statusDescription: String {
        switch biometricAuth.biometricStatus {
        case .authorized:
            return LocalizationKeys.settingsStatusAuthorized(biometryName: biometricTitle, lang: lang)
        case .denied:
            return lang.localized(LocalizationKeys.Settings.statusDenied)
        case .notEnrolled:
            return lang.localized(LocalizationKeys.Settings.statusNotEnrolled)
        case .notAvailable:
            return lang.localized(LocalizationKeys.Settings.statusNotAvailable)
        case .locked:
            return lang.localized(LocalizationKeys.Settings.statusLocked)
        }
    }

    private var statusColor: Color {
        switch biometricAuth.biometricStatus {
        case .authorized:   return .green
        case .denied:       return .red
        case .notEnrolled:  return .yellow
        case .notAvailable: return .gray
        case .locked:       return .orange
        }
    }
}

#Preview {
    SettingsView()
        .environment(LanguageManager.shared)
        .environment(BiometricAuthManager.shared)
}
