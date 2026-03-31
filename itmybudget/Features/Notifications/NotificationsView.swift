import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            tabSelection
            
            if viewModel.filteredNotifications.isEmpty {
                emptyState
            } else {
                notificationsList
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
    
    private var header: some View {
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
            
            Text("Notifications")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Menu {
                Button(action: {
                    viewModel.markAllAsRead()
                }) {
                    Label("Mark all as read", systemImage: "checkmark.circle")
                }
                
                Button(role: .destructive, action: {
                    viewModel.deleteAll()
                }) {
                    Label("Delete all", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
    
    private var tabSelection: some View {
        HStack(spacing: 8) {
            ForEach(NotificationsViewModel.NotificationTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.selectedTab = tab
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: viewModel.selectedTab == tab ? .semibold : .medium))
                        
                        if tab == .unread && viewModel.unreadCount > 0 {
                            Text("\(viewModel.unreadCount)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(viewModel.selectedTab == tab ? .black : .white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedTab == tab ? .white : .orange)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            if viewModel.selectedTab == tab {
                                Capsule()
                                    .fill(.black)
                                    .matchedGeometryEffect(id: "tab", in: tabNamespace)
                            } else {
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                    )
                            }
                        }
                    )
                    .foregroundStyle(viewModel.selectedTab == tab ? .white : .gray)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    @Namespace private var tabNamespace
    
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.groupedNotifications, id: \.0) { dateStr, items in
                    Section(header: sectionHeader(dateStr)) {
                        VStack(spacing: 8) {
                            ForEach(items) { notification in
                                NotificationItem(notification: notification) {
                                    viewModel.toggleReadState(for: notification)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                    
                    Text("All caught up!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.6))
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            Spacer()
        }
        .background(Color.clear)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.gray.opacity(0.4))
            }
            
            VStack(spacing: 8) {
                Text("Empty")
                    .font(.system(size: 18, weight: .semibold))
                
                Text(viewModel.selectedTab == .all ? "You have no notifications yet" : "You've read all your notifications")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

struct NotificationItem: View {
    let notification: AppNotification
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(notification.isRead ? Color.gray.opacity(0.08) : Color.orange.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: notification.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(notification.isRead ? .gray.opacity(0.8) : .orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(notification.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(notification.isRead ? .gray : .black)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(.orange)
                                .frame(width: 7, height: 7)
                                .padding(.top, 6)
                        }
                    }
                    
                    Text(notification.description)
                        .font(.system(size: 13))
                        .foregroundStyle(.gray.opacity(0.9))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatTime(notification.date))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.7))
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(notification.isRead ? Color.black.opacity(0.03) : Color.orange.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
