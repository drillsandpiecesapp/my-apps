import Foundation

enum DrillShape: String, Codable, CaseIterable, Identifiable {
    case round = "Round"
    case square = "Square"
    case other = "Other"
    var id: String { rawValue }
}

enum DrillType: String, Codable, CaseIterable, Identifiable {
    case standard = "Standard"
    case ab = "AB (Aurora Borealis)"
    case fairyDust = "Fairy Dust"
    case translucent = "Translucent"
    case rhinestone = "Rhinestone"
    case glitter = "Glitter"
    case metallic = "Metallic"
    case glowInTheDark = "Glow in the Dark"
    case crystalAb = "Crystal AB"
    case sparkle = "Sparkle"
    case neon = "Neon"
    case pearl = "Pearl"
    case custom = "Custom / Other"
    var id: String { rawValue }
}

enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case wishlist = "Wish list"
    case ordered = "Ordered"
    case inStash = "In stash"
    case inProgress = "In progress"
    case done = "Done"
    var id: String { rawValue }
}

enum ProjectType: String, Codable, CaseIterable, Identifiable {
    case diamondArt = "Diamond Art"
    case puzzles = "Puzzles"
    case legos = "Legos"
    var id: String { rawValue }
}

enum RenderingType: String, Codable, CaseIterable, Identifiable {
    case unknown = "Unknown"
    case handRendered = "Hand Rendered"
    case aiRendered = "AI Rendered"
    case hybrid = "Hybrid"
    var id: String { rawValue }
}

struct Project: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var projectType: ProjectType = .diamondArt
    var status: ProjectStatus = .inStash
    var widthCm: Int? = nil
    var heightCm: Int? = nil
    var dimensionUnit: String = "cm"
    var shape: DrillShape = .round
    var cost: Double? = nil
    var rating: Int? = nil
    var notes: String = ""
    var imageUris: String = "" // comma separated
    var barcode: String? = nil
    var purchaseLink: String? = nil
    var artistMaker: String? = nil
    var renderingType: RenderingType = .unknown
    var numberOfDrills: Int? = nil
    var specialDrillsIncluded: Bool = false
    var orderedAt: Date? = nil
    var arrivedAt: Date? = nil
    var startedAt: Date? = nil
    var finishedAt: Date? = nil
    var createdAt: Date = Date()
    var timerStartMs: Date? = nil

    func getImageList() -> [String] {
        if imageUris.isEmpty { return [] }
        return imageUris.split(separator: ",").map { String($0) }.filter { !$0.isEmpty }
    }

    func coverImage() -> String? {
        return getImageList().first
    }
}

struct WorkSession: Identifiable, Codable {
    var id: UUID = UUID()
    var projectId: UUID
    var startMs: Date
    var endMs: Date
}

struct DrillStock: Identifiable, Codable {
    var id: UUID = UUID()
    var colorCode: String
    var colorName: String = ""
    var type: DrillType = .standard
    var customTypeName: String? = nil
    var shape: DrillShape = .round
    var quantity: Int = 0
    var barcode: String? = nil
}
