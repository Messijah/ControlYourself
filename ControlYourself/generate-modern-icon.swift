import SwiftUI
import AppKit

struct ModernAppIcon: View {
    var body: some View {
        ZStack {
            // No borders - pure gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.10, blue: 0.38),
                    Color(red: 0.20, green: 0.12, blue: 0.42),
                    Color(red: 0.12, green: 0.08, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Main circular icon with glow - inspired by the app's design
            ZStack {
                // Outer glow (mint/cyan like the completed state)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.4, green: 0.8, blue: 0.7).opacity(0.4),
                                Color(red: 0.3, green: 0.7, blue: 0.6).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .frame(width: 700, height: 700)
                    .blur(radius: 60)

                // Main circle with gradient (purple to cyan)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.42, green: 0.36, blue: 0.90),
                                Color(red: 0.35, green: 0.65, blue: 0.85),
                                Color(red: 0.3, green: 0.75, blue: 0.70)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 600, height: 600)
                    .shadow(color: Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.5), radius: 50, x: 0, y: 20)

                // Inner subtle glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(width: 600, height: 600)

                // Icon: Stylized timer/snus symbol (simple flower/hexagon shape like in the app)
                ZStack {
                    // Hexagon flower pattern (like the "snus kvar" icon)
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: 70, height: 70)
                            .offset(x: 90 * cos(Double(index) * .pi / 3),
                                   y: 90 * sin(Double(index) * .pi / 3))
                    }

                    // Center circle
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .frame(width: 300, height: 300)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// Render to PNG
@MainActor
func generateIcon() {
    let view = ModernAppIcon()
    let nsView = NSHostingView(rootView: view)
    nsView.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)

    let renderer = ImageRenderer(content: view)
    renderer.scale = 1.0

    if let image = renderer.cgImage {
        let bitmap = NSBitmapImageRep(cgImage: image)
        bitmap.size = NSSize(width: 1024, height: 1024)

        if let pngData = bitmap.representation(using: .png, properties: [:]) {
            let outputPath = "/Users/jens/Desktop/ControlYourself/ControlYourself/ControlYourself/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png"
            try? pngData.write(to: URL(fileURLWithPath: outputPath))
            print("Modern icon saved to: \(outputPath)")
        }
    }
}

await generateIcon()
