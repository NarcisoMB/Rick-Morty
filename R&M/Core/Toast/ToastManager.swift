//
//  ToastManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI
import Observation

@Observable
final class ToastManager {
    static let shared = ToastManager()

    private var toastWindow: UIWindow?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    @MainActor
    func show(_ message: String) {
        dismissTask?.cancel()
        dismissWindow(animated: false)

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else { return }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = false

        let controller = UIHostingController(rootView: ToastContentView(message: message))
        controller.view.backgroundColor = .clear
        window.rootViewController = controller

        window.alpha = 0
        window.isHidden = false
        toastWindow = window

        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            window.alpha = 1
        }

        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            dismissWindow(animated: true)
        }
    }

    @MainActor
    private func dismissWindow(animated: Bool) {
        guard let window = toastWindow else { return }
        toastWindow = nil
        guard animated else { window.isHidden = true; return }
        UIView.animate(withDuration: 0.25) {
            window.alpha = 0
        } completion: { _ in
            window.isHidden = true
        }
    }
}
