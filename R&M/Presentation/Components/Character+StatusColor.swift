//
//  Character+StatusColor.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

extension Character {
    var statusColor: Color {
        switch status.lowercased() {
        case "alive": .green
        case "dead":  .red
        default:      .gray
        }
    }
}
