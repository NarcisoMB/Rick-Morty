//
// SettingsView.swift
// R&M
//
// Created by Narciso Meza on 09/06/26.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
	@Environment(LanguageManager.self) private var lang
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
			.task { self.viewModel.checkBiometricStatus() }
			.onChange(of: scenePhase) { _, phase in
				if phase == .active { self.viewModel.checkBiometricStatus() }
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
				Image(systemName: self.biometricIcon)
					.font(.title2)
					.foregroundStyle(self.statusColor)
					.frame(width: 32)

				VStack(alignment: .leading, spacing: 2) {
					Text(self.biometricTitle)
						.font(.headline)
					Text(self.statusDescription)
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				Spacer()

				Toggle("", isOn: Binding(
					get: { self.viewModel.isFaceIDEnabled },
					set: { enabled in
						if enabled {
							let reason = self.lang.localized(LocalizationKeys.Settings.faceIDReason)
							Task { await self.viewModel.enableFaceID(reason: reason) }
						} else {
							self.viewModel.disableFaceID()
						}
					}
				))
				.labelsHidden()
				.tint(.green)
				.disabled(self.viewModel.biometricStatus == .notAvailable || self.viewModel.isAuthenticating)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 14)

			if self.viewModel.biometricStatus == .denied {
				Divider().background(.secondary.opacity(0.3))

				Button {
					UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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

	// MARK: - Computed helpers
	private var biometricIcon: String {
		switch self.viewModel.biometryType {
		case .faceID:  return "faceid"
		case .touchID: return "touchid"
		case .opticID: return "opticid"
		default:       return "lock.slash"
		}
	}

	private var biometricTitle: String {
		switch self.viewModel.biometryType {
		case .faceID:  return lang.localized(LocalizationKeys.Settings.biometryFaceID)
		case .touchID: return lang.localized(LocalizationKeys.Settings.biometryTouchID)
		case .opticID: return lang.localized(LocalizationKeys.Settings.biometryOpticID)
		default:       return lang.localized(LocalizationKeys.Settings.biometryGeneric)
		}
	}

	private var statusDescription: String {
		switch self.viewModel.biometricStatus {
		case .authorized:
			return LocalizationKeys.settingsStatusAuthorized(biometryName: self.biometricTitle, lang: self.lang)
		case .denied:
			return self.lang.localized(LocalizationKeys.Settings.statusDenied)
		case .notEnrolled:
			return self.lang.localized(LocalizationKeys.Settings.statusNotEnrolled)
		case .notAvailable:
			return self.lang.localized(LocalizationKeys.Settings.statusNotAvailable)
		case .locked:
			return self.lang.localized(LocalizationKeys.Settings.statusLocked)
		}
	}

	private var statusColor: Color {
		switch self.viewModel.biometricStatus {
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
}
