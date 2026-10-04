//
//  CatalogPageScaffold.swift
//  AlertCatalog
//
//  The chrome every page shares: the explanation at the top, the buttons
//  that present the page's alerts, the controls for the knobs the page is
//  about, what the alerts did, and a collapsible snippet of the code behind
//  it.
//

import SwiftUI

/// A button on a page that presents an alert.
struct CatalogDemo: Identifiable {
    let title: String
    let systemImage: String
    let action: () -> Void

    var id: String {
        title
    }

    init(_ title: String, systemImage: String = "rectangle.on.rectangle", action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
}

/// Lays out a page that scrolls: explanation, demos, controls, events, then code.
///
/// ```swift
/// CatalogPageScaffold(.basicAlert, code: Self.code, log: log, demos: [
///     CatalogDemo("Present Alert") { presentAlert() },
/// ]) {
///     TextField("Title", text: $title)
/// }
/// ```
struct CatalogPageScaffold<Controls: View>: View {
    let page: CatalogPageID
    let code: String
    let log: CatalogEventLog?
    let demos: [CatalogDemo]
    @ViewBuilder let controls: Controls

    init(
        _ page: CatalogPageID,
        code: String,
        log: CatalogEventLog? = nil,
        demos: [CatalogDemo],
        @ViewBuilder controls: () -> Controls,
    ) {
        self.page = page
        self.code = code
        self.log = log
        self.demos = demos
        self.controls = controls()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CatalogPageHeader(page: page)

                CatalogDemoGrid(demos: demos)

                if Controls.self != EmptyView.self {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Controls")
                            .font(.headline)
                        controls
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("catalog.controls")
                }

                if let log {
                    CatalogEventLogView(log: log)
                }

                CodeSnippetView(code: code)
            }
            .frame(maxWidth: CatalogStyle.readableWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .catalogNavigationTitle(page.title)
        .task {
            await CatalogAutoPresent.runIfRequested(demos.first)
        }
    }
}

extension CatalogPageScaffold where Controls == EmptyView {
    init(
        _ page: CatalogPageID,
        code: String,
        log: CatalogEventLog? = nil,
        demos: [CatalogDemo],
    ) {
        self.init(page, code: code, log: log, demos: demos) {
            EmptyView()
        }
    }
}

/// The page's demo buttons in a card, as many to a row as fit.
struct CatalogDemoGrid: View {
    let demos: [CatalogDemo]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], alignment: .leading, spacing: 12) {
            ForEach(demos) { demo in
                Button(action: demo.action) {
                    Label(demo.title, systemImage: demo.systemImage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("catalog.demo.\(demo.title)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatalogStyle.cardBackground, in: RoundedRectangle(cornerRadius: CatalogStyle.cornerRadius))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("catalog.demos")
    }
}

/// Runs the first demo of the page opened at launch when `-autoPresent YES` asks for
/// it, once per process, so scripted screenshots can show an alert.
enum CatalogAutoPresent {
    private static var hasRun = false

    static func runIfRequested(_ demo: CatalogDemo?) async {
        guard CatalogLaunchOptions.current.isAutoPresenting, !hasRun, let demo else {
            return
        }
        // Give the window time to become key before presenting into it. SwiftUI can
        // replace the page right after launch; the replaced page's task is cancelled,
        // and running its demo would log into that page's discarded state.
        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled, !hasRun else {
            return
        }
        hasRun = true
        demo.action()
    }
}

/// The explanation at the top of a page.
struct CatalogPageHeader: View {
    let page: CatalogPageID

    var body: some View {
        Text(page.summary)
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("catalog.summary")
    }
}

/// The minimal code behind a page, collapsed until asked for. The text is plain and kept
/// in step with the page by hand.
struct CodeSnippetView: View {
    let code: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.snappy) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .font(.caption.weight(.semibold))
                    Text("Code")
                        .font(.headline)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("catalog.code.toggle")

            if isExpanded {
                ScrollView(.horizontal) {
                    Text(code)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .fixedSize(horizontal: true, vertical: true)
                        .padding(12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(CatalogStyle.cardBackground, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("catalog.code")
            }
        }
    }
}

/// Shared measurements and colors.
enum CatalogStyle {
    static let readableWidth: CGFloat = 760
    static let cornerRadius: CGFloat = 14

    static var cardBackground: Color {
        Color.secondary.opacity(0.08)
    }
}

extension View {
    /// Sets the navigation title, shown inline where a large title would crowd the page.
    func catalogNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
