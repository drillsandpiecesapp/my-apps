import Foundation
import UIKit

func buildProjectShareText(project: Project, totalTime: TimeInterval, includeNotes: Bool = true) -> String {
    var lines: [String] = []
    lines.append("Check out my project: \(project.title)")
    lines.append("\(project.projectType.rawValue) • \(project.status.rawValue)")

    var details: [String] = []
    if project.projectType == .diamondArt {
        if let w = project.widthCm, let h = project.heightCm {
            details.append("\(w)x\(h) \(project.dimensionUnit)")
        }
        details.append("\(project.shape.rawValue) drills")
    }

    if let count = project.numberOfDrills {
        let unit = project.projectType == .diamondArt ? "drills" : "pieces"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedCount = formatter.string(from: NSNumber(value: count)) ?? "\(count)"
        details.append("\(formattedCount) \(unit)")
    }

    if !details.isEmpty {
        lines.append(details.joined(separator: " • "))
    }

    if totalTime > 0 {
        lines.append("Time spent: \(formatDuration(totalTime))")
    }

    if let artist = project.artistMaker, !artist.isEmpty {
        lines.append("Brand/Artist: \(artist)")
    }

    if let link = project.purchaseLink, !link.isEmpty {
        lines.append("Where I bought it: \(link)")
    }

    if let cost = project.cost {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        if let formattedCost = formatter.string(from: NSNumber(value: cost)) {
            lines.append("Cost: \(formattedCost)")
        }
    }

    if includeNotes, !project.notes.isEmpty {
        lines.append("\nNotes:\n\(project.notes)")
    }

    return lines.joined(separator: "\n")
}

func prepareSharedImage(from imagePath: String) -> UIImage? {
    guard let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
        return nil
    }

    let maxDimension: CGFloat = 1600
    let size = image.size
    if size.width <= maxDimension && size.height <= maxDimension {
        return image
    }

    let scale = maxDimension / max(size.width, size.height)
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return scaledImage ?? image
}
