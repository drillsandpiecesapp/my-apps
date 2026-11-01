import SwiftUI

struct AddEditProjectView: View {
    @Bindable var store: AppStore
    var project: Project?
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var projectType: ProjectType = .diamondArt
    @State private var status: ProjectStatus = .inStash
    @State private var artistMaker = ""
    @State private var renderingType: RenderingType = .unknown
    @State private var numberOfDrills = ""
    @State private var width = ""
    @State private var height = ""
    @State private var dimensionUnit = "cm"
    @State private var shape: DrillShape = .round
    @State private var specialDrillsIncluded = false
    @State private var purchaseLink = ""
    @State private var cost = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Project Title *", text: $title)
                    Picker("Project Type", selection: $projectType) {
                        ForEach(ProjectType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                    TextField("Artist / Maker", text: $artistMaker)
                    TextField("Purchase Link", text: $purchaseLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section("Specs") {
                    Picker("Rendering Type", selection: $renderingType) {
                        ForEach(RenderingType.allCases) { rt in
                            Text(rt.rawValue).tag(rt)
                        }
                    }
                    TextField(projectType == .diamondArt ? "Number of Drills" : "Number of Pieces", text: $numberOfDrills)
                        .keyboardType(.numberPad)

                    if projectType == .diamondArt {
                        HStack {
                            TextField("Width", text: $width)
                                .keyboardType(.numberPad)
                            TextField("Height", text: $height)
                                .keyboardType(.numberPad)
                            Picker("Unit", selection: $dimensionUnit) {
                                Text("cm").tag("cm")
                                Text("in").tag("in")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 100)
                        }
                        Picker("Drill Shape", selection: $shape) {
                            ForEach(DrillShape.allCases) { sh in
                                Text(sh.rawValue).tag(sh)
                            }
                        }
                        Toggle("Special drills included", isOn: $specialDrillsIncluded)
                    }
                }

                Section("Financial & Notes") {
                    TextField("Cost ($)", text: $cost)
                        .keyboardType(.decimalPad)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(project == nil ? "Add Project" : "Edit Project")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let p = project {
                    title = p.title
                    projectType = p.projectType
                    status = p.status
                    artistMaker = p.artistMaker ?? ""
                    renderingType = p.renderingType
                    numberOfDrills = p.numberOfDrills.map { String($0) } ?? ""
                    width = p.widthCm.map { String($0) } ?? ""
                    height = p.heightCm.map { String($0) } ?? ""
                    dimensionUnit = p.dimensionUnit
                    shape = p.shape
                    specialDrillsIncluded = p.specialDrillsIncluded
                    purchaseLink = p.purchaseLink ?? ""
                    cost = p.cost.map { String($0) } ?? ""
                    notes = p.notes
                }
            }
        }
    }

    private func saveProject() {
        let cleanLink = purchaseLink.trimmingCharacters(in: .whitespaces)
        let finalLink: String? = cleanLink.isEmpty ? nil : (cleanLink.hasPrefix("http") ? cleanLink : "https://\(cleanLink)")

        let p = Project(
            id: project?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespaces),
            projectType: projectType,
            status: status,
            widthCm: Int(width),
            heightCm: Int(height),
            dimensionUnit: dimensionUnit,
            shape: shape,
            cost: Double(cost),
            notes: notes.trimmingCharacters(in: .whitespaces),
            imageUris: project?.imageUris ?? "",
            purchaseLink: finalLink,
            artistMaker: artistMaker.trimmingCharacters(in: .whitespaces).isEmpty ? nil : artistMaker,
            renderingType: renderingType,
            numberOfDrills: Int(numberOfDrills),
            specialDrillsIncluded: specialDrillsIncluded,
            createdAt: project?.createdAt ?? Date()
        )
        store.upsert(p)
        dismiss()
    }
}
