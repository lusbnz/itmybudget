import SwiftUI

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = "Quoc Viet"
    @State private var email: String = "quocviet@itmybudget.app"
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    avatarSection
                    
                    VStack(spacing: 20) {
                        inputField(title: "Full Name", text: $name, placeholder: "Your Name", icon: "person")
                        inputField(title: "Email Address", text: $email, placeholder: "yourname@example.com", icon: "envelope")
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(24)
            }
            
            Spacer()
            
            saveButton
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
    
    private var header: some View {
        HStack(alignment: .center) {
            Text("Edit Profile")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
    
    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://i.pravatar.cc/300")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3).shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5))
                
                Button(action: { /* Change photo logic */ }) {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 28, height: 28)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }
                }
                .offset(x: 2, y: 2)
            }
            
            Text("Change Photo")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black.opacity(0.6))
        }
    }
    
    private func inputField(title: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray.opacity(0.6))
                    .frame(width: 24)
                
                TextField(placeholder, text: text)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            // Save logic
            dismiss()
        }) {
            Text("Save Changes")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(BouncyButtonStyle())
        .padding(24)
        .padding(.bottom, 10)
    }
}

#Preview {
    EditProfileSheet()
}
