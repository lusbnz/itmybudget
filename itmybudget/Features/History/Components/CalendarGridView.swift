import SwiftUI

struct CalendarGridView: View {
    let selectedDate: Date
    let onDaySelect: ([Transaction], Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(1...31, id: \.self) { day in
                    CalendarCell(
                        day: day,
                        selectedDate: selectedDate,
                        action: onDaySelect
                    )
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .padding(.horizontal, 16)
    }
}
