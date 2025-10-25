//
//  SubscriptionManager.swift
//  ControlYourself
//
//  Created by Claude on 2025-10-16.
//

import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed

    private var updateListenerTask: Task<Void, Error>?

    enum SubscriptionStatus {
        case notSubscribed
        case subscribed
        case inTrial
    }

    static let shared = SubscriptionManager()

    private let productIDs = [
        "urge.plus.monthly",
        "urge.plus.yearly"
    ]

    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIDs)

            // Sort: yearly first (better deal), then monthly
            self.subscriptions = products.sorted { product1, product2 in
                if product1.id == "urge.plus.yearly" {
                    return true
                } else if product2.id == "urge.plus.yearly" {
                    return false
                }
                return product1.price > product2.price
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Update subscription status
            await updateSubscriptionStatus()

            // Always finish a transaction
            await transaction.finish()

            return transaction

        case .userCancelled, .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Update Subscription Status

    func updateSubscriptionStatus() async {
        var activeSubscription: Product?
        var isInTrial = false

        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if this transaction is for one of our subscription products
                if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                    activeSubscription = subscription

                    // Check if in trial period
                    if transaction.expirationDate != nil {
                        let purchaseDate = transaction.purchaseDate
                        let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days
                        if Date().timeIntervalSince(purchaseDate) < trialDuration {
                            isInTrial = true
                        }
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        // Update published properties
        if let _ = activeSubscription {
            if isInTrial {
                subscriptionStatus = .inTrial
            } else {
                subscriptionStatus = .subscribed
            }
            purchasedSubscriptions = subscriptions.filter { product in
                productIDs.contains(product.id)
            }
        } else {
            subscriptionStatus = .notSubscribed
            purchasedSubscriptions = []
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // Update subscription status
                    await self.updateSubscriptionStatus()

                    // Always finish a transaction
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Subscription Info

    var isSubscribed: Bool {
        subscriptionStatus == .subscribed || subscriptionStatus == .inTrial
    }

    var isInTrialPeriod: Bool {
        subscriptionStatus == .inTrial
    }

    // MARK: - Pricing Helpers

    func formattedPrice(for product: Product) -> String {
        return product.displayPrice
    }

    func savingsText(for yearlyProduct: Product, comparedTo monthlyProduct: Product) -> String {
        let yearlyPrice = yearlyProduct.price
        let monthlyYearlyCost = monthlyProduct.price * 12
        let savings = monthlyYearlyCost - yearlyPrice

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearlyProduct.priceFormatStyle.locale

        if let savingsString = formatter.string(from: NSDecimalNumber(decimal: savings)) {
            return String(format: NSLocalizedString("subscription.save_amount", comment: ""), savingsString)
        }
        return ""
    }
}

// MARK: - Store Error

enum StoreError: Error {
    case failedVerification
}
