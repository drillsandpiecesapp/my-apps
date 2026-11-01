import SwiftUI

struct DrillStockView: View {
    @Bindable var store: AppStore
    @State private var showingAddStock = false
    @State private var code = ""
    @State private var colorName = ""
    @State private var type: DrillType = .standard
    @State private var shape: DrillShape = .round
    @State private var quantity = "1"

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.stock) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("DMC \(item.colorCode)")
                                .font(.headline)
                            if !item.colorName.isEmpty {
                                Text(item.colorName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("\(item.type.rawValue) • \(item.shape.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("Qty: \(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
                .onDelete { indexSet in
                    store.stock.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Drill Stock")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddStock = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddStock) {
                NavigationStack {
                    Form {
                        TextField("Color Code (e.g. 310)", text: $code)
                        TextField("Color Name (optional)", text: $colorName)
                        Picker("Type", selection: $type) {
                            ForEach(DrillType.allCases) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        Picker("Shape", selection: $shape) {
                            ForEach(DrillShape.allCases) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.numberPad)
                    }
                    .navigationTitle("Add Drill Stock")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { showingAddStock = false }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Save") {
                                let stockItem = DrillStock(
                                    colorCode: code.trimmingCharacters(in: .whitespaces),
                                    colorName: colorName.trimmingCharacters(in: .whitespaces),
                                    type: type,
                                    shape: shape,
                                    quantity: Int(quantity) ?? 0
                                )
                                store.stock.append(stockItem)
                                showingAddStock = false
                                code = ""
                                colorName = ""
                            }
                            .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
        }
    }
}
