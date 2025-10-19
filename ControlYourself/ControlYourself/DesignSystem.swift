//
//  DesignSystem.swift
//  ControlYourself
//
//  Modern Design System 2026
//

import SwiftUI

// MARK: - Colors & Gradients
struct AppTheme {
    // Modern gradient backgrounds
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.11, green: 0.13, blue: 0.18),  // #1c212e
            Color(red: 0.17, green: 0.20, blue: 0.27)   // #2b3344
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.42, green: 0.36, blue: 0.90),  // #6c5ce7
            Color(red: 0.55, green: 0.27, blue: 0.87)   // #8b45de
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.0, green: 0.82, blue: 0.60),   // #00d19a
            Color(red: 0.0, green: 0.70, blue: 0.52)    // #00b386
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let warningGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.75, blue: 0.0),    // #ffc000
            Color(red: 1.0, green: 0.60, blue: 0.0)     // #ff9900
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let dangerGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.23, blue: 0.19),   // #ff3b30
            Color(red: 0.93, green: 0.11, blue: 0.14)   // #ed1c24
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    // Solid colors
    static let accent = Color(red: 0.42, green: 0.36, blue: 0.90)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let cardBackground = Color.white.opacity(0.1)
}

// MARK: - Custom Button Styles
struct ModernButtonStyle: ButtonStyle {
    var gradient: LinearGradient
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(gradient)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(configuration.isPressed ? 0.2 : 0))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: gradient.startColor.opacity(0.5), radius: configuration.isPressed ? 5 : 15, x: 0, y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GlassmorphicButtonStyle: ButtonStyle {
    var accentColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(accentColor.opacity(0.15))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Helper Extensions
extension LinearGradient {
    var startColor: Color {
        // Extract first color from gradient (approximation)
        return Color(red: 0.42, green: 0.36, blue: 0.90)
    }
}

// MARK: - Circular Progress Ring
struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: lineWidth
                )

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.08))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
    }
}

// MARK: - Pulse Animation
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseModifier())
    }
}
