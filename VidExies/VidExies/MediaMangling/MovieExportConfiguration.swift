//
//  MovieExportConfiguration.swift
//  VidExies
//
//  Created by Andy Dent on 12/6/2025.
//

import Foundation

// Conformance of 'CGSize' to 'Hashable' is only available in iOS 18.0 or newer;
struct MovieRez: Hashable {
    let width: Int
    let height: Int
    let title: String  // useful for named rez
    var isZero: Bool { width == 0 || height == 0 }
    
    init(width: Int, height: Int, title: String = "") {
        self.width = width
        self.height = height
        self.title = title
    }
    
    func asCGSize() -> CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

// easier to pass class into editors and exporters
class MovieExportConfiguration {
    /// The output video size in pixels.
    var sourceResolution: MovieRez
    var resolution: MovieRez
    var aspectRatio: CGFloat { CGFloat(sourceResolution.width) / CGFloat(sourceResolution.height) }
    var needsSizing: Bool { sourceResolution.isZero }
    var movieAspectRatio: CGFloat { CGFloat(resolution.width) / CGFloat(resolution.height) }
    var movieFormatDescription: String
    
    static let zero = MovieExportConfiguration(resolution: .init(width: 0, height: 0))
    
    /// Frames per second for both rendering and the movie timeline.
    var fps: Double
    
    init(resolution: MovieRez, fps: Double = 30.0 ) {
        self.sourceResolution = resolution
        self.resolution = resolution
        self.fps = fps
        movieFormatDescription = "Matching original: \(resolution.width)x\(resolution.height) @ \(fps)fps"
    }
    
    func useSizeIfNotSet(_ size: CGSize)  {
        if sourceResolution.isZero {
            let viewRez = MovieRez(width: Int(size.width), height: Int(size.height))
            resolution = viewRez
            sourceResolution = viewRez
            movieFormatDescription = "Matching original: \(resolution.width)x\(resolution.height) @ \(fps)fps"
        }
    }
}
