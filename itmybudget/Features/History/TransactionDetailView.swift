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
                    VStack(alignment: .leading, spacing: 24) {
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
        .alert("transaction_detail.delete_title".localized, isPresented: $showingDeleteAlert) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("transaction_detail.delete_transaction".localized, role: .destructive) {
                dismiss()
            }
        } message: {
            LText("transaction_detail.delete_message")
        }
        .fullScreenCover(isPresented: $showingEditSheet) {
            TransactionFormView(transactionToEdit: transaction)
        }
        .sheet(isPresented: $showingJourneySheet) {
            JourneyDetailSheet(title: "transaction_detail.view_journey".localized)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAnalyticSheet) {
            AnalyticDetailSheet(title: "transaction_detail.view_analysis".localized)
                .presentationDragIndicator(.visible)
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
            
            LText("transaction_detail.title")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Menu {
                Button(action: { showingEditSheet = true }) {
                    Label("transaction_detail.edit_details".localized, systemImage: "pencil")
                }
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("transaction_detail.delete_transaction".localized, systemImage: "trash")
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
                LText("transaction_detail.you_spent")
                    .foregroundStyle(.gray)
                Text(transaction.amountString)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                LText("transaction_detail.on_this_transaction")
                    .foregroundStyle(.gray)
            }
            .font(.system(size: 14))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var tagsFlowLayout: some View {
        FlowLayout(spacing: 8) {
            tagItem(text: transaction.date.formatted(date: .abbreviated, time: .shortened), icon: "calendar", color: .purple)
            tagItem(text: transaction.budgetName, icon: "wallet.pass.fill", color: .blue)
            tagItem(text: "transaction_detail.eating".localized, icon: "fork.knife", color: .orange)
            tagItem(text: "transaction_detail.recurring".localized, icon: "repeat", color: .green)
        }
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
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
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
                content: "transaction_detail.higher_spend".localized,
                cta: "transaction_detail.view_journey".localized,
                onCTATap: {
                    showingJourneySheet = true
                }
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var locationMapSection: some View {
        SectionContainer(title: "transaction_detail.location".localized) {
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
                        LText("transaction_detail.view_on_maps")
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
            }
        }
    }
    
    private var photoGallerySection: some View {
        SectionContainer(title: "transaction_detail.photos".localized) {
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
            LText(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
                .padding(.horizontal, 16)
            
            content
                .padding(.horizontal, 16)
        }
    }
}
