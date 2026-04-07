import SwiftUI

struct SimpleTransactionListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let transactions: [Transaction]
    @State private var selectedTransaction: Transaction? = nil
    
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
                
                Spacer()
                
                Button(action: {
                    showingAddSheet = true
                }) {
                    HStack(spacing: 6) {
                        Text("Add New")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .clipShape(Capsule())
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 4) {
                let total = (transactions).reduce(0.0) { sum, tr in
                    sum + (tr.type == .outcome ? tr.amount : 0)
                }
                
                HStack(spacing: 4) {
                    Text("You spent")
                        .foregroundStyle(.gray)
                    Text("$\(Int(total))")
                        .fontWeight(.bold)
                    Text("in this list")
                        .foregroundStyle(.gray)
                }
                .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(transactions) { transaction in
                        TransactionItemView(transaction: transaction) {
                            selectedTransaction = transaction
                        }
                    }
                    
                    if transactions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.gray.opacity(0.3))
                            Text("No transactions found")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                        }
                        .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 12)
                
                Spacer(minLength: 100)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
        .sheet(isPresented: $showingAddSheet) {
            TransactionFormView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
