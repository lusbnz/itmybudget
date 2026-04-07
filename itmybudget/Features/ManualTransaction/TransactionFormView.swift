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
    
    // State for manual input
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var transactionType: TransactionType = .outcome
    @Namespace private var typeNamespace
    
    // Selectors
    @State private var isShowingCategorySelector = false
    @State private var isShowingBudgetSelector = false
    @State private var isShowingLocationMap = false
    @State private var isShowingTimePicker = false
    
    // Recurring States
    @State private var isRecurring: Bool = false
    @State private var frequency: String = "Monthly"
    @State private var isNonFixed: Bool = false
    @State private var startDate: Date = Date()
    @State private var frequencyOptions = ["Weekly", "Monthly", "Yearly"]
    @Namespace private var tagNamespace
    
    let transactionToEdit: Transaction?
    
    init(transactionToEdit: Transaction? = nil) {
        self.transactionToEdit = transactionToEdit
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
        .sheet(isPresented: $isShowingCategorySelector) {
            CategorySelectorSheet { category in
                // Update selected category logic
            }
            .presentationDetents([.fraction(0.85)])
        }
        .sheet(isPresented: $isShowingBudgetSelector) {
            BudgetSelectorSheet { budget in
                // Update selected budget logic
            }
            .presentationDetents([.fraction(0.85)])
        }
        .sheet(isPresented: $isShowingLocationMap) {
            LocationSelectorSheet()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $isShowingTimePicker) {
            TimeSelectorSheet()
                .presentationDetents([.fraction(0.85)])
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Text(transactionToEdit == nil ? "Create New" : "Edit")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    // Drafts logic
                }) {
                    HStack(spacing: 6) {
                        Text(transactionToEdit == nil ? "Add New" : "Edit")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: transactionToEdit == nil ? "plus" : "checkmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .clipShape(Capsule())
                }
                .buttonStyle(BouncyButtonStyle())
                
                Menu {
                    if transactionToEdit == nil {
                        Button(action: { }) {
                            Label("Save as Draft", systemImage: "pencil.and.outline")
                        }
                    } else {
                        Button(role: .destructive, action: { }) {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 15)
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
        .padding(.bottom, 40)
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
        VStack {
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
        VStack(spacing: 24) {
            // Name Input
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
            .padding(.horizontal, 20)
            
            // Amount Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Amount")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                HStack {
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .bold))
                    
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
                
                // Quick selection slugs
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
            .padding(.horizontal, 20)
            
            // Transaction Type Tabs (Capsule Style)
            HStack(spacing: 0) {
                typeTab(type: .outcome, title: "Outcome", icon: "arrow.up.right.circle.fill")
                typeTab(type: .income, title: "Income", icon: "arrow.down.left.circle.fill")
            }
            .padding(4)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            // Interactive Tags (Leading Aligned)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    metadataTag(text: "Food & Drinks", icon: "fork.knife", color: .orange) {
                        isShowingCategorySelector = true
                    }
                    metadataTag(text: "Main Budget", icon: "wallet.pass.fill", color: .blue) {
                        isShowingBudgetSelector = true
                    }
                }
                
                HStack(spacing: 12) {
                    metadataTag(text: "Today, 10:30 AM", icon: "calendar", color: .purple) {
                        isShowingTimePicker = true
                    }
                    metadataTag(text: "Add Location", icon: "location.fill", color: .red) {
                        isShowingLocationMap = true
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            recurringSection
        }
    }
    
    private var recurringSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recurring Transaction")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                Spacer()
                
                Toggle("", isOn: $isRecurring.animation(.spring()))
                    .labelsHidden()
            }
            .padding(.bottom, isRecurring ? 8 : 0)
            
            if isRecurring {
                VStack(spacing: 20) {
                    Divider()
                        .background(Color.black.opacity(0.05))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Frequency")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.gray)
                        
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
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Variable Amount")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.black)
                            Text("Hide amount until due date")
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isNonFixed)
                            .labelsHidden()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Date")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.black)
                            Text("When to begin this cycle")
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .scaleEffect(0.9)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func metadataTag(text: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
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
        VStack(spacing: 20) {
            TransactionCard {
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.opacity(0.5))
                    
                    Text("Scan Receipt")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Point your camera at a receipt to automatically extract transaction details.")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button(action: {}) {
                        Text("Open Camera")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var chatEntryView: some View {
        VStack(spacing: 20) {
            TransactionCard {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange.opacity(0.5))
                    
                    Text("AI Assistant")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Simply describe your transaction, for example:\n\"Spent $10 on coffee at Starbucks this morning\"")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    TextField("Tell me about your spending...", text: .constant(""))
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        )
                }
                .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 20)
    }
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
