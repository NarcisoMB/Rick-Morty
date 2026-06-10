//
//  CharacterMapView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI
import MapKit

struct CharacterMapView: View {
	@Environment(MapNavigationManager.self) private var mapNav
	@Environment(LocationManager.self) private var locationManager
	@Environment(LanguageManager.self) private var lang
	
	@State private var viewModel = CharacterMapViewModel()
	@State private var position: MapCameraPosition = .automatic
	@State private var isPanelExpanded = false
	@State private var isPanelMinimized = false
	@State private var panelDragOffset: CGFloat = 0
	@State private var selectedCharacter: Character?
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .bottom) {
				Map(position: self.$position) {
					UserAnnotation()
					ForEach(viewModel.annotations) { annotation in
						Annotation("", coordinate: annotation.coordinate, anchor: .bottom) {
							CharacterPinView(character: annotation.character)
								.onTapGesture {
									withAnimation {
										position = .region(MKCoordinateRegion(
											center: annotation.coordinate,
											span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
										))
									}
									selectedCharacter = annotation.character
								}
						}
					}
				}
				.accessibilityIdentifier("map_main")
				.mapStyle(.standard)
				.ignoresSafeArea()
				.overlay(alignment: .top) { mapHeader }
				.overlay(alignment: .topTrailing) { locationButton }
				.overlay {
					if viewModel.isLoading { ProgressView().tint(.white) }
				}
				
				if isPanelMinimized {
					restorePill
						.transition(.scale.combined(with: .opacity))
				} else {
					CharacterListSheet(
						annotations: viewModel.annotations,
						isLoading: viewModel.isLoading,
						isExpanded: self.$isPanelExpanded,
						liveOffset: self.$panelDragOffset,
						onMinimize: {
							isPanelMinimized = true
							isPanelExpanded = false
						},
						onFocus: { annotation in
							withAnimation {
								position = .region(MKCoordinateRegion(
									center: annotation.coordinate,
									span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
								))
							}
						}
					)
					.accessibilityElement(children: .contain)
					.accessibilityIdentifier("panel_characters")
					.frame(height: max(80, (isPanelExpanded ? geo.size.height * 0.78 : geo.size.height * 0.38) - panelDragOffset))
					.padding(.bottom, 8)
					.animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPanelExpanded)
					.transition(.move(edge: .bottom).combined(with: .opacity))
				}
			}
			.animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPanelMinimized)
		}
		.task { await viewModel.load() }
		.sheet(item: self.$selectedCharacter) {
			CharacterDetailView(
				character: $0,
				showMapPin: false
			)
		}
		.onChange(of: mapNav.pendingCharacter) { _, character in
			guard let character else { return }
			let coord = CharacterMapViewModel.coordinate(for: character.id)
			withAnimation {
				position = .region(MKCoordinateRegion(
					center: coord,
					span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 18)
				))
			}
			mapNav.pendingCharacter = nil
		}
		.onChange(of: locationManager.userLocation) { _, coord in
			guard let coord else { return }
			withAnimation {
				position = .region(MKCoordinateRegion(
					center: coord,
					span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
				))
			}
		}
	}
	
	private var locationButton: some View {
		Button {
			let status = locationManager.authorizationStatus
			if status == .authorizedWhenInUse || status == .authorizedAlways {
				if let coord = locationManager.userLocation {
					withAnimation {
						position = .region(MKCoordinateRegion(
							center: coord,
							span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
						))
					}
				} else {
					locationManager.requestWhenInUse()
				}
			} else {
				locationManager.requestWhenInUse()
			}
		} label: {
			Image(systemName: locationIcon)
				.font(.system(size: 16, weight: .medium))
				.foregroundStyle(.white)
				.padding(12)
				.background(Color.rmCard)
				.clipShape(Circle())
				.shadow(color: .black.opacity(0.4), radius: 4, y: 2)
		}
		.accessibilityIdentifier("btn_location")
		.padding(.top, 56)
		.padding(.trailing, 16)
	}
	
	private var locationIcon: String {
		switch locationManager.authorizationStatus {
		case .authorizedWhenInUse, .authorizedAlways:
			return locationManager.userLocation != nil ? "location.fill" : "location"
		case .denied, .restricted: return "location.slash"
		default: return "location"
		}
	}
	
	private var restorePill: some View {
		Button {
			withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
				isPanelMinimized = false
			}
		} label: {
			HStack(spacing: 8) {
				Image(systemName: "person.3.fill")
					.font(.subheadline)
				Text(lang.localized(LocalizationKeys.Tab.characters))
					.font(.subheadline).bold()
				if !viewModel.annotations.isEmpty {
					Text("\(viewModel.annotations.count)")
						.font(.caption)
						.padding(.horizontal, 7)
						.padding(.vertical, 2)
						.background(Color.white.opacity(0.2))
						.clipShape(Capsule())
				}
			}
			.foregroundStyle(.white)
			.padding(.horizontal, 18)
			.padding(.vertical, 12)
			.background(Color.rmCard)
			.clipShape(Capsule())
			.shadow(color: .black.opacity(0.4), radius: 8, y: 4)
		}
		.accessibilityIdentifier("btn_restore_pill")
		.padding(.bottom, 16)
	}
	
	private var mapHeader: some View {
		VStack(spacing: 2) {
			Text("Rick & Morty").foregroundStyle(.white)
			Text(lang.localized(LocalizationKeys.Map.subtitle))
				.foregroundStyle(.white.opacity(0.7))
				.font(.caption)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 12)
	}
}

private struct CharacterPinView: View {
	let character: Character
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				Circle()
					.fill(Color.rmCard)
					.frame(width: 44, height: 44)
					.shadow(color: .black.opacity(0.4), radius: 4, y: 2)
				Circle()
					.strokeBorder(character.statusColor, lineWidth: 2.5)
					.frame(width: 44, height: 44)
				CachedAsyncImage(url: character.image) { image in
					image.resizable().scaledToFill()
				} placeholder: {
					Color.gray.opacity(0.3)
				}
				.frame(width: 38, height: 38)
				.clipShape(Circle())
			}
			PinTip()
				.fill(character.statusColor)
				.frame(width: 10, height: 7)
		}
	}
}

private struct PinTip: Shape {
	func path(in rect: CGRect) -> Path {
		Path { path in
			path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
			path.closeSubpath()
		}
	}
}
