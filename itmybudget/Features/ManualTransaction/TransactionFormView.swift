import SwiftUI
import MapKit

enum TransactionEntryMode: String, CaseIterable, Identifiable {
    case manual = "Manual"
    case camera = "Camera"
    case chat = "Chat"
    
    var id: String { self.rawValue }
    
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
    @State private var frequencyOptions = ["Weekly", "Monthly", "Yearly"]
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
    @State private var inputImage: UIImage? = nil
    
    @State private var chatMessages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your financial assistant. How can I help you today?", isAI: true, time: "9:41 AM"),
        ChatMessage(text: "I spent 45k on eating Pho", isAI: false, time: "9:42 AM"),
        ChatMessage(isTransactionCard: true, transactionName: "Ăn phở", amount: "45.000", time: "9:42 AM")
    ]
    @State private var chatInputText: String = ""
    
    let transactionToEdit: Transaction?
    
    init(transactionToEdit: Transaction? = nil, startWithRecurring: Bool = false, initialMode: TransactionEntryMode = .manual) {
        self.transactionToEdit = transactionToEdit
        _isRecurring = State(initialValue: startWithRecurring)
        _selectedLocationName = State(initialValue: transactionToEdit?.location ?? "Add Location")
        _selectedMode = State(initialValue: initialMode)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 1.0, green: 0.98, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    contentView
                        .padding(.top, 10)
                }
                
                Spacer(minLength: 100)
            }
            
            modeSelectorTabs
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .sheet(isPresented: $isShowingCategorySelector) {
            CategorySelectorSheet { category in
            }
        }
        .sheet(isPresented: $isShowingBudgetSelector) {
            BudgetSelectorSheet { budget in
            }
        }
        .sheet(isPresented: $isShowingLocationMap) {
            LocationSelectorSheet()
        }
        .sheet(isPresented: $isShowingTimePicker) {
            TimeSelectorSheet()
        }
        .fullScreenCover(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $inputImage, sourceType: .camera)
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
            
            Text(transactionToEdit == nil ? "New Transaction" : "Edit Transaction")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            if selectedMode == .manual {
                saveButton
                
                Menu {
                    if transactionToEdit == nil {
                        Button(action: {}) {
                            Label("Save draft", systemImage: "square.and.pencil")
                        }
                    } else {
                        Button(role: .destructive, action: { 
                            dismiss() 
                        }) {
                            Label("Delete", systemImage: "trash")
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
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
    
    private var saveButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Save")
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .foregroundStyle(.white)
        }
        .buttonStyle(BouncyButtonStyle())
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
            // Transaction Name
            VStack(alignment: .leading, spacing: 10) {
                Text("Transaction Name")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                TextField("e.g., Starbucks Coffee", text: $name)
                    .font(.system(size: 16, weight: .medium))
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 16)
            
            // Amount Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Amount")
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
                            Text("$\(formatCurrency(val))")
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
            
            // Type Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Type")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                
                HStack(spacing: 0) {
                    typeTab(type: .outcome, title: "Outcome", icon: "arrow.up.right.circle.fill")
                    typeTab(type: .income, title: "Income", icon: "arrow.down.left.circle.fill")
                }
                .padding(4)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Metadata")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                
                FlowLayout(spacing: 8) {
                    metadataTag(text: "Food & Drinks", icon: "fork.knife", color: .orange) {
                        isShowingCategorySelector = true
                    }
                    metadataTag(text: "Main Budget", icon: "wallet.pass.fill", color: .blue) {
                        isShowingBudgetSelector = true
                    }
                    metadataTag(text: "Today, 10:30 AM", icon: "calendar", color: .purple) {
                        isShowingTimePicker = true
                    }
                }
            }
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
                
                Text("Recurring Transaction")
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
                        Text("Frequency")
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
                                Text("Variable Amount")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("Hide amount until due date")
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
                                Text("Start Date")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("When to begin this cycle")
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
        SectionContainer(title: "Location") {
            Button(action: { isShowingLocationMap = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedLocationName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                        Text(selectedLocationName == "Add Location" ? "Where did this happen?" : "Tap to change location")
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
        SectionContainer(title: "Photos") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { isShowingImagePicker = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.viewfinder")
                                .font(.system(size: 24))
                            Text("Add Photo")
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
            
            if isCaptured {
                cameraActionButtons
            }
        }
    }
    
    private var cameraActionButtons: some View {
        VStack(spacing: 12) {
            Divider().background(Color.black.opacity(0.05))
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) { isCaptured = false }
                }) {
                    Text("Retry")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1))
                }
                .buttonStyle(BouncyButtonStyle())
                
                Button(action: { dismiss() }) {
                    Text("Confirm and Create")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
            .background(Color.white)
        }
        .transition(.move(edge: .bottom))
    }
    
    private var cameraScannerView: some View {
        VStack(spacing: 24) {
            ZStack {
                CameraView()
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .frame(height: 380)
                
                cornerDecorators
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            VStack(spacing: 16) {
                Text("Scan Receipt or Invoice")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Align your receipt within the frame to automatically detect transaction details.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Capture Button
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
            .padding(.bottom, 120) // Extra padding to keep it above tab area
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
                // Photo and Amount Section
                ZStack(alignment: .bottom) {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 380)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    } else {
                        Image("receipt_placeholder") // Using placeholder if image nil
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 380)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                    
                    // Amount Card inside ZStack, floating above bottom
                    amountGlassCard
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transaction Name")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            
                        TextField("Enter name...", text: $cameraName)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                            .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Type")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                        
                        HStack(spacing: 0) {
                            typeTab(type: .outcome, title: "Outcome", icon: "arrow.up.right.circle.fill")
                            typeTab(type: .income, title: "Income", icon: "arrow.down.left.circle.fill")
                        }
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Metadata")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            
                        FlowLayout(spacing: 8) {
                            metadataTag(text: "Food & Drinks", icon: "fork.knife", color: .orange) {
                                isShowingCategorySelector = true
                            }
                            metadataTag(text: "Main Budget", icon: "wallet.pass.fill", color: .blue) {
                                isShowingBudgetSelector = true
                            }
                            metadataTag(text: "Today, 10:30 AM", icon: "calendar", color: .purple) {
                                isShowingTimePicker = true
                            }
                        }
                    }
                    
                    locationSelectionSection
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 160) // Extra space for sticky bottom buttons
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
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Date Separator
                    Text("Today")
                        .font(.system(size: 12, weight: .bold))
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
                    
                    Spacer(minLength: 120) // Space for input bar
                }
                .padding(.top, 20)
            }
            
            chatInputBar
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
                    .background(message.isAI ? Color.white : Color.black)
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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hệ thống vừa ghi nhận giao dịch **\(message.transactionName)** hết **\(message.amount)đ**. Bạn có muốn ghi chú thêm gì không?")
                    .font(.system(size: 15))
                    .foregroundStyle(.black)
                
                Text(message.time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.gray.opacity(0.6))
            }
            .padding(.horizontal, 16)
            
            TransactionCard {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.transactionName)
                                .font(.system(size: 16, weight: .bold))
                            Text("Outcome")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(message.amount)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                        Text("VND")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                    
                    HStack {
                        miniTag(text: "Food & Drinks", icon: "fork.knife")
                        miniTag(text: "Main Budget", icon: "wallet.pass.fill")
                        Spacer()
                    }
                    
                    Divider()
                        .background(Color.black.opacity(0.05))
                    
                    HStack(spacing: 8) {
                        actionMiniButton(title: "Edit", icon: "pencil", color: .blue) {
                            withAnimation { selectedMode = .manual }
                        }
                        
                        actionMiniButton(title: "Draft", icon: "square.and.pencil", color: .orange)
                        
                        actionMiniButton(title: "Confirm", icon: "checkmark.circle.fill", color: .green) {
                            dismiss()
                        }
                    }
                }
            }
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
    
    private var amountGlassCard: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                TextField("0", text: $cameraAmount)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .frame(minWidth: 100)
                
                Text("USD")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
    }

    private var chatInputBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.black.opacity(0.05))
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                
                HStack {
                    TextField("Tell me about your spending...", text: $chatInputText)
                        .font(.system(size: 15))
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 1))
                
                Button(action: {
                    if !chatInputText.isEmpty {
                        chatMessages.append(ChatMessage(text: chatInputText, isAI: false, time: "Now"))
                        chatInputText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
            .background(Color(red: 1.0, green: 0.98, blue: 0.96))
        }
    }
}

// Model for Chat
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
