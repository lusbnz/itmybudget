import SwiftUI

struct ImageGroup: Identifiable {
    let id = UUID()
    let title: String
    let images: [String]
}

struct TransactionGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    
    // Mock grouped images matching Notification-style time periods
    private let groupedImages: [ImageGroup] = [
        ImageGroup(title: "Date Today", images: (1...6).map { "https://picsum.photos/400?random=\($0+10)" }),
        ImageGroup(title: "Yesterday", images: (7...12).map { "https://picsum.photos/400?random=\($0+20)" }),
        ImageGroup(title: "March 2026", images: (13...21).map { "https://picsum.photos/400?random=\($0+30)" }),
        ImageGroup(title: "February 2026", images: (22...30).map { "https://picsum.photos/400?random=\($0+40)" })
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                    ForEach(groupedImages) { group in
                        Section(header: sectionHeader(group.title)) {
                            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(group.images, id: \.self) { urlString in
                                    AsyncImage(url: URL(string: urlString)) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.05)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.05), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 4)
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
        HStack(spacing: 16) {
            Text("Transaction Images")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            Spacer()
        }
        .background(Color(red: 1.0, green: 0.97, blue: 0.92).opacity(0.95)) // Slight blur/opacity for pinned effect
    }
}

#Preview {
    TransactionGalleryView()
}
