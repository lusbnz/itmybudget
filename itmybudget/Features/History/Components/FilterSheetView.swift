import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var loc
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
                    
                    Spacer(minLength: 100)
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
        .onChange(of: loc.currentLanguage) {
            categories = Category.sampleData
        }
    }
    
    private var filterHeader: some View {
        HStack {
            LText("history.filter_transactions")
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
            LText("history.transaction_type")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            HStack(spacing: 0) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedType = type
                        }
                    }) {
                        Text(type.localizedName)
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
            LText("history.category")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }) {
                    BudgetCategoryCard(title: "history.all_categories".localized, icon: "square.grid.2x2.fill", color: .gray, isSelected: selectedCategory == nil)
                }
                .buttonStyle(BouncyButtonStyle())
                
                ForEach(categories) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }) {
                        BudgetCategoryCard(title: category.name, icon: category.icon, color: category.color, isSelected: selectedCategory?.name == category.name)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { dismiss() }) {
                LText("history.apply_filters")
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
                LText("history.reset_filters")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 14)
    }
    

}
