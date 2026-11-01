import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("About Drills & Pieces") {
                    Text("This app is free to download and will never contain ads. If you enjoy it and want to support its development, donations are appreciated via Venmo at https://www.venmo.com/u/HokuKai330 (donations/tips are non-refundable). Thank you for using it!")
                        .font(.body)

                    if let url = URL(string: "https://www.venmo.com/u/HokuKai330") {
                        Link(destination: url) {
                            Label("Support via Venmo (@HokuKai330)", systemImage: "heart.fill")
                        }
                    }
                }

                Section("Privacy") {
                    Text("Your privacy is fully protected. This app does not require a login, does not have tracking or analytics, and will not collect any personal data.")
                        .font(.body)
                }

                Section("Community") {
                    if let url = URL(string: "https://discord.gg/RJFk6R4KJk") {
                        Link(destination: url) {
                            Label("Join our Discord", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                    }
                }
            }
            .navigationTitle("About & Support")
        }
    }
}
