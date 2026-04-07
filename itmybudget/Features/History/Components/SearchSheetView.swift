import SwiftUI

struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool
    @State private var selectedTransaction: Transaction? = nil
    
    var filteredResults: [Transaction] {
        if searchText.isEmpty { return [] }
        return Transaction.sampleData.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedResults: [(String, [Transaction])] {
        let filtered = filteredResults
        let grouped = Dictionary(grouping: filtered) { $0.dateString }
        return grouped.sorted { 
            let date0 = grouped[$0.key]?.first?.date ?? Date.distantPast
            let date1 = grouped[$1.key]?.first?.date ?? Date.distantPast
            return date0 > date1
        }.map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            
            ScrollView(showsIndicators: false) {
                resultsContent
                
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
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private var searchHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                TextField("Search your transactions...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
            .onTapGesture {
                isSearchFocused = true
            }
            
            Button("Done") {
                dismiss()
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(.black)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var resultsContent: some View {
        if searchText.isEmpty {
            emptyState(icon: "magnifyingglass", title: "Type something to search")
        } else if filteredResults.isEmpty {
            emptyState(icon: "tray.fill", title: "No transactions found for \"\(searchText)\"")
        } else {
            resultsList
        }
    }
    
    private var resultsList: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
            ForEach(groupedResults, id: \.0) { dateString, transactions in
                timelineSection(dateString: dateString, transactions: transactions)
            }
        }
    }
    
    private func timelineSection(dateString: String, transactions: [Transaction]) -> some View {
        Section(header: dateHeader(dateString, transactions: transactions)) {
            VStack(spacing: 0) {
                ForEach(Array(transactions.enumerated()), id: \.1.id) { index, transaction in
                    timelineRow(index: index, transaction: transaction, totalCount: transactions.count)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private func timelineRow(index: Int, transaction: Transaction, totalCount: Int) -> some View {
        TransactionTimelineItem(
            transaction: transaction,
            isLast: index == totalCount - 1
        ) {
            selectedTransaction = transaction
        }
    }
    
    private func dateHeader(_ text: String, transactions: [Transaction]) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Text(totalAmount(for: transactions))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.98, blue: 0.96).opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func totalAmount(for transactions: [Transaction]) -> String {
        let total = transactions.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) }
        return String(format: "$%.0f", total)
    }
    
    private func emptyState(icon: String, title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.2))
                .padding(.top, 100)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
