import SwiftUI
import MapKit
import SwiftData

enum TransactionEntryMode: String, CaseIterable, Identifiable {
    case manual = "Thủ công"
    case camera = "Máy ảnh"
    case chat = "Trò chuyện"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        self.rawValue
    }
    
    var icon: String {
        switch self {
        case .manual: return "pencil.line"
        case .camera: return "camera.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        }
    }
}

struct TransactionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DBCategory.createdAt, order: .reverse) private var dbCategories: [DBCategory]
    @Query(sort: \DBBudget.updatedAt, order: .reverse) private var dbBudgets: [DBBudget]
    
    @State private var isSaving = false
    @State private var selectedCategory: Category?
    @State private var selectedBudget: Budget?
    @State private var isShowingImageSourceActionSheet = false

    @State private var selectedMode: TransactionEntryMode = .manual
    @Namespace private var modeNamespace
    
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var transactionType: TransactionType = .outcome
    @Namespace private var typeNamespace
    
    @State private var isShowingCategorySelector = false
    @State private var isShowingBudgetSelector = false
    @State private var isShowingLocationMap = false
    @State private var isShowingTimePicker = false
    
    @State private var isRecurring: Bool = false
    @State private var frequency: String = "Monthly"
    @State private var isNonFixed: Bool = false
    @State private var startDate: Date = Date()
    @State private var frequencyOptions = ["Hàng tuần", "Hàng tháng", "Hàng năm"]
    @Namespace private var tagNamespace
    
    @State private var isCaptured: Bool = false
    @State private var capturedImage: UIImage? = nil
    @State private var cameraAmount: String = "500.000"
    @State private var cameraName: String = ""
    @State private var showContent = false
    @State private var selectedImages: [UIImage] = []
    @State private var selectedLocationName: String = ""
    @State private var isRecurringOpen: Bool = false
    @State private var isShowingImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var inputImage: UIImage? = nil
    
    @State private var chatMessages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your financial assistant. How can I help you today?", isAI: true, time: "9:41 AM"),
        ChatMessage(text: "I spent 45k on eating Pho", isAI: false, time: "9:42 AM"),
        ChatMessage(isTransactionCard: true, transactionName: "Ăn phở", amount: "45.000", time: "9:42 AM")
    ]
    @State private var chatInputText: String = ""
    
    let transactionToEdit: Transaction?
    let isPresentedAsSheet: Bool
    
    init(transactionToEdit: Transaction? = nil, startWithRecurring: Bool = false, initialMode: TransactionEntryMode = .manual, isPresentedAsSheet: Bool = false) {
        self.transactionToEdit = transactionToEdit
        self.isPresentedAsSheet = isPresentedAsSheet
        _isRecurring = State(initialValue: startWithRecurring)
        _selectedLocationName = State(initialValue: transactionToEdit?.location ?? "Add Location")
        _selectedMode = State(initialValue: initialMode)
    }
    
    @State private var chatEditingTransaction: Transaction? = nil
    @State private var isShowingEditTransactionSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 1.0, green: 0.98, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                if selectedMode == .chat {
                    chatEntryView
                } else {
                    ScrollView(showsIndicators: false) {
                        contentView
                            .padding(.top, 10)
                    }
                }
                
                if !isPresentedAsSheet {
                    Spacer(minLength: selectedMode == .chat ? 0 : 80)
                }
            }
            
            if (!isCaptured || selectedMode != .camera) && !isPresentedAsSheet {
                modeSelectorTabs
            } else if selectedMode == .camera && isCaptured {
                cameraActionButtons
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .sheet(isPresented: $isShowingCategorySelector) {
            CategorySelectorSheet(
                categories: dbCategories.map { db in
                    Category(dbId: db.id, name: db.name, icon: db.icon, color: Color(hex: db.colorHex), isActive: !db.isHidden)
                }
            ) { category in
                self.selectedCategory = category
            }
        }
        .sheet(isPresented: $isShowingBudgetSelector) {
            BudgetSelectorSheet(
                budgets: dbBudgets.map { db in
                    Budget(
                        id: db.id,
                        name: db.name,
                        spent: Double(db.spentAmountStr) ?? 0.0,
                        total: Double(db.amountStr) ?? 0.0,
                        dailyLimit: 0,
                        nextTopUp: db.endDate,
                        lastTransactionDate: Date()
                    )
                }
            ) { budget in
                self.selectedBudget = budget
            }
        }
        .sheet(isPresented: $isShowingLocationMap) {
            LocationSelectorSheet()
        }
        .sheet(isPresented: $isShowingTimePicker) {
            TimeSelectorSheet()
        }
        .sheet(isPresented: $isShowingEditTransactionSheet) {
            if let trans = chatEditingTransaction {
                TransactionFormView(transactionToEdit: trans, initialMode: .manual, isPresentedAsSheet: true)
            }
        }
        .fullScreenCover(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $inputImage, sourceType: imagePickerSourceType)
        }
        .onChange(of: inputImage) { oldValue, newValue in
            if let image = newValue {
                selectedImages.append(image)
            }
        }
    }
    
    private var headerSection: some View {
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
            
            Text(transactionToEdit == nil ? "Giao dịch mới" : "Sửa giao dịch")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            if selectedMode == .manual {
                saveButton
                
                if !isPresentedAsSheet {
                    Menu {
                        if transactionToEdit == nil {
                            Button(action: {}) {
                                Label("Lưu bản nháp", systemImage: "square.and.pencil")
                            }
                        } else {
                            Button(role: .destructive, action: { 
                                dismiss() 
                            }) {
                                Label("Xóa", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
        .padding(.top, isPresentedAsSheet ? 10 : 0)
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
    
    private var saveButton: some View {
        Button(action: saveTransaction) {
            if isSaving {
                ProgressView().tint(.white).scaleEffect(0.8)
                    .frame(height: 16)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .clipShape(Capsule())
            } else {
                Text("Lưu")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
            }
        }
        .disabled(isSaving)
        .buttonStyle(BouncyButtonStyle())
    }
    
    private func saveTransaction() {
        guard let budget = selectedBudget else { return } // Should show alert in real app
        guard let category = selectedCategory else { return }
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")) else { return }
        
        let finalAmount: Double
        if transactionType == .outcome {
            finalAmount = -abs(amountValue)
        } else if transactionType == .income {
            finalAmount = abs(amountValue)
        } else {
            finalAmount = amountValue // Adjustment
        }
        
        isSaving = true
        
        Task {
            do {
                var uploadedUrls: [String] = []
                let imagesToUpload = selectedImages + (capturedImage != nil ? [capturedImage!] : [])
                
                if !imagesToUpload.isEmpty {
                    let imageDataArray = imagesToUpload.compactMap { $0.jpegData(compressionQuality: 0.8) }
                    let uploadEndpoint = UploadEndpoint.uploadFiles(images: imageDataArray)
                    let uploadResponse: APIUploadResponse = try await NetworkManager.shared.request(uploadEndpoint)
                    print("✅ Upload success: \(uploadResponse)")
                    if let urls = uploadResponse.urls {
                        uploadedUrls = urls
                    } else if let url = uploadResponse.url {
                        uploadedUrls = [url]
                    } else if let fileUrl = uploadResponse.fileUrl {
                        uploadedUrls = [fileUrl]
                    } else if let data = uploadResponse.data {
                        uploadedUrls = data
                    }
                }
                
                let createRequest = APICreateTransactionRequest(
                    budget_id: budget.id,
                    amount: finalAmount,
                    type: transactionType == .outcome ? "expense" : "income",
                    category_id: category.dbId ?? 1,
                    note: name.isEmpty ? nil : name,
                    images: uploadedUrls.isEmpty ? nil : uploadedUrls
                )
                
                let createEndpoint = TransactionEndpoint.create(request: createRequest)
                let _: EmptyResponse = try await NetworkManager.shared.request(createEndpoint)
                
                // Update local SwiftData
                await MainActor.run {
                    let dbTransaction = DBTransaction(
                        id: Int.random(in: 1...9999999), // Mock ID for offline consistency
                        budgetId: budget.id,
                        categoryId: category.dbId ?? 1,
                        amount: finalAmount,
                        type: transactionType == .outcome ? "expense" : "income",
                        note: name,
                        categoryName: category.name,
                        images: uploadedUrls
                    )
                    modelContext.insert(dbTransaction)
                    
                    // Update Budget Balance locally
                    let bId = budget.id
                    let descriptor = FetchDescriptor<DBBudget>(predicate: #Predicate { $0.id == bId })
                    if let dbBudget = try? modelContext.fetch(descriptor).first {
                        let currentSpent = Double(dbBudget.spentAmountStr) ?? 0.0
                        dbBudget.spentAmountStr = String(format: "%.2f", currentSpent + finalAmount)
                    }
                    
                    isSaving = false
                    dismiss()
                }
                
            } catch {
                print("❌ Failed to save transaction: \(error)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
    
    private var modeSelectorTabs: some View {
        HStack(spacing: 0) {
            ForEach(TransactionEntryMode.allCases) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 12))
                        
                        Text(mode.rawValue)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(selectedMode == mode ? .white : .black.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            if selectedMode == mode {
                                Capsule()
                                    .fill(Color.black)
                                    .matchedGeometryEffect(id: "modePill", in: modeNamespace)
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
        .padding(.horizontal, 25)
        .padding(.top, 15)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white.opacity(0.9), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading) {
            switch selectedMode {
            case .manual:
                manualEntryView
            case .camera:
                cameraEntryView
            case .chat:
                chatEntryView
            }
        }
        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
        .id(selectedMode)
    }
    
    private var manualEntryView: some View {
        VStack(alignment: .leading, spacing: 24) {
            transactionNameSection
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Số tiền")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                HStack {
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("USD")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.gray)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                
                HStack(spacing: 8) {
                    ForEach(dynamicQuickAmounts, id: \.self) { val in
                        Button(action: {
                            amount = String(format: "%.0f", val)
                        }) {
                            Text("\(val > 1000 ? formatCurrency(val) : String(format: "%.0f", val))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 16)
            
            transactionTypeSection
                .padding(.horizontal, 16)
            
            metadataSection
                .padding(.horizontal, 16)
            
            recurringSection
            
            locationSelectionSection
            
            photoSelectionSection
        }
    }

    private var recurringSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 24, height: 24)
                    Image(systemName: "repeat")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Text("Giao dịch định kỳ")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                
                Spacer()
                
                Toggle("", isOn: $isRecurring.animation(.spring()))
                    .labelsHidden()
                    .tint(.black)
                    .scaleEffect(0.8)
                    .frame(width: 44, height: 28)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if isRecurring {
                VStack(spacing: 24) {
                    Divider()
                        .background(Color.black.opacity(0.05))
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tần suất")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(frequencyOptions, id: \.self) { option in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            frequency = option
                                        }
                                    }) {
                                        Text(option)
                                            .font(.system(size: 13, weight: frequency == option ? .bold : .medium))
                                            .foregroundStyle(frequency == option ? .white : .black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                ZStack {
                                                    if frequency == option {
                                                        Capsule()
                                                            .fill(Color.black)
                                                            .matchedGeometryEffect(id: "freqTab", in: tagNamespace)
                                                    } else {
                                                        Capsule()
                                                            .fill(Color.black.opacity(0.05))
                                                    }
                                                }
                                            )
                                    }
                                    .buttonStyle(BouncyButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Số tiền thay đổi")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("Ẩn số tiền nếu giá trị thay đổi")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isNonFixed)
                                .labelsHidden()
                                .tint(.black)
                                .scaleEffect(0.8)
                                .frame(width: 44, height: 28)
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ngày bắt đầu")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("Bắt đầu chu kỳ định kỳ của bạn")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                                .tint(.black)
                                .scaleEffect(0.8)
                                .frame(width: 80, height: 28)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var locationSelectionSection: some View {
        SectionContainer(title: "Vị trí") {
            Button(action: { isShowingLocationMap = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedLocationName == "Add Location" ? "Việc này xảy ra ở đâu?" : selectedLocationName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                        Text(selectedLocationName == "Add Location" ? "Việc này xảy ra ở đâu?" : "Nhấn để thay đổi vị trí")
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
            .buttonStyle(BouncyButtonStyle())
        }
    }
    
    private var photoSelectionSection: some View {
        SectionContainer(title: "Ảnh") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: {
                        isShowingImageSourceActionSheet = true
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.viewfinder")
                                .font(.system(size: 24))
                            Text("Thêm ảnh")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(.gray)
                        .frame(width: 120, height: 120)
                        .background(Color.black.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundStyle(.gray.opacity(0.3))
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .confirmationDialog("Chọn nguồn ảnh", isPresented: $isShowingImageSourceActionSheet) {
                        Button("Thư viện ảnh") {
                            imagePickerSourceType = .photoLibrary
                            isShowingImagePicker = true
                        }
                        Button("Máy ảnh") {
                            imagePickerSourceType = .camera
                            isShowingImagePicker = true
                        }
                        Button("Hủy", role: .cancel) { }
                    }

                    ForEach(selectedImages, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
                            .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
                    }
                    
                    if transactionToEdit != nil {
                        ForEach(transactionToEdit?.images ?? [], id: \.self) { img in
                            photoCard(url: img)
                        }
                    }
                    
                    ForEach(1...2, id: \.self) { i in
                        photoCard(url: "https://picsum.photos/600/600?random=\(i + 40)")
                            .opacity(0.5)
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
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
    
    private func metadataTag(text: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
        .buttonStyle(BouncyButtonStyle())
    }
    
    private func typeTab(type: TransactionType, title: String, icon: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                transactionType = type
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(transactionType == type ? .white : .black.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if transactionType == type {
                        Capsule()
                            .fill(type == .outcome ? Color.orange : Color.green)
                            .matchedGeometryEffect(id: "typePill", in: typeNamespace)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dynamicQuickAmounts: [Double] {
        let base = Double(amount) ?? 1
        let multiplier = (base > 0 && base < 100_000) ? base : 1
        return [multiplier * 10, multiplier * 100, multiplier * 1000]
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
    
    private var cameraEntryView: some View {
        ZStack(alignment: .bottom) {
            if isCaptured {
                capturedFormView
            } else {
                cameraScannerView
            }
        }
    }
    
    private var cameraActionButtons: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring()) { isCaptured = false }
                    }) {
                        Text("Thử lại")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.gray)
                            .frame(width: 110)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1.5))
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    Button(action: saveTransaction) {
                        if isSaving {
                            ProgressView().tint(.white).scaleEffect(0.8)
                                .frame(height: 16)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .clipShape(Capsule())
                        } else {
                            Text("Xác nhận và tạo")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                    }
                    .disabled(isSaving)
                    .buttonStyle(BouncyButtonStyle())
                }
                
                Button(action: { dismiss() }) {
                    Text("Chỉ lưu dưới dạng bản nháp")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.8))
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .background(Color(red: 1.0, green: 0.98, blue: 0.96))
        }
    }
    
    private var cameraScannerView: some View {
        VStack(spacing: 24) {
            ZStack {
                CameraView()
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                
                cornerDecorators
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                Text("Quét biên lai của bạn")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Căn chỉnh biên lai trong khung để có kết quả tốt nhất")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            HStack(spacing: 40) {
                Button(action: {
                    imagePickerSourceType = .photoLibrary
                    isShowingImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 24))
                        .foregroundColor(.black.opacity(0.8))
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {
                    withAnimation(.spring()) { isCaptured = true }
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 4)
                            .frame(width: 80, height: 80)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 66, height: 66)
                        Image(systemName: "camera.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 24))
                    }
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {}) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 24))
                        .foregroundColor(.black.opacity(0.8))
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
    }
    
    private var cornerDecorators: some View {
        ZStack {
            VStack {
                HStack {
                    decoratorLines(rotation: 0)
                    Spacer()
                    decoratorLines(rotation: 90)
                }
                Spacer()
                HStack {
                    decoratorLines(rotation: 270)
                    Spacer()
                    decoratorLines(rotation: 180)
                }
            }
        }
        .padding(40)
    }
    
    private func decoratorLines(rotation: Double) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 40))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 40, y: 0))
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        .frame(width: 40, height: 40)
        .rotationEffect(.degrees(rotation))
    }
    
    private var capturedFormView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ZStack(alignment: .bottom) {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1541014741259-df529411fdc6?q=80&w=1000&auto=format&fit=crop")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ZStack {
                                Color.black.opacity(0.05)
                                ProgressView()
                            }
                        }
                    }
                    
                    amountGlassCard
                        .padding(.bottom, 24)
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 24) {
                    transactionNameSection
                        .padding(.horizontal, 16)
                    
                    transactionTypeSection
                        .padding(.horizontal, 16)
                    
                    metadataSection
                        .padding(.horizontal, 16)
                    
                    locationSelectionSection
                }
                
                Spacer(minLength: 160) 
            }
        }
    }
    
    private func miniTag(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.05))
        .clipShape(Capsule())
        .foregroundStyle(.black.opacity(0.6))
    }
    
    private var chatEntryView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Dòng thời gian")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Capsule())
                    
                    ForEach(chatMessages) { message in
                        if message.isTransactionCard {
                            aiTransactionCard(message: message)
                        } else {
                            chatBubble(message: message)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            
            chatInputBar
            
            Spacer(minLength: 80)
        }
    }
    
    private func chatBubble(message: ChatMessage) -> some View {
        HStack {
            if !message.isAI { Spacer() }
            
            VStack(alignment: message.isAI ? .leading : .trailing, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isAI ? Color.white : Color.black.opacity(0.85))
                    .foregroundStyle(message.isAI ? .black : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
                
                Text(message.time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.gray.opacity(0.6))
                    .padding(.horizontal, 4)
            }
            
            if message.isAI { Spacer() }
        }
        .padding(.horizontal, 20)
    }
    
    private func aiTransactionCard(message: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            chatBubble(message: ChatMessage(
                text: "Hệ thống vừa ghi nhận giao dịch **\(message.transactionName)** với số tiền **\(message.amount)**. Bạn có muốn thêm ghi chú nào không?",
                isAI: true,
                time: message.time
            ))
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.transactionName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        Text("11 Mar • 202 Nguyen Huy Tuong")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("-$\(message.amount)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                        
                        Text("Ăn uống")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.black.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.black.opacity(0.05)))
                    }
                }
                .padding(16)
                
                Divider().background(Color.black.opacity(0.05))
                
                HStack(spacing: 16) {
                    Button(action: {
                    }) {
                        Text("Sửa")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {}) {
                        Text("Lưu bản nháp")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Xác nhận và tạo")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
            .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }
    
    private func actionMiniButton(title: String, icon: String, color: Color, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
        }
        .buttonStyle(BouncyButtonStyle())
    }
    
    private var transactionNameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tên giao dịch")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            TextField(selectedMode == .camera ? "Nhập tên..." : "ví dụ: Cà phê Starbucks", text: selectedMode == .camera ? $cameraName : $name)
                .font(.system(size: 16, weight: selectedMode == .camera ? .semibold : .medium))
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(selectedMode == .camera ? 0.02 : 0), radius: 5, x: 0, y: 2)
        }
    }

    private var transactionTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Loại giao dịch")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
            
            HStack(spacing: 0) {
                typeTab(type: .outcome, title: "Chi tiêu", icon: "arrow.up.right.circle.fill")
                typeTab(type: .income, title: "Thu nhập", icon: "arrow.down.left.circle.fill")
            }
            .padding(4)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Siêu dữ liệu")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
            
            FlowLayout(spacing: 8) {
                metadataTag(
                    text: selectedCategory?.name ?? "Chọn danh mục",
                    icon: selectedCategory?.icon ?? "square.grid.2x2",
                    color: selectedCategory?.color ?? .orange
                ) {
                    isShowingCategorySelector = true
                }
                metadataTag(
                    text: selectedBudget?.name ?? "Chọn Budget",
                    icon: "wallet.pass.fill", // Assuming Budget doesn't have an icon property directly mapped or we just use default
                    color: .blue
                ) {
                    isShowingBudgetSelector = true
                }
                metadataTag(text: "Hôm nay", icon: "calendar", color: .purple) {
                    isShowingTimePicker = true
                }
            }
        }
    }

    private var amountGlassCard: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            TextField("0", text: $cameraAmount)
                .font(.system(size: 16, weight: .bold))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .fixedSize()
            
            Text("USD")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
    }

    private var chatInputBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                imagePickerSourceType = .photoLibrary
                isShowingImagePicker = true
            }) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.7))
            }
            
            Image(systemName: "mic.fill")
                .font(.system(size: 14))
                .foregroundStyle(.black.opacity(0.8))
            
            TextField("Mô tả giao dịch của bạn...", text: $chatInputText)
                .font(.system(size: 14))
            
            Button(action: {
                if !chatInputText.isEmpty {
                    chatMessages.append(ChatMessage(text: chatInputText, isAI: false, time: "Now"))
                    chatInputText = ""
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String = ""
    var isAI: Bool = false
    var isTransactionCard: Bool = false
    var transactionName: String = ""
    var amount: String = ""
    var time: String = ""
}

struct TransactionCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct CameraView: View {
    var body: some View {
        ZStack {
            Color.black
            
            VStack {
                Spacer()
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.1))
                Spacer()
            }
        }
    }
}
