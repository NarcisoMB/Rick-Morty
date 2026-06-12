//
//  SettingsViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation
import UIKit

@Observable
final class SettingsViewModel {
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
