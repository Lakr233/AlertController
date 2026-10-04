//
//  CatalogEventLog.swift
//  AlertCatalog
//
//  What the alerts on a page did, newest first: which action was picked,
//  when a dispose completion ran, the text an input alert returned.
//

import SwiftUI

@Observable
final class CatalogEventLog {
    struct Entry: Identifiable {
        let id: Int
        let date: Date
        let text: String
    }

    /// The most recent events, newest first.
    private(set) var entries: [Entry] = []
    private var nextID = 0

    private static let capacity = 6

    func record(_ text: String) {
        entries.insert(Entry(id: nextID, date: .now, text: text), at: 0)
        nextID += 1
        if entries.count > Self.capacity {
            entries.removeLast(entries.count - Self.capacity)
        }
    }

    func clear() {
        entries.removeAll()
    }
}

/// The events of a page, or a hint while there are none.
struct CatalogEventLogView: View {
    let log: CatalogEventLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Events")
                    .font(.headline)
                Spacer()
                if !log.entries.isEmpty {
                    Button("Clear") { log.clear() }
                        .buttonStyle(.borderless)
                        .font(.callout)
                }
            }
            if log.entries.isEmpty {
                Text("Present an alert and pick an action; what happens shows up here.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(log.entries) { entry in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(entry.date, format: .dateTime.hour().minute().second())
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        Text(entry.text)
                            .font(.callout)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("catalog.events")
    }
}
