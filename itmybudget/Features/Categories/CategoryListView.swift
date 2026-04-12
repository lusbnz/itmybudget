import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    var isActive: Bool
}

extension Category {
    static var sampleData: [Category] {
        [
            Category(name: "Food & Drink", icon: "cup.and.saucer.fill", color: .orange, isActive: true),
            Category(name: "Shopping", icon: "cart.fill", color: .blue, isActive: true),
            Category(name: "Transport", icon: "car.fill", color: .green, isActive: true),
            Category(name: "Entertainment", icon: "popcorn.fill", color: .purple, isActive: true),
            Category(name: "Health", icon: "heart.fill", color: .red, isActive: false),
            Category(name: "Education", icon: "book.fill", color: .teal, isActive: true),
            Category(name: "Home", icon: "house.fill", color: .brown, isActive: true),
            Category(name: "Gifts", icon: "gift.fill", color: .pink, isActive: false)
        ]
    }
}

struct CategoryListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categories = Category.sampleData
    @State private var showContent = false
    @State private var showingFormSheet = false
    @State private var selectedCategoryToEdit: Category? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header
                
                subtitle
                
                categoryGrid
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
            .sheet(isPresented: $showingFormSheet) {
                CategoryFormSheet(
                    categoryToEdit: selectedCategoryToEdit,
                    onSave: { updatedCategory in
                        if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
                            categories[index] = updatedCategory
                        } else {
                            categories.insert(updatedCategory, at: 0)
                        }
                    },
                    onDelete: {
                        if let edited = selectedCategoryToEdit {
                            categories.removeAll(where: { $0.id == edited.id })
                        }
                    }
                )
                .presentationDragIndicator(.visible)
            }
        }
    
    private var header: some View {
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
            
            Text("Categories")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Button(action: { 
                selectedCategoryToEdit = nil
                showingFormSheet = true
            }) {
                HStack(spacing: 4) {
                    Text("Create New")
                        .font(.system(size: 12, weight: .bold))
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .foregroundStyle(.white)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.bottom, 8)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
    
    private var subtitle: some View {
        Text("Explore your categories")
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .offset(y: showContent ? 0 : 15)
            .opacity(showContent ? 1 : 0)
    }
    
    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(categories) { category in
                Button(action: {
                    selectedCategoryToEdit = category
                    showingFormSheet = true
                }) {
                    CategoryItemCard(category: category)
                }
                .buttonStyle(BouncyButtonStyle())
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.top, 4)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
}

struct CategoryItemCard: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: category.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(category.color)
                }
                
                Spacer()
                
                if category.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            
            Text(category.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}
