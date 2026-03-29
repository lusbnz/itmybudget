import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<10) { _ in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Shopping")
                                .font(.headline)
                            Text("Today")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                        Text("-$20.00")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("History")
            .scrollContentBackground(.hidden)
            .background(.clear)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
}
