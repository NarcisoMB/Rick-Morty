//
//  SearchFilterHeader.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct SearchFilterHeader: View {
    @Binding var showSearch: Bool
    @Binding var searchText: String
    @Binding var filterStatus: String?
    @Binding var filterSpecies: String?
    var availableStatuses: [String]
    var availableSpecies: [String]
    var placeholder: String = "Name, species, status..."
    @FocusState.Binding var isSearchFocused: Bool

    private var hasActiveFilter: Bool { filterStatus != nil || filterSpecies != nil }

    var body: some View {
        VStack(spacing: 0) {
            if showSearch {
                searchBar
            }
            if !showSearch && !searchText.isEmpty {
                searchChip
            }
            if hasActiveFilter {
                filterChipsRow
            }
        }
        .background(Color.rmBackground)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: hasActiveFilter)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $searchText)
                .focused($isSearchFocused)
                .autocorrectionDisabled()
                .onSubmit { showSearch = false }
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
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
        .onChange(of: isSearchFocused) { _, focused in
            if !focused {
                withAnimation(.easeInOut(duration: 0.2)) { showSearch = false }
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Section("Status") {
                Button { filterStatus = nil } label: {
                    Label("All", systemImage: filterStatus == nil ? "checkmark" : "")
                }
                ForEach(availableStatuses, id: \.self) { status in
                    Button { filterStatus = filterStatus == status ? nil : status } label: {
                        Label(status, systemImage: filterStatus == status ? "checkmark" : "")
                    }
                }
            }
            Section("Species") {
                Button { filterSpecies = nil } label: {
                    Label("All", systemImage: filterSpecies == nil ? "checkmark" : "")
                }
                ForEach(availableSpecies, id: \.self) { species in
                    Button { filterSpecies = filterSpecies == species ? nil : species } label: {
                        Label(species, systemImage: filterSpecies == species ? "checkmark" : "")
                    }
                }
            }
        } label: {
            Image(systemName: hasActiveFilter
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
            .foregroundStyle(hasActiveFilter ? Color.accentColor : .secondary)
        }
    }

    private var searchChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.caption)
            Text(searchText)
                .font(.caption)
                .lineLimit(1)
            Button { searchText = "" } label: {
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
            withAnimation(.easeInOut(duration: 0.2)) { showSearch = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { isSearchFocused = true }
        }
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let status = filterStatus {
                    FilterChipView(label: status) { filterStatus = nil }
                }
                if let species = filterSpecies {
                    FilterChipView(label: species) { filterSpecies = nil }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
