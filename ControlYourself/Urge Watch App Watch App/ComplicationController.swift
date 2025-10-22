//
//  ComplicationController.swift
//  Urge Watch App
//
//  Provides complication data for watch faces
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "urge_timer",
                displayName: "Urge Timer",
                supportedFamilies: [
                    .graphicCircular,
                    .graphicCorner,
                    .graphicBezel,
                    .graphicRectangular,
                    .modularSmall,
                    .modularLarge
                ]
            )
        ]

        handler(descriptors)
    }

    // MARK: - Timeline Configuration

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Timeline ends 24 hours from now
        handler(Date().addingTimeInterval(24 * 60 * 60))
    }

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let connectivity = WatchConnectivityManager.shared
        let entry = createTimelineEntry(for: complication, date: Date(), connectivity: connectivity)
        handler(entry)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // For timer complications, we don't need future entries as we update dynamically
        handler(nil)
    }

    // MARK: - Sample Templates

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = createTemplate(for: complication, countdownTime: 3600, snusLeft: 5, isReady: false)
        handler(template)
    }

    // MARK: - Template Creation

    private func createTimelineEntry(for complication: CLKComplication, date: Date, connectivity: WatchConnectivityManager) -> CLKComplicationTimelineEntry? {
        guard let template = createTemplate(
            for: complication,
            countdownTime: connectivity.countdownTime,
            snusLeft: connectivity.snusLeft,
            isReady: connectivity.isReady
        ) else {
            return nil
        }

        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }

    private func createTemplate(for complication: CLKComplication, countdownTime: TimeInterval, snusLeft: Int, isReady: Bool) -> CLKComplicationTemplate? {

        let timeString = formatTime(countdownTime)
        let statusText = isReady ? "Ready!" : timeString

        switch complication.family {
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: statusText),
                line2TextProvider: CLKSimpleTextProvider(text: "\(snusLeft)")
            )

        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: CLKSimpleTextProvider(text: statusText),
                outerTextProvider: CLKSimpleTextProvider(text: "Urge")
            )

        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: statusText),
                line2TextProvider: CLKSimpleTextProvider(text: "\(snusLeft)")
            )

            return CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: circularTemplate,
                textProvider: CLKSimpleTextProvider(text: isReady ? "Ready to go!" : "Next in \(timeString)")
            )

        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Urge"),
                body1TextProvider: CLKSimpleTextProvider(text: isReady ? "✓ Ready" : "⏱ \(timeString)"),
                body2TextProvider: CLKSimpleTextProvider(text: "\(snusLeft) left")
            )

        case .modularSmall:
            return CLKComplicationTemplateModularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: statusText),
                line2TextProvider: CLKSimpleTextProvider(text: "\(snusLeft)")
            )

        case .modularLarge:
            return CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Urge"),
                body1TextProvider: CLKSimpleTextProvider(text: isReady ? "✓ Ready to go" : "Next: \(timeString)"),
                body2TextProvider: CLKSimpleTextProvider(text: "\(snusLeft) remaining")
            )

        default:
            return nil
        }
    }

    // MARK: - Helper Methods

    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return String(format: "%ds", secs)
        }
    }
}
