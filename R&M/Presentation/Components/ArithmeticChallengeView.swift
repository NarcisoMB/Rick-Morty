//
//  ArithmeticChallengeView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct ArithmeticChallengeView: View {
    let challenge: ArithmeticChallenge

    @Environment(BiometricAuthManager.self) private var biometricAuth

    @State private var input = ""
    @State private var shakeOffset: CGFloat = 0

    private let maxDigits = 3

    var body: some View {
        ZStack {
            Color.rmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.white)
                    .padding(.bottom, 12)

                Text(self.challenge.question)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                inputDisplay
                    .offset(x: self.shakeOffset)
                    .padding(.bottom, 40)

                numericPad

                Spacer(minLength: 0)

                HStack {
                    Button("Cancelar") {
                        self.biometricAuth.cancelChallenge()
                    }
                    .foregroundStyle(.white)
                    .font(.body)
                    .frame(maxWidth: .infinity)

                    Color.clear.frame(maxWidth: .infinity)

                    Button {
                        self.deleteDigit()
                    } label: {
                        Image(systemName: "delete.left")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(self.input.isEmpty ? 0 : 1)
                    .animation(.easeInOut(duration: 0.15), value: self.input.isEmpty)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .colorScheme(.dark)
    }

    private var inputDisplay: some View {
        Text(self.input.isEmpty ? "—" : self.input)
            .font(.system(size: 48, weight: .thin, design: .monospaced))
            .foregroundStyle(self.input.isEmpty ? Color.white.opacity(0.3) : Color.white)
            .frame(minWidth: 120)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.1), value: self.input)
    }

    private var numericPad: some View {
        VStack(spacing: 16) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { digit in
                        digitButton(digit)
                    }
                }
            }
            HStack(spacing: 20) {
                Color.clear.frame(width: 80, height: 80)
                digitButton(0)
                confirmButton
            }
        }
    }

    private func digitButton(_ digit: Int) -> some View {
        Button {
            guard self.input.count < self.maxDigits else { return }
            self.input.append("\(digit)")
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 80)
                Text("\(digit)")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private var confirmButton: some View {
        Button {
            self.verify()
        } label: {
            ZStack {
                Circle()
                    .fill(self.input.isEmpty ? Color.clear : Color.accentColor)
                    .frame(width: 80, height: 80)
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .opacity(self.input.isEmpty ? 0 : 1)
            }
            .animation(.easeInOut(duration: 0.15), value: self.input.isEmpty)
        }
        .buttonStyle(.plain)
        .disabled(self.input.isEmpty)
    }

    private func deleteDigit() {
        guard !self.input.isEmpty else { return }
        self.input.removeLast()
    }

    private func verify() {
        guard let value = Int(self.input) else {
            self.triggerShake()
            return
        }
        if value == self.challenge.answer {
            self.biometricAuth.submitChallengeAnswer(value)
        } else {
            self.triggerShake()
            self.input = ""
        }
    }

    private func triggerShake() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
            self.shakeOffset = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                self.shakeOffset = 0
            }
        }
    }
}
