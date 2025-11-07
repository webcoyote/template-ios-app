import SwiftUI

struct TabBarButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption2)
                    .fixedSize()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .blue : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    private let tabNames = ["home", "settings"]

    // Particle settings state
    @State private var selectedPreset = HomePage.ParticlePreset.confetti
    @State private var birthRate: Double = 100
    @State private var speed: Double = 0.5
    @State private var lifespan: Double = 3.0
    @State private var particleSize: Double = 16

    var body: some View {
        VStack(spacing: 0) {
            // Page content with lazy loading
            Group {
                if selectedTab == 0 {
                    HomePage(
                        selectedPreset: $selectedPreset,
                        birthRate: $birthRate,
                        speed: $speed,
                        lifespan: $lifespan,
                        particleSize: $particleSize
                    )
                } else {
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            HStack(spacing: 0) {
                TabBarButton(
                    title: "Home",
                    systemImage: "house.fill",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )

                TabBarButton(
                    title: "Settings",
                    systemImage: "gear",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(UIColor.separator)),
                alignment: .top
            )
        }
        .onChange(of: selectedTab) { _, newValue in
            AnalyticsManager.shared.trackScreenView(screenName: tabNames[newValue])
        }
        .onAppear {
            // Track initial screen view
            AnalyticsManager.shared.trackScreenView(screenName: "home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
