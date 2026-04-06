import SwiftUI

struct MonthNavigator: View {
    @Binding var selectedDate: Date
    let onShowPicker: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
                    withAnimation {
                        selectedDate = newDate
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .buttonStyle(BouncyButtonStyle())
            
            Spacer()
            
            Button(action: onShowPicker) {
                Text(monthYearString(from: selectedDate))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .buttonStyle(BouncyButtonStyle())
            
            Spacer()
            
            Button(action: {
                if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
                    withAnimation {
                        selectedDate = newDate
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
