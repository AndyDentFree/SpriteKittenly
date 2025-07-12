//
//  ExportConfigEditorView.swift
//  VidExies
//
//  Created by Andy Dent on 12/6/2025.
//

import SwiftUI


struct ExportConfigEditorView: View {
    @Environment(\.dismiss) var dismiss
    var configuration: MovieExportConfiguration
    let configSourceRes: String

    @State private var movieWidth: Int
    @State private var movieHeight: Int
    @State private var keepAspectRatio = true // expecting they will usually pick a standard format
    @State private var fps: Double
    @State private var aspectRatio: CGFloat = 1.0  // keep local copy because reset if pick a known movie size
    @State private var editingWidth: Bool = false
    @State private var editingHeight: Bool = false
    @State private var formatDescription: String
    @State private var justPicked = false  // flag to prevent updateDimensions reacting to state changes

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
        .init(width: 1200, height:  630, title:  "Facebook/Twitter preview"),
    ]

    init(configuration: MovieExportConfiguration) {
        self.configuration = configuration
        let res = configuration.resolution
        movieWidth  = res.width
        movieHeight = res.height
        aspectRatio = configuration.aspectRatio
        fps = configuration.fps
        formatDescription = configuration.movieFormatDescription
        configSourceRes = "Source: \(configuration.sourceResolution.width) × \(configuration.sourceResolution.height)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(configSourceRes)

            Toggle("Keep Aspect Ratio", isOn: $keepAspectRatio)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Width")
                    TextField(
                        "",
                        value: $movieWidth,
                        formatter: NumberFormatter(),
                        onEditingChanged: {editingWidth = $0}
                    )
                    .onChangeOf(movieWidth) { _ in
                        updateDimensions()
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                }
                VStack(alignment: .leading) {
                    Text("Height")
                    TextField(
                        "",
                        value: $movieHeight,
                        formatter: NumberFormatter(),
                        onEditingChanged: {editingHeight = $0}
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChangeOf(movieHeight) { _ in
                        updateDimensions()
                    }
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                }
            }

            Menu {
                // reverse because SwiftUI reverses on display
                ForEach(commonResolutions.reversed(), id: \.self) { rez in
                    let pickedDescription = "\(String(rez.width)) × \(String(rez.height))\n\(rez.title)"
                    Button(pickedDescription) {
                        movieWidth = rez.width
                        movieHeight = rez.height
                        aspectRatio = CGFloat(rez.width) / CGFloat(rez.height)
                        formatDescription = pickedDescription.replacingOccurrences(of: "\n", with: " ") + " @ \(fps)fps"
                        justPicked = true
                    }
                }
            }  label: {
                HStack(spacing: 4) {
                    Text("Common Resolutions")
#if os(iOS)
                    Image(systemName: "chevron.down")  // Mac has own down-chevron
#endif
                }
                //.font(.body)                    // DynamicType–aware font
                .foregroundColor(.accentColor)      // or whatever color you need
            }

            HStack {
                Text("fps")
                TextField(
                    "",
                    value: $fps,
                    formatter: NumberFormatter()
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
#if os(iOS)
                .keyboardType(.decimalPad)
#endif
            }
            Spacer()

            Button("Done") {
                configuration.resolution = MovieRez(width: movieWidth, height: movieHeight)
                configuration.fps = fps
                configuration.movieFormatDescription = formatDescription
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
        }
    }

    private func updateDimensions() {
        guard !justPicked else {return}
        justPicked = false
        formatDescription = "Specified resolution: \(movieWidth)x\(movieHeight) @ \(fps)fps"
        guard keepAspectRatio else {return}

        // using flags only true when have actually started editing a field to guard against setters
        if editingWidth {
            movieHeight = Int(CGFloat(movieWidth) / aspectRatio)
        } else if editingHeight {
            movieWidth = Int(CGFloat(movieHeight) * aspectRatio)
        }
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
