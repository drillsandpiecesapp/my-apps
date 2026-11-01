import Foundation
import SwiftUI

@Observable
class AppStore {
    var projects: [Project] = [] { didSet { save() } }
    var sessions: [WorkSession] = [] { didSet { saveSessions() } }
    var stock: [DrillStock] = [] { didSet { saveStock() } }
    var isCompactView: Bool = false

    private let projectsFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("projects.json")
    private let sessionsFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions.json")
    private let stockFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("stock.json")

    init() {
        load()
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: projectsFile)
        } catch {
            print("Failed to save projects: \(error)")
        }
    }

    func load() {
        do {
            if let data = try? Data(contentsOf: projectsFile) {
                projects = try JSONDecoder().decode([Project].self, from: data)
            }
            if let data = try? Data(contentsOf: sessionsFile) {
                sessions = try JSONDecoder().decode([WorkSession].self, from: data)
            }
            if let data = try? Data(contentsOf: stockFile) {
                stock = try JSONDecoder().decode([DrillStock].self, from: data)
            }
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    func saveSessions() {
        try? JSONEncoder().encode(sessions).write(to: sessionsFile)
    }

    func saveStock() {
        try? JSONEncoder().encode(stock).write(to: stockFile)
    }

    func upsert(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.insert(project, at: 0)
        }
    }

    func delete(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        sessions.removeAll { $0.projectId == project.id }
    }

    func totalTime(for projectId: UUID) -> TimeInterval {
        let projectSessions = sessions.filter { $0.projectId == projectId }
        var total = projectSessions.reduce(0) { $0 + $1.endMs.timeIntervalSince($1.startMs) }
        if let p = projects.first(where: { $0.id == projectId }), let start = p.timerStartMs {
            total += Date().timeIntervalSince(start)
        }
        return max(0, total)
    }

    func overallTotalTime() -> TimeInterval {
        return projects.reduce(0) { $0 + totalTime(for: $1.id) }
    }
}

func formatDuration(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 {
        return String(format: "%d:%02d:%02d", h, m, s)
    } else {
        return String(format: "%02d:%02d", m, s)
    }
}
