import SwiftUI

struct PlanningView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Budget Planning")
                    .font(.title3)
                    .foregroundStyle(.gray)
                
                Image(systemName: "calendar.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue.opacity(0.3))
                    .padding()
            }
            .navigationTitle("Planning")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
        }
        .background(.clear)
    }
}
