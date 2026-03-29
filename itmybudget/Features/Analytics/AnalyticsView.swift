import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue.opacity(0.1))
                        .frame(height: 200)
                        .overlay {
                            Text("Spending Analysis Chart")
                                .foregroundStyle(.blue)
                        }
                        .padding()
                }
            }
            .navigationTitle("Analytics")
            .background(.clear)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
}
