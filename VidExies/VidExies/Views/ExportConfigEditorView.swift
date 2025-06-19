//
//  ExportConfigEditorView.swift
//  VidExies
//
//  Created by Andrew Dent on 12/6/2025.
//

import SwiftUI


struct ExportConfigEditorView: View {
    @Environment(\.dismiss) var dismiss
    var configuration: MovieExportConfiguration
    let configSourceRes: String

    @State private var width: Int
    @State private var height: Int
    @State private var keepAspectRatio = false
    @State private var fps: Double
    
    private let minWidth = 192
    private let minHeight = 144
    private let maxWidth = 4096
    private let maxHeight = 2160
    
    // social media thanks https://sproutsocial.com/insights/social-media-video-specs-guide/
    private let commonResolutions: [MovieRez] = [
        .init(width: 3840, height: 2160, title: "4K 2160p 1:1.9"),
        .init(width: 2560, height: 1440, title: "1440p Quad HD 16:9"),
        .init(width: 2048, height: 1080, title: "2K 1:1.77"),
        .init(width: 1920, height: 1080, title: "1080p Full HD 16:9"),
        .init(width: 1280, height:  720, title: "720p HD, Facebook 16:9"),
        .init(width:  854, height:  480, title: "480p SD 16:9"),
        .init(width:  640, height:  360, title: "360p SD 16:9"),
        .init(width:  462, height:  240, title: "240p SD 16:9"),
        .init(width:  720, height: 1280, title: "Facebook Vertical 9:16"),
        .init(width: 1080, height: 1080, title: "Instagram square"),
        .init(width: 1080, height: 1920, title: "TikTok/Reels 9:16"),
        .init(width: 1200, height: 630, title:  "Facebook/Twitter preview"),
    ]

    init(configuration: MovieExportConfiguration) {
        self.configuration = configuration
        let res = configuration.resolution
        width  = res.width
        height = res.height
        fps = configuration.fps
        configSourceRes = "Source: \(configuration.sourceResolution.width) × \(configuration.sourceResolution.height)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(configSourceRes)
                .font(.headline)

            Toggle("Keep Aspect Ratio", isOn: $keepAspectRatio)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Width")
                    TextField(
                        "",
                        value: $width,
                        formatter: NumberFormatter(),
                        onEditingChanged: { _ in },
                        onCommit: { updateDimensions(changed: .width) }
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                }
                VStack(alignment: .leading) {
                    Text("Height")
                    TextField(
                        "",
                        value: $height,
                        formatter: NumberFormatter(),
                        onEditingChanged: { _ in },
                        onCommit: { updateDimensions(changed: .height) }
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                }
            }

            Menu("Common Resolutions") {  // arrowtriangle.down.fill
                ForEach(commonResolutions, id: \.self) { rez in
                    Button("\(rez.width) × \(rez.height) \(rez.title)") {
                        width = rez.width
                        height = rez.height
                        applyConstraints()
                    }
                }
            }

            Spacer()
            HStack {
                Text("fps")
                TextField(
                    "",
                    value: $fps,
                    formatter: NumberFormatter()
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            }
            Spacer()

            Button("Done") {
                // clamp and commit back
                let w = clamp(width,  min: minWidth, max: maxWidth)
                let h = clamp(height, min: minHeight, max: maxHeight)
                configuration.resolution = MovieRez(width: w, height: h)
                configuration.fps = fps
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
        }
    }

    private enum Changed { case width, height }

    private func updateDimensions(changed: Changed) {
        var w = clamp(width,  min: minWidth, max: maxWidth)
        var h = clamp(height, min: minHeight, max: maxHeight)

        if keepAspectRatio {
            switch changed {
            case .width:
                // recalc height
                h = Int(CGFloat(w) / configuration.aspectRatio)
            case .height:
                // recalc width
                w = Int(CGFloat(h) * configuration.aspectRatio)
            }
        }

        width  = clamp(w, min: minWidth, max: maxWidth)
        height = clamp(h, min: minHeight, max: maxHeight)
    }

    private func applyConstraints() {
        if keepAspectRatio {
            // recalc height from width for simplicity
            height = Int(CGFloat(width) / configuration.aspectRatio)
        }
        width  = clamp(width,  min: minWidth, max: maxWidth)
        height = clamp(height, min: minHeight, max: maxHeight)
    }

    private func clamp(_ value: Int, min: Int, max: Int) -> Int {
        Swift.max(min, Swift.min(value, max))
    }
}



struct ExportConfigEditorView_PreviewWithPopup: View {
    @State private var config = MovieExportConfiguration(resolution: MovieRez(width: 1920, height: 1080))
    @State private var showingEditor = false

    var body: some View {
        Button("Edit Export Settings") {
            showingEditor.toggle()
        }
        .popover(isPresented: $showingEditor) {
            ExportConfigEditorView(configuration: config)
                .frame(width: 300, height: 360)
                .padding()
        }
    }
}


struct ExportConfigEditorView_Preview: PreviewProvider {
    static var previews: some View {
        ExportConfigEditorView_PreviewWithPopup()
    }
}
