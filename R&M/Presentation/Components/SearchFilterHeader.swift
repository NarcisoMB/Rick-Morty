//
//  SearchFilterHeader.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct SearchFilterHeader: View {
    @Environment(LanguageManager.self) private var lang

    @Binding var showSearch: Bool
    @Binding var searchText: String
    @Binding var filterStatus: String?
    @Binding var filterSpecies: String?
    
	var availableStatuses: [String]
    var availableSpecies: [String]
    var placeholder: String = ""
    
	@FocusState.Binding var isSearchFocused: Bool

    private var hasActiveFilter: Bool { filterStatus != nil || filterSpecies != nil }
    private var resolvedPlaceholder: String { placeholder.isEmpty ? lang.localized(LocalizationKeys.CharacterList.searchPlaceholder) : placeholder }

    var body: some View {
        VStack(spacing: 0) {
			if self.showSearch {
				searchBar
            }
			if !self.showSearch && !self.searchText.isEmpty {
				searchChip
            }
			if self.hasActiveFilter {
				filterChipsRow
            }
        }
        .background(Color.rmBackground)
		.animation(.easeInOut(duration: 0.2), value: self.showSearch)
		.animation(.easeInOut(duration: 0.2), value: self.searchText.isEmpty)
		.animation(.easeInOut(duration: 0.2), value: self.hasActiveFilter)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
			TextField(self.resolvedPlaceholder, text: self.$searchText)
				.focused(self.$isSearchFocused)
                .autocorrectionDisabled()
				.onSubmit { self.showSearch = false }
			if !self.searchText.isEmpty {
				Button { self.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            filterMenu
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.vertical, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
		.onChange(of: self.isSearchFocused) { _, focused in
            if !focused {
				withAnimation(.easeInOut(duration: 0.2)) { self.showSearch = false }
            }
        }
    }

    private var filterMenu: some View {
        Menu {
			Section(self.lang.localized(LocalizationKeys.Filter.sectionStatus)) {
				Button { self.filterStatus = nil } label: {
					Label(self.lang.localized(LocalizationKeys.Filter.all), systemImage: self.filterStatus == nil ? "checkmark" : "")
                }
				ForEach(self.availableStatuses, id: \.self) { status in
					Button { self.filterStatus = self.filterStatus == status ? nil : status } label: {
						Label(status, systemImage: self.filterStatus == status ? "checkmark" : "")
                    }
                }
            }
			Section(self.lang.localized(LocalizationKeys.Filter.sectionSpecies)) {
				Button { self.filterSpecies = nil } label: {
					Label(self.lang.localized(LocalizationKeys.Filter.all), systemImage: self.filterSpecies == nil ? "checkmark" : "")
                }
                ForEach(availableSpecies, id: \.self) { species in
                    Button { filterSpecies = filterSpecies == species ? nil : species } label: {
                        Label(species, systemImage: filterSpecies == species ? "checkmark" : "")
                    }
                }
            }
        } label: {
			Image(systemName: self.hasActiveFilter
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
			.foregroundStyle(self.hasActiveFilter ? Color.accentColor : .secondary)
        }
    }

    private var searchChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.caption)
			Text(self.searchText)
                .font(.caption)
                .lineLimit(1)
			Button { self.searchText = "" } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .bold()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.15))
        .foregroundStyle(Color.accentColor)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .leading)))
        .onTapGesture {
			withAnimation(.easeInOut(duration: 0.2)) { self.showSearch = true }
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { self.isSearchFocused = true }
        }
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
				if let status = self.filterStatus {
					FilterChipView(label: status) { self.filterStatus = nil }
                }
				if let species = self.filterSpecies {
					FilterChipView(label: species) { self.filterSpecies = nil }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
