import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showContent = false
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        mainTransactionInfo
                        
                        tagsFlowLayout
                        
                        aiInsightSection
                        
                        locationMapSection
                        
                        photoGallerySection
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.top, 24)
                    .offset(y: showContent ? 0 : 20)
                    .opacity(showContent ? 1 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var headerBar: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .buttonStyle(BouncyButtonStyle())
            
            Text("Transaction Detail")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Menu {
                Button(action: { showingEditSheet = true }) {
                    Label("Edit Details", systemImage: "pencil")
                }
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("Delete Transaction", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
    
    private var mainTransactionInfo: some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 12) {
                Text(transaction.name)
                    .font(.system(size: 24, weight: .semibold))
                
                HStack(spacing: 4) {
                    Text("You spent")
                        .foregroundStyle(.gray)
                    Text(transaction.amountString)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    Text("on this transaction")
                        .foregroundStyle(.gray)
                }
                .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                Text(transaction.type == .outcome ? "\(transaction.amountString)" : "\(transaction.amountString)")
                    .font(.system(size: 32, weight: .black))
                
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(transaction.type == .income ? Color.green : Color.black)
                            .frame(width: 16, height: 16)
                        Image(systemName: transaction.type == .income ? "arrow.down" : "arrow.up")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(transaction.type == .income ? "Received" : "Sent")
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 12)
    }
    
    private var tagsFlowLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                tagItem(text: transaction.location)
                tagItem(text: transaction.date.formatted(date: .abbreviated, time: .shortened))
            }
            
            HStack(spacing: 10) {
                tagItem(text: transaction.budgetName)
                tagItem(text: "Eating")
                tagItem(text: "Recurring")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    private func tagItem(text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
            .foregroundStyle(.black.opacity(0.8))
    }
    
    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AIInsightCarousel(
                content: "This transaction is 15% higher than your other average spending. Consider adjusting your next week's budget to stay on track.",
                cta: nil
            )
        }
        .padding(.horizontal, 12)
    }
    
    private var locationMapSection: some View {
        SectionContainer(title: "Location") {
            VStack(alignment: .leading, spacing: 12) {
                Text(transaction.location)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.black.opacity(0.6))

                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.blue.opacity(0.04))
                        .frame(height: 180)
                    
                    Canvas { context, size in
                        let path = Path { p in
                            p.move(to: CGPoint(x: 0, y: 50))
                            p.addLine(to: CGPoint(x: size.width, y: 130))
                            p.move(to: CGPoint(x: size.width * 0.3, y: 0))
                            p.addLine(to: CGPoint(x: size.width * 0.4, y: size.height))
                        }
                        context.stroke(path, with: .color(Color.blue.opacity(0.1)), lineWidth: 3)
                    }
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: .blue.opacity(0.4), radius: 5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.black.opacity(0.05), lineWidth: 1))
            }
        }
    }
    
    private var photoGallerySection: some View {
        SectionContainer(title: "Photos") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if transaction.images.isEmpty {
                        ForEach(1...3, id: \.self) { i in
                            AsyncImage(url: URL(string: "https://picsum.photos/600/600?random=\(i + 10)")) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.black.opacity(0.03)
                            }
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
                        }
                    } else {
                        ForEach(transaction.images, id: \.self) { img in
                            Color.black.opacity(0.03)
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
                        }
                    }
                }
            }
        }
    }
}

struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            content
        }
        .padding(.horizontal, 12)
    }
}
