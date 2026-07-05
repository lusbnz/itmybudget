import SwiftUI

struct CategoryFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let categoryToEdit: DBCategory?
    var onSave: (String, String, String, Bool) -> Void
    var onDelete: (() -> Void)? = nil
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "cup.and.saucer.fill"
    @State private var selectedColor: Color = .orange
    @State private var isActive: Bool = true
    
    private let icons = [
        "cup.and.saucer.fill", "cart.fill", "car.fill", "popcorn.fill",
        "heart.fill", "book.fill", "house.fill", "gift.fill",
        "bag.fill", "creditcard.fill", "airplane", "gamecontroller.fill",
        "theatermasks.fill", "leaf.fill", "moped.fill", "graduationcap.fill"
    ]
    
    private let colors: [Color] = [
        .orange, .blue, .green, .purple, .red, .teal, .brown, .pink,
        .cyan, .indigo, .mint, .yellow, .gray, .black
    ]
    
    init(categoryToEdit: DBCategory?, onSave: @escaping (String, String, String, Bool) -> Void, onDelete: (() -> Void)? = nil) {
        self.categoryToEdit = categoryToEdit
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: categoryToEdit?.name ?? "")
        _selectedIcon = State(initialValue: categoryToEdit?.icon ?? "cup.and.saucer.fill")
        _selectedColor = State(initialValue: Color.from(hex: categoryToEdit?.colorHex ?? "#FF9500"))
        _isActive = State(initialValue: !(categoryToEdit?.isHidden ?? false))
    }
    
    private var isEditMode: Bool {
        categoryToEdit != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tên danh mục")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        TextField("ví dụ: Ăn uống", text: $name)
                            .font(.system(size: 16, weight: .medium))
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chọn biểu tượng")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        FlowLayout(spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.15) : Color.white)
                                            .frame(width: 44, height: 44)
                                            .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(selectedIcon == icon ? selectedColor : .gray.opacity(0.4))
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? selectedColor.opacity(0.3) : Color.black.opacity(0.05), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(BouncyButtonStyle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chọn màu sắc")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        FlowLayout(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    ZStack {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 32, height: 32)
                                        
                                        if selectedColor == color {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                                .buttonStyle(BouncyButtonStyle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Trạng thái hoạt động")
                                    .font(.system(size: 14, weight: .bold))
                                Text(isActive ? "Danh mục hiển thị trong danh sách" : "Danh mục bị ẩn")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: $isActive)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .black))
                                .scaleEffect(0.9)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                    }
                }
                .padding(20)
            }
            
            Spacer()
            
            Button(action: {
                if !name.isEmpty {
                    onSave(name, selectedIcon, selectedColor.hexString, isActive)
                    dismiss()
                }
            }) {
                Text(isEditMode ? "Cập nhật danh mục" : "Tạo danh mục")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(20)
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
    
    private var header: some View {
        HStack(alignment: .center) {
            Text(isEditMode ? "Sửa danh mục" : "Danh mục mới")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            if isEditMode {
                Menu {
                    Button(role: .destructive) {
                        onDelete?()
                        dismiss()
                    } label: {
                        Label("Xóa danh mục", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            } 
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
}
