import SwiftUI

struct NotificationSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var locationEnabled = true
    @State private var reminderTime = Date()
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        LText("notification_settings.channel_settings")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.gray)
                        
                        VStack(spacing: 0) {
                            toggleRow(title: "notification_settings.push_notifications", icon: "bell.fill", color: .orange, isOn: $pushEnabled)
                            Divider().opacity(0.3).padding(.horizontal, 16)
                            toggleRow(title: "notification_settings.email_reports", icon: "envelope.fill", color: .blue, isOn: $emailEnabled)
                            Divider().opacity(0.3).padding(.horizontal, 16)
                            toggleRow(title: "notification_settings.location_reminders", icon: "location.fill", color: .green, isOn: $locationEnabled)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        LText("notification_settings.daily_reminder")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.gray)
                        
                        HStack {
                            Label("notification_settings.remind_me_at".localized, systemImage: "clock.fill")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
                    }
                }
                .padding(20)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                LText("notification_settings.save_settings")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
    
    private var header: some View {
        HStack {
            LText("notification_settings.title")
                .font(.system(size: 22, weight: .bold))
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
    
    private func toggleRow(title: String, icon: String, color: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.1))
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
            }
            .frame(width: 32, height: 32)
            
            LText(title)
                .font(.system(size: 14, weight: .medium))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
