import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    @State private var showSearch = false
    @State private var showFilter = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 20)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray.opacity(0.4))
                        
                        Text("No transactions yet")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 100)
                    .offset(y: showContent ? 0 : 20)
                    .opacity(showContent ? 1 : 0)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("History")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    showSearch.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showContent ? 0 : 10)
                .opacity(showContent ? 1 : 0)
                
                Button(action: {
                    showFilter = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showContent ? 0 : 10)
                .opacity(showContent ? 1 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
}
