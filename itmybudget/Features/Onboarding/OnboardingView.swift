import SwiftUI

struct OnboardingView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @State private var selection: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack {
                TabView(selection: $selection) {
                    OnboardingSlide(
                        title: "Thiết lập cơ bản",
                        description: "Chào mừng! Hãy cùng bắt đầu hành trình quản lý tài chính hiệu quả.",
                        image: "gearshape.fill",
                        tag: 0
                    )
                    
                    OnboardingSlide(
                        title: "Phân loại chi tiêu",
                        description: "Sắp xếp mọi khoản thu chi của bạn theo từng danh mục rõ ràng và khoa học.",
                        image: "list.bullet.rectangle.portrait.fill",
                        tag: 1
                    )
                    
                    OnboardingSlide(
                        title: "Ngân sách đầu tiên",
                        description: "Đặt ngay kế hoạch chi tiêu cho tháng này để đạt mục tiêu tài chính nhanh hơn.",
                        image: "briefcase.fill",
                        tag: 2
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Footer Buttons
                VStack(spacing: 16) {
                    Button {
                        if selection < 2 {
                            withAnimation {
                                selection += 1
                            }
                        } else {
                            appStateManager.moveToMain()
                        }
                    } label: {
                        Text(selection == 2 ? "Bắt đầu ngay" : "Tiếp theo")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    if selection < 2 {
                        Button {
                            appStateManager.moveToMain()
                        } label: {
                            Text("Bỏ qua")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

struct OnboardingSlide: View {
    let title: String
    let description: String
    let image: String
    let tag: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.blue.gradient)
                .padding(.bottom, 16)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 40)
        }
        .tag(tag)
    }
}
