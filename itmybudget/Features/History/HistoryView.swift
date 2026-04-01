import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Transaction History")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Spacer()
            
            Text("No transactions yet")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .background(Color(red: 1.0, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
}
