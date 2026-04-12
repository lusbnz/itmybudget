import SwiftUI

struct MonthPickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Month")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HStack(spacing: 0) {
                        Picker("Month", selection: Binding(
                            get: { Calendar.current.component(.month, from: selectedDate) },
                            set: { newValue in
                                if let newDate = Calendar.current.date(bySetting: .month, value: newValue, of: selectedDate) {
                                    selectedDate = newDate
                                }
                            }
                        )) {
                            ForEach(1...12, id: \.self) { month in
                                Text(Calendar.current.monthSymbols[month-1]).tag(month)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Year", selection: Binding(
                            get: { Calendar.current.component(.year, from: selectedDate) },
                            set: { newValue in
                                if let newDate = Calendar.current.date(bySetting: .year, value: newValue, of: selectedDate) {
                                    selectedDate = newDate
                                }
                            }
                        )) {
                            ForEach(2020...2030, id: \.self) { year in
                                Text(String(format: "%d", year)).tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
                }
                .padding(24)
            }
            
            Button(action: { isPresented = false }) {
                Text("Apply Selection")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(24)
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
}
