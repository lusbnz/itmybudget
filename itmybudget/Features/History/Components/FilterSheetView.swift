import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedType: TransactionType
    @Binding var selectedBudgetId: UUID?
    @Binding var selectedCategory: Category?
    @Namespace private var filterAnimation
    @State private var categories = Category.sampleData
    
    var body: some View {
        VStack(spacing: 0) {
            filterHeader
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    typeSection
                    
                    categorySection
                    
                    Spacer(minLength: 40)
                }
                .padding(24)
            }
            
            actionButtons
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    private var filterHeader: some View {
        HStack {
            Text("Filter Transactions")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 20)
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transaction Type")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            HStack(spacing: 0) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedType = type
                        }
                    }) {
                        Text(type.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedType == type ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    if selectedType == type {
                                        Capsule()
                                            .fill(Color.black)
                                            .matchedGeometryEffect(id: "typePill", in: filterAnimation)
                                    }
                                }
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }) {
                    budgetCategoryCard(title: "All Categories", icon: "square.grid.2x2.fill", color: .gray, isSelected: selectedCategory == nil)
                }
                .buttonStyle(BouncyButtonStyle())
                
                ForEach(categories) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }) {
                        budgetCategoryCard(title: category.name, icon: category.icon, color: category.color, isSelected: selectedCategory?.name == category.name)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Text("Apply Filters")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(BouncyButtonStyle())
            
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedType = .all
                    selectedBudgetId = nil
                    selectedCategory = nil
                }
                dismiss()
            }) {
                Text("Reset filters")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 14)
    }
    
    private func budgetCategoryCard(title: String, icon: String, color: Color, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 16))
                        .foregroundStyle(.black.opacity(0.1))
                }
            }
            
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: isSelected ? 15 : 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isSelected ? Color.black : Color.black.opacity(0.05), lineWidth: isSelected ? 2 : 1)
        )
    }
}
