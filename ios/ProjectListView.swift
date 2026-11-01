import SwiftUI

struct ProjectListView: View {
    @Bindable var store: AppStore
    @State private var showingAddProject = false
    @State private var selectedTypeFilter: ProjectType? = nil
    @State private var selectedStatusFilter: ProjectStatus? = nil
    @State private var isMultiSelectMode = false
    @State private var selectedProjectIds = Set<UUID>()

    var filteredProjects: [Project] {
        store.projects.filter { p in
            if let type = selectedTypeFilter, p.projectType != type { return false }
            if let status = selectedStatusFilter, p.status != status { return false }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Overall Summary Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Time Spent Across All Crafts")
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.8))
                    Text(formatDuration(store.overallTotalTime()))
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.accentColor.opacity(0.15))
                .cornerRadius(12)
                .padding()

                // Multi-select bar or filter bar
                if isMultiSelectMode {
                    HStack {
                        Text("\(selectedProjectIds.count) Selected")
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            shareSelectedProjects()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .disabled(selectedProjectIds.isEmpty)
                        .padding(.horizontal)

                        Button(action: {
                            copySelectedProjects()
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        .disabled(selectedProjectIds.isEmpty)

                        Button(action: {
                            isMultiSelectMode = false
                            selectedProjectIds.removeAll()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .padding(.leading)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterButton(title: "All", isSelected: selectedTypeFilter == nil) {
                                selectedTypeFilter = nil
                            }
                            ForEach(ProjectType.allCases) { type in
                                FilterButton(title: type.rawValue, isSelected: selectedTypeFilter == type) {
                                    selectedTypeFilter = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }

                // Project List
                List {
                    ForEach(filteredProjects) { project in
                        NavigationLink(destination: ProjectDetailView(store: store, project: project)) {
                            HStack(alignment: .top, spacing: 12) {
                                if isMultiSelectMode {
                                    Image(systemName: selectedProjectIds.contains(project.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(.accentColor)
                                        .onTapGesture {
                                            if selectedProjectIds.contains(project.id) {
                                                selectedProjectIds.remove(project.id)
                                            } else {
                                                selectedProjectIds.insert(project.id)
                                            }
                                        }
                                        .padding(.top, 8)
                                }

                                if let coverStr = project.coverImage(), let url = URL(string: coverStr), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text("\(project.projectType.rawValue) • \(project.status.rawValue)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Time: \(formatDuration(store.totalTime(for: project.id)))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Drills & Pieces")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { isMultiSelectMode.toggle() }) {
                            Image(systemName: "checklist")
                        }
                        Button(action: { showingAddProject = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddEditProjectView(store: store, project: nil)
            }
        }
    }

    private func shareSelectedProjects() {
        let selectedItems = store.projects.filter { selectedProjectIds.contains($0.id) }
        let combinedText = selectedItems.map { buildProjectShareText(project: $0, totalTime: store.totalTime(for: $0.id)) }.joined(separator: "\n\n---\n\n")
        let av = UIActivityViewController(activityItems: [combinedText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
    }

    private func copySelectedProjects() {
        let selectedItems = store.projects.filter { selectedProjectIds.contains($0.id) }
        let combinedText = selectedItems.map { buildProjectShareText(project: $0, totalTime: store.totalTime(for: $0.id)) }.joined(separator: "\n\n---\n\n")
        UIPasteboard.general.string = combinedText
    }
}

struct FilterButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
