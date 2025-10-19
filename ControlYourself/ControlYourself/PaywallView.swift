//
//  PaywallView.swift
//  ControlYourself
//
//  Created by Claude on 2025-10-16.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    @State private var selectedProduct: Product?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Modern mesh gradient background (same as LandingPageView)
            MeshGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    // App Icon & Title
                    VStack(spacing: 20) {
                        // App icon styled circle
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.7, blue: 0.9),
                                            Color(red: 0.3, green: 0.6, blue: 0.85)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.blue.opacity(0.4), radius: 20, x: 0, y: 10)

                            // Central dot
                            Circle()
                                .fill(Color.white)
                                .frame(width: 12, height: 12)

                            // Surrounding dots
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 10, height: 10)
                                    .offset(x: cos(Double(index) * 2 * .pi / 5) * 28,
                                           y: sin(Double(index) * 2 * .pi / 5) * 28)
                            }
                        }

                        VStack(spacing: 8) {
                            Text("Välkommen till")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))

                            Text("Urge")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "timer", title: "Håll balansen", description: "Reglera ditt intag utan att sluta helt")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Följ din framgång", description: "Se din statistik och progress över tid")
                        FeatureRow(icon: "bolt.shield.fill", title: "Panikläge", description: "Flexibilitet när du behöver det")
                        FeatureRow(icon: "moon.stars.fill", title: "Dynamic Island", description: "Timer alltid synlig i Dynamic Island")
                    }
                    .padding(.horizontal, 24)

                    // Subscription Options
                    if !subscriptionManager.subscriptions.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(subscriptionManager.subscriptions, id: \.id) { product in
                                SubscriptionOptionCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    isYearly: product.id == "urge.plus.yearly",
                                    savingsText: getSavingsText(for: product)
                                ) {
                                    selectedProduct = product
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }

                    // Trial info
                    Text("7 dagars gratis provperiod")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )

                    // CTA Button
                    Button {
                        Task {
                            await purchaseSubscription()
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Text("Starta gratis provperiod")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(AppTheme.successGradient)

                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.25), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .shadow(color: Color.green.opacity(0.5), radius: 20, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isPurchasing || selectedProduct == nil)
                    .opacity((isPurchasing || selectedProduct == nil) ? 0.6 : 1.0)
                    .padding(.horizontal, 24)

                    // Restore purchases
                    Button {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    } label: {
                        Text("Återställ köp")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .underline()
                    }
                    .padding(.bottom, 8)

                    // Fine print
                    Text("Avbryt när som helst. Ingen bindningstid.")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
        }
        .alert("Något gick fel", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Pre-select yearly (better deal)
            if let yearlyProduct = subscriptionManager.subscriptions.first(where: { $0.id == "urge.plus.yearly" }) {
                selectedProduct = yearlyProduct
            } else {
                selectedProduct = subscriptionManager.subscriptions.first
            }
        }
    }

    private func getSavingsText(for product: Product) -> String? {
        guard product.id == "urge.plus.yearly",
              let monthlyProduct = subscriptionManager.subscriptions.first(where: { $0.id == "urge.plus.monthly" }) else {
            return nil
        }
        return subscriptionManager.savingsText(for: product, comparedTo: monthlyProduct)
    }

    private func purchaseSubscription() async {
        guard let product = selectedProduct else { return }

        isPurchasing = true

        do {
            let transaction = try await subscriptionManager.purchase(product)

            if transaction != nil {
                // Purchase successful - dismiss paywall
                dismiss()
            }
        } catch {
            errorMessage = "Köpet kunde inte genomföras. Försök igen."
            showError = true
        }

        isPurchasing = false
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
    }
}

// MARK: - Subscription Option Card
struct SubscriptionOptionCard: View {
    let product: Product
    let isSelected: Bool
    let isYearly: Bool
    let savingsText: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.green : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(isYearly ? "Helår" : "Månad")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        if let savings = savingsText, isYearly {
                            Text(savings)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.2))
                                )
                        }
                    }

                    Text("\(product.displayPrice)/\(isYearly ? "år" : "mån") efter provperiod")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(isSelected ? 0.15 : 0.08))

                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: isSelected ? [.green.opacity(0.6), .green.opacity(0.3)] : [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .shadow(color: isSelected ? Color.green.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 15 : 5, x: 0, y: isSelected ? 8 : 3)
        }
    }
}

#Preview {
    PaywallView()
}
