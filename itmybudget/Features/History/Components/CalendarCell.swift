import SwiftUI

struct CalendarCell: View {
    let day: Int
    let selectedDate: Date
    let action: ([Transaction], Date) -> Void
    
    private var fullDate: Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
    
    private var dayTransactions: [Transaction] {
        Transaction.sampleData.filter {
            Calendar.current.isDate($0.date, inSameDayAs: fullDate)
        }
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(fullDate)
    }
    
    var body: some View {
        Button(action: {
            if !dayTransactions.isEmpty {
                action(dayTransactions, fullDate)
            }
        }) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(isToday ? Color.black : Color.black.opacity(0.035))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Group {
                                if let first = dayTransactions.first {
                                    if !first.images.isEmpty {
                                        AsyncImage(url: URL(string: "https://picsum.photos/100/100?random=\(first.id.uuidString.prefix(8))")) { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Color.orange.opacity(0.12)
                                                .overlay(
                                                    Image(systemName: "photo.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.orange)
                                                )
                                        }
                                        .frame(width: 42, height: 42)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        Circle()
                                            .fill(isToday ? Color.black : (first.type == .income ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)))
                                            .frame(width: 42, height: 42)
                                            .overlay(
                                                Image(systemName: first.icon)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(isToday ? .white : (first.type == .income ? .green : .blue))
                                            )
                                    }
                                } else {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14))
                                        .foregroundColor(isToday ? .white : .gray.opacity(0.3))
                                }
                            }
                        )
                    
                    if dayTransactions.count > 1 {
                        Text("+\(dayTransactions.count - 1)")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                            .offset(x: 4, y: -4)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                
                Text("\(day)")
                    .font(.system(size: 11, weight: isToday ? .bold : .medium))
                    .foregroundColor(isToday ? .black : .black.opacity(0.6))
            }
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(dayTransactions.isEmpty)
    }
}
