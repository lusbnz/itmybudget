import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var loc
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DBCategory.createdAt) private var categories: [DBCategory]
    @State private var showContent = false
    @State private var showingFormSheet = false
    @State private var selectedCategoryToEdit: DBCategory? = nil
    
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
        .task {
            do {
                let fetchEndpoint = CategoryEndpoint.list
                let serverCategories: [APICategoryResponse] = try await NetworkManager.shared.request(fetchEndpoint)
                for serverCat in serverCategories {
                    let categoryId = serverCat.id
                    let fetchDescriptor = FetchDescriptor<DBCategory>(predicate: #Predicate { $0.id == categoryId })
                    if let existing = try? modelContext.fetch(fetchDescriptor).first {
                        existing.name = serverCat.name
                        existing.icon = serverCat.icon
                        existing.colorHex = serverCat.color
                        existing.isHidden = serverCat.is_hidden
                    } else {
                        let dbCat = DBCategory(
                            id: serverCat.id,
                            name: serverCat.name,
                            icon: serverCat.icon,
                            colorHex: serverCat.color,
                            userId: serverCat.user_id,
                            isDefault: serverCat.is_default,
                            isHidden: serverCat.is_hidden,
                            createdAt: serverCat.created_at,
                            updatedAt: serverCat.updated_at
                        )
                        modelContext.insert(dbCat)
                    }
                }
                try? modelContext.save()
            } catch {
                print("Failed to sync categories: \(error)")
            }
        }
        .onChange(of: loc.currentLanguage) {
            // Language changed, no manual refresh needed for SwiftData models unless localized properties exist
        }
        .sheet(isPresented: $showingFormSheet) {
            CategoryFormSheet(
                categoryToEdit: selectedCategoryToEdit,
                onSave: { name, icon, colorHex, isActive in
                    Task {
                        await saveCategory(name: name, icon: icon, colorHex: colorHex, isActive: isActive)
                    }
                },
                onDelete: {
                    if let category = selectedCategoryToEdit {
                        Task {
                            await deleteCategory(category)
                        }
                    }
                }
            )
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
            
            LText("categories.title")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Button(action: { 
                selectedCategoryToEdit = nil
                showingFormSheet = true
            }) {
                HStack(spacing: 4) {
                    LText("planning.create_new")
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
        LText("categories.explore")
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .offset(y: showContent ? 0 : 15)
            .opacity(showContent ? 1 : 0)
    }
    
    private var categoryGrid: some View {
        Group {
            if categories.isEmpty {
                emptyStateView
            } else {
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
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 64))
                .foregroundStyle(.gray.opacity(0.2))
                .padding(.top, 60)
            
            VStack(spacing: 8) {
                Text("No Categories")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                
                Text("Create your first category to start organizing your transactions.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                selectedCategoryToEdit = nil
                showingFormSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    LText("planning.create_new")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.black)
                .clipShape(Capsule())
                .foregroundStyle(.white)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
    
    private func deleteCategory(_ category: DBCategory) async {
        do {
            let _: EmptyResponse = try await NetworkManager.shared.request(CategoryEndpoint.delete(id: category.id))
            modelContext.delete(category)
            try? modelContext.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    
    private func saveCategory(name: String, icon: String, colorHex: String, isActive: Bool) async {
        do {
            if let edited = selectedCategoryToEdit {
                // Update
                let updated: APICategoryResponse = try await NetworkManager.shared.request(
                    CategoryEndpoint.update(id: edited.id, name: name, isHidden: !isActive, icon: icon, color: colorHex)
                )
                // Sync to DB
                edited.name = updated.name
                edited.icon = updated.icon
                edited.colorHex = updated.color
                edited.isHidden = updated.is_hidden
                try? modelContext.save()
            } else {
                // Create
                let created: APICategoryResponse = try await NetworkManager.shared.request(
                    CategoryEndpoint.create(name: name, icon: icon, color: colorHex)
                )
                // Sync to DB
                let dbCat = DBCategory(
                    id: created.id,
                    name: created.name,
                    icon: created.icon,
                    colorHex: created.color,
                    userId: created.user_id,
                    isDefault: created.is_default,
                    isHidden: created.is_hidden,
                    createdAt: created.created_at,
                    updatedAt: created.updated_at
                )
                modelContext.insert(dbCat)
                try? modelContext.save()
            }
        } catch {
            print("Failed to save category: \(error)")
        }
    }
}

struct CategoryItemCard: View {
    let category: DBCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.from(hex: category.colorHex).opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: category.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.from(hex: category.colorHex))
                }
                
                Spacer()
                
                if !category.isHidden {
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
