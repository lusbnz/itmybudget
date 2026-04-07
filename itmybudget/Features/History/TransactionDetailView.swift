import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingJourneySheet = false
    @State private var showingAnalyticSheet = false
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
                        
                        Spacer(minLength: 100)
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
        .sheet(isPresented: $showingEditSheet) {
            TransactionFormView(transactionToEdit: transaction)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingJourneySheet) {
            JourneyDetailSheet(title: "Journey Details")
                .presentationDetents([.fraction(0.85)])
        }
        .sheet(isPresented: $showingAnalyticSheet) {
            AnalyticDetailSheet(title: "Detailed Analysis")
                .presentationDetents([.fraction(0.85)])
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
        VStack(alignment: .leading, spacing: 12) {
            Text(transaction.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
            
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
        .padding(.horizontal, 20)
    }
    
    private var tagsFlowLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                tagItem(text: transaction.location, icon: "mappin.and.ellipse", color: .red)
                tagItem(text: transaction.date.formatted(date: .abbreviated, time: .shortened), icon: "calendar", color: .purple)
            }
            
            HStack(spacing: 12) {
                tagItem(text: transaction.budgetName, icon: "wallet.pass.fill", color: .blue)
                tagItem(text: "Eating", icon: "fork.knife", color: .orange)
                tagItem(text: "Recurring", icon: "repeat", color: .green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private func tagItem(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
            
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AIInsightCarousel(
                content: "This transaction is 15% higher than your other average spending. Consider adjusting your next week's budget to stay on track.",
                cta: "View Journey Detail",
                onCTATap: {
                    showingJourneySheet = true
                }
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var locationMapSection: some View {
        SectionContainer(title: "Location") {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.location)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                        Text("View on Apple Maps")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.gray.opacity(0.3))
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
                .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)

                ZStack {
                    // Stylized map background (Zoomed out)
                    Rectangle()
                        .fill(Color(red: 0.95, green: 0.97, blue: 1.0))
                    
                    Canvas { context, size in
                        // Denser grid for "zoomed out" effect
                        let gridPath = Path { p in
                            for i in 1...12 {
                                let x = CGFloat(i) * size.width / 13
                                p.move(to: CGPoint(x: x, y: 0))
                                p.addLine(to: CGPoint(x: x, y: size.height))
                                
                                let y = CGFloat(i) * size.height / 13
                                p.move(to: CGPoint(x: 0, y: y))
                                p.addLine(to: CGPoint(x: size.width, y: y))
                            }
                        }
                        context.stroke(gridPath, with: .color(Color.blue.opacity(0.03)), lineWidth: 0.5)
                        
                        // Smaller/More roads
                        for j in 1...3 {
                            let road = Path { p in
                                p.move(to: CGPoint(x: 0, y: size.height * (0.2 * CGFloat(j))))
                                p.addCurve(to: CGPoint(x: size.width, y: size.height * (0.3 * CGFloat(j))), 
                                          control1: CGPoint(x: size.width * 0.4, y: size.height * 0.1), 
                                          control2: CGPoint(x: size.width * 0.6, y: size.height * 0.8))
                            }
                            context.stroke(road, with: .color(Color.blue.opacity(0.05)), lineWidth: 2)
                        }
                    }
                    
                    // Smaller Pin for zoomed out feel
                    VStack(spacing: 0) {
                        Image(systemName: "mappin")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 3, y: 2)
                        
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 6, height: 3)
                            .scaleEffect(x: 1.5, y: 1)
                    }
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
            }
        }
    }
    
    private var photoGallerySection: some View {
        SectionContainer(title: "Photos") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if transaction.images.isEmpty {
                        ForEach(1...3, id: \.self) { i in
                            photoCard(url: "https://picsum.photos/600/600?random=\(i + 20)")
                        }
                    } else {
                        ForEach(transaction.images, id: \.self) { img in
                            photoCard(url: img)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func photoCard(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ZStack {
                Color.black.opacity(0.02)
                ProgressView()
                    .scaleEffect(0.6)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
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
        .padding(.horizontal, 20)
    }
}
