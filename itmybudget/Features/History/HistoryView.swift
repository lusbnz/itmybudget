import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Transaction.sampleData) { transaction in
                        TransactionItemView(transaction: transaction)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Recent Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
}
