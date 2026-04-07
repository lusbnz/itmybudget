import SwiftUI
import MapKit

struct CategorySelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSelect: (Category) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Category")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .padding(24)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(Category.sampleData) { category in
                        Button(action: {
                            onSelect(category)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(category.color.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(category.color)
                                }
                                
                                Text(category.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                                    .lineLimit(1)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 3)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(red: 1.0, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
}

struct BudgetSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSelect: (Budget) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Budget")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .padding(24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Budget.sampleData) { budget in
                        BudgetItemView(budget: budget, showDetails: true, onTap: {
                            onSelect(budget)
                            dismiss()
                        })
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(red: 1.0, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
}

struct LocationSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ZStack(alignment: .top) {
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .realistic))
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(16)
                .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.gray)
                        
                        TextField("Search for a place...", text: $searchText)
                            .font(.system(size: 14))
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                }
            }
            
            Button(action: { dismiss() }) {
                Text("Confirm Location")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .padding(24)
        }
        .background(Color(red: 1.0, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Select Location")
                    .font(.system(size: 20, weight: .bold))
                Text("Where did this transaction happen?")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(24)
    }
}

struct TimeSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    DatePicker("", selection: $selectedDate)
                        .datePickerStyle(.graphical)
                        .accentColor(.black)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        )
                    
                    Button(action: { dismiss() }) {
                        Text("Confirm Date & Time")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                }
                .padding(24)
            }
        }
        .background(Color(red: 1.0, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Date & Time")
                    .font(.system(size: 20, weight: .bold))
                Text("When was this purchase made?")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(24)
    }
}
