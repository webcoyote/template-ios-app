import SwiftUI
import StoreKit
import UIKit
import WebKit
import UniformTypeIdentifiers
import CoreData

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var appSettings = AppSettings.shared
    @ObservedObject private var usageTracker = UsageTracker.shared
    @State private var activeSheet: SheetType?
    @State private var activeAlert: AlertType?
    @State private var showingSurvey = false

    enum SheetType: Identifiable {
        case appearance
        case survey
        case privacy
        case support

        var id: Self { self }
    }

    enum AlertType: Identifiable {
        case appInfo

        var id: Self { self }
    }

    private let warningColor = Color(red: 255/255.0, green: 104/255.0, blue: 0/255.0, opacity: 1.0)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                        SettingsSection("Appearance") {
                            VStack(spacing: 0) {
                                SettingsRowWithIcon(
                                    title: "Appearance",
                                    subtitle: appSettings.appearanceMode.displayName,
                                    icon: "paintbrush"
                                ) {
                                    activeSheet = .appearance
                                    AnalyticsManager.shared.track("settings_tapped", properties: ["setting": "appearance"])
                                }
                                .padding()
                            }
                        }

                        SettingsSection("Support") {
                            VStack(spacing: 0) {
                                SettingsRowWithIcon(
                                    title: "Contact Support",
                                    subtitle: nil,
                                    icon: "envelope"
                                ) {
                                    activeSheet = .support
                                }
                                .padding()

                                Divider()

                                SettingsRowWithIcon(
                                    title: "Privacy Policy",
                                    subtitle: nil,
                                    icon: "lock.shield"
                                ) {
                                    activeSheet = .privacy
                                    AnalyticsManager.shared.track("settings_tapped", properties: ["setting": "privacy_policy"])
                                }
                                .padding()
                            }
                        }

                        SettingsSection("Feedback") {
                            VStack(spacing: 0) {
                                SettingsRowWithIcon(
                                    title: "Rate the App",
                                    subtitle: nil,
                                    icon: "star.fill"
                                ) {
                                    requestAppReview()
                                }
                                .padding()

                                Divider()

                                SettingsRowWithIcon(
                                    title: "Take a Survey",
                                    subtitle: nil,
                                    icon: "doc.text"
                                ) {
                                    showingSurvey = true
                                }
                                .padding()
                            }
                        }

                        SettingsSection("App Information") {
                            VStack(spacing: 0) {
                                let appInfo = AppSettings.shared.getAppInfo()

                                SettingsRowWithIcon(
                                    title: "App Details",
                                    subtitle: "\(appInfo.name) v\(appInfo.version).\(appInfo.build)",
                                    icon: "info.circle"
                                ) {
                                    activeAlert = .appInfo
                                }
                                .padding()

                                Divider()

                                SettingsInfoRow(
                                    title: "App Launches",
                                    subtitle: "\(usageTracker.launches) times",
                                    icon: "chart.bar.fill"
                                )
                                .padding()
                            }
                        }

                    }
                    .padding(.vertical)
                }
                .navigationTitle("Settings")
            }
            .sheet(item: $activeSheet) { sheetType in
                switch sheetType {
                case .appearance:
                    AppearanceSelectionView()
                case .survey:
                    SurveyWebView(url: URL(string: Configuration.App.surveyURL)!)
                case .privacy:
                    SurveyWebView(url: URL(string: Configuration.App.privacyPolicyURL)!)
                case .support:
                    ContactSupportView()
                }
            }
            .sheet(isPresented: $showingSurvey) {
                SurveyWebView(url: URL(string: Configuration.App.surveyURL)!)
            }
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .appInfo:
                    Alert(
                        title: Text("App Information"),
                        message: Text(AppSettings.shared.getDeviceInfo()),
                        primaryButton: .default(Text("Copy")) {
                            UIPasteboard.general.string = AppSettings.shared.getDeviceInfo()
                        },
                        secondaryButton: .cancel(Text("OK"))
                    )
                }
            }
        }
    }

    @MainActor
    private func requestAppReview() {
        AnalyticsManager.shared.track("rate_app_tapped")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }

struct SettingsInfoRow: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct SettingsRowWithIcon: View {
    let title: String
    let subtitle: String?
    let icon: String
    let isDisabled: Bool
    let showWarning: Bool
    let action: () -> Void

    private let warningColor = Color(red: 255/255.0, green: 104/255.0, blue: 0/255.0, opacity: 1.0)

    init(
        title: String,
        subtitle: String?,
        icon: String,
        isDisabled: Bool = false,
        showWarning: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isDisabled = isDisabled
        self.showWarning = showWarning
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(isDisabled ? .secondary : .primary)

                    if let subtitle = subtitle {
                        HStack {
                            if showWarning {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(warningColor)
                                    .font(.caption)
                            }
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(showWarning ? warningColor : .secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SurveyWebView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            WebView(url: url)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(Color.accentColor)
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - ContactSupportView
struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Contact Support")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    Text("Send us an email at:")
                        .foregroundColor(.secondary)

                    Button(action: {
                        var components = URLComponents()
                        components.scheme = "mailto"
                        components.path = Configuration.App.supportEmail
                        components.queryItems = [
                            URLQueryItem(name: "subject", value: "Support Request for ParPlay App")
                        ]

                        if let url = components.url {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(Configuration.App.supportEmail)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.accentColor)
                            .underline()
                    }
                }

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Text("OK")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}
