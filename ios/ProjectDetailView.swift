import SwiftUI

struct ProjectDetailView: View {
    @Bindable var store: AppStore
    var project: Project

    @State private var isEditing = false
    @State private var notes: String = ""
    @State private var showingShareDialog = false
    @State private var includeCoverImage = true
    @State private var includeNotes = true
    @State private var timerTimer: Timer? = nil
    @State private var now = Date()

    var currentProject: Project {
        store.projects.first(where: { $0.id == project.id }) ?? project
    }

    var body: some View {
        Form {
            // Images section
            if !currentProject.getImageList().isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(currentProject.getImageList(), id: \.self) { imgStr in
                                if let url = URL(string: imgStr), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(10)
                                        .clipped()
                                }
                            }
                        }
                    }
                }
            }

            // Timer & Status Section
            Section("Timer & Status") {
                HStack {
                    Text("Time Spent:")
                    Spacer()
                    Text(formatDuration(store.totalTime(for: currentProject.id)))
                        .fontWeight(.bold)
                }

                Button(action: {
                    toggleTimer()
                }) {
                    Label(currentProject.timerStartMs == nil ? "Start Timer" : "Pause Timer", systemImage: currentProject.timerStartMs == nil ? "play.fill" : "pause.fill")
                }

                Picker("Status", selection: Binding(
                    get: { currentProject.status },
                    set: { newStatus in
                        var p = currentProject
                        p.status = newStatus
                        store.upsert(p)
                    }
                )) {
                    ForEach(ProjectStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }

            // Details Section
            Section("Details") {
                if let artist = currentProject.artistMaker, !artist.isEmpty {
                    LabeledContent("Artist / Maker", value: artist)
                }
                LabeledContent("Rendering", value: currentProject.renderingType.rawValue)
                if let count = currentProject.numberOfDrills {
                    LabeledContent(currentProject.projectType == .diamondArt ? "Number of Drills" : "Number of Pieces", value: "\(count)")
                }
                if currentProject.projectType == .diamondArt {
                    if let w = currentProject.widthCm, let h = currentProject.heightCm {
                        LabeledContent("Dimensions", value: "\(w) x \(h) \(currentProject.dimensionUnit)")
                    }
                    LabeledContent("Shape", value: currentProject.shape.rawValue)
                    LabeledContent("Special Drills", value: currentProject.specialDrillsIncluded ? "Yes" : "No")
                }
                if let cost = currentProject.cost {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    LabeledContent("Cost", value: formatter.string(from: NSNumber(value: cost)) ?? "\(cost)")
                }
            }

            // Purchase Link Section
            if let link = currentProject.purchaseLink, !link.isEmpty {
                Section("Purchase Link") {
                    HStack {
                        if let url = URL(string: link) {
                            Link(link, destination: url)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = link
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
            }

            // Notes Section
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                    .onChange(of: notes) { _, newValue in
                        var p = currentProject
                        p.notes = newValue
                        store.upsert(p)
                    }
            }
        }
        .navigationTitle(currentProject.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingShareDialog = true }) {
                        Label("Share project", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {
                        let text = buildProjectShareText(project: currentProject, totalTime: store.totalTime(for: currentProject.id))
                        UIPasteboard.general.string = text
                    }) {
                        Label("Copy project text", systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive, action: {
                        store.delete(currentProject)
                    }) {
                        Label("Delete project", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            notes = currentProject.notes
            if currentProject.timerStartMs != nil {
                startTicker()
            }
        }
        .sheet(isPresented: $showingShareDialog) {
            ShareDialogView(project: currentProject, totalTime: store.totalTime(for: currentProject.id), includeCoverImage: $includeCoverImage, includeNotes: $includeNotes)
        }
    }

    private func toggleTimer() {
        var p = currentProject
        if p.timerStartMs == nil {
            p.timerStartMs = Date()
            startTicker()
        } else {
            if let start = p.timerStartMs {
                let end = Date()
                let session = WorkSession(projectId: p.id, startMs: start, endMs: end)
                store.sessions.append(session)
            }
            p.timerStartMs = nil
            stopTicker()
        }
        store.upsert(p)
    }

    private func startTicker() {
        timerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            now = Date()
        }
    }

    private func stopTicker() {
        timerTimer?.invalidate()
        timerTimer = nil
    }
}

struct ShareDialogView: View {
    var project: Project
    var totalTime: TimeInterval
    @Binding var includeCoverImage: Bool
    @Binding var includeNotes: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if !project.coverImage().isNilOrEmpty {
                    Toggle("Include cover image", isOn: $includeCoverImage)
                }
                if !project.notes.isEmpty {
                    Toggle("Include notes", isOn: $includeNotes)
                }
                Text("Some apps may only send the picture. You can use Copy to clipboard to paste the text separately.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: {
                    dismiss()
                    shareProjectAction()
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    dismiss()
                    let text = buildProjectShareText(project: project, totalTime: totalTime, includeNotes: includeNotes)
                    UIPasteboard.general.string = text
                }) {
                    Label("Copy to clipboard", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Share Project")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func shareProjectAction() {
        let text = buildProjectShareText(project: project, totalTime: totalTime, includeNotes: includeNotes)
        var items: [Any] = [text]

        if includeCoverImage, let coverPath = project.coverImage(), let scaledImage = prepareSharedImage(from: coverPath) {
            items.insert(scaledImage, at: 0)
        }

        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
