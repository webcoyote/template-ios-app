import SwiftUI

struct SettingsSelectionView<T: CaseIterable & Equatable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    let options: [T]
    let currentSelection: T
    let onSelection: (T) -> Void
    let displayName: (T) -> String
    @Environment(\.dismiss) var dismiss

    private var dynamicHeight: CGFloat {
        let baseHeight: CGFloat = 120 // Navigation bar + padding + done button
        let rowHeight: CGFloat = 44    // Standard iOS row height
        let calculatedHeight = baseHeight + (CGFloat(options.count) * rowHeight)
        let maxHeight: CGFloat = 400   // Don't exceed reasonable size
        return min(calculatedHeight, maxHeight)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.rawValue) { option in
                    Button(action: {
                        onSelection(option)
                        dismiss()
                    }) {
                        HStack {
                            Text(displayName(option))
                                .foregroundColor(.primary)
                            Spacer()
                            if option == currentSelection {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .modifier(iOS16SheetModifier(dynamicHeight: dynamicHeight))
    }
}

struct AppearanceSelectionView: View {
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        SettingsSelectionView(
            title: "Appearance",
            options: AppearanceMode.allCases,
            currentSelection: appSettings.appearanceMode,
            onSelection: { mode in
                appSettings.appearanceMode = mode
            },
            displayName: { $0.displayName }
        )
    }
}

struct iOS16SheetModifier: ViewModifier {
    let dynamicHeight: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.height(dynamicHeight)])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}
