//
//  CatalogControls.swift
//  AlertCatalog
//
//  Controls the pages share, so every page offers its knobs the same way on
//  every platform.
//

import SwiftUI

/// A labeled stepper over whole numbers that shows its value.
struct CatalogStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    init(_ title: String, value: Binding<Int>, in range: ClosedRange<Int>) {
        self.title = title
        _value = value
        self.range = range
    }

    var body: some View {
        Stepper(value: $value, in: range) {
            HStack {
                Text(title)
                Spacer()
                Text(value, format: .number)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// A labeled slider that shows its value.
struct CatalogSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: (Double) -> String

    init(
        _ title: String,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double,
        format: @escaping (Double) -> String,
    ) {
        self.title = title
        _value = value
        self.range = range
        self.step = step
        self.format = format
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(format(value))
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
                .accessibilityLabel(title)
        }
    }
}

/// A picker over a fixed set of choices, drawn as segments.
///
/// The title is drawn above the picker on every platform: SwiftUI hides a segmented
/// picker's own title outside a `Form` on iOS.
struct CatalogPicker<Option: Hashable>: View {
    let title: String
    @Binding var selection: Option
    let options: [Option]
    let label: (Option) -> String

    init(
        _ title: String,
        selection: Binding<Option>,
        options: [Option],
        label: @escaping (Option) -> String,
    ) {
        self.title = title
        _selection = selection
        self.options = options
        self.label = label
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(label(option)).tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
        }
    }
}

/// A labeled text field with its label above it, the same on every platform.
struct CatalogTextField: View {
    let title: String
    @Binding var text: String
    let isMultiline: Bool

    init(_ title: String, text: Binding<String>, isMultiline: Bool = false) {
        self.title = title
        _text = text
        self.isMultiline = isMultiline
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
            TextField(title, text: $text, axis: isMultiline ? .vertical : .horizontal)
                .textFieldStyle(.roundedBorder)
                .lineLimit(isMultiline ? 2 ... 6 : 1 ... 1)
                .labelsHidden()
        }
    }
}

/// A label and a value that changes as the demo runs, such as the text an input alert
/// returned. The value is monospaced so it does not jitter as it updates.
struct CatalogReadout: View {
    let title: String
    let value: String

    init(_ title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .font(.callout.monospaced())
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
                .truncationMode(.middle)
                .accessibilityIdentifier("readout.\(title)")
        }
        .font(.callout)
    }
}

/// A short note under a demo, for a caveat or a hint on what to try.
struct CatalogNote: View {
    let text: String
    let systemImage: String

    init(_ text: String, systemImage: String = "lightbulb") {
        self.text = text
        self.systemImage = systemImage
    }

    var body: some View {
        Label {
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: systemImage)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
