import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.gray)
                        VStack(alignment: .leading) {
                            Text("Quoc Viet")
                                .font(.headline)
                            Text("Premium Member")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Settings") {
                    Label("Account", systemImage: "person")
                    Label("Notifications", systemImage: "bell")
                    Label("Security", systemImage: "lock")
                }
                
                Section {
                    Button(role: .destructive, action: {
                    }) {
                        Text("Log out")
                    }
                }
            }
            .navigationTitle("Profile")
            .scrollContentBackground(.hidden)
            .background(.clear)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
}
