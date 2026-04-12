import SwiftUI

struct FeatureSuggestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var suggestion: String = ""
    @State private var email: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Suggest a Feature")
                            .font(.system(size: 24, weight: .bold))
                        Text("Your feedback helps us make itmybudget better.")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What would you like to see?")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        TextEditor(text: $suggestion)
                            .padding(16)
                            .frame(height: 180)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                            .font(.system(size: 15))
                            .overlay(alignment: .topLeading) {
                                if suggestion.isEmpty {
                                    Text("Describe your idea here...")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.gray.opacity(0.4))
                                        .padding(.leading, 20)
                                        .padding(.top, 24)
                                }
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Email (Optional)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        TextField("yourname@example.com", text: $email)
                            .font(.system(size: 16, weight: .medium))
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(24)
            }
            
            Spacer()
            
            submitButton
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
    
    private var submitButton: some View {
        Button(action: {
            if !suggestion.isEmpty {
                isSubmitting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isSubmitting = false
                    dismiss()
                }
            }
        }) {
            HStack {
                if isSubmitting {
                    ProgressView().tint(.white)
                        .padding(.trailing, 8)
                }
                Text(isSubmitting ? "Submitting..." : "Send Feedback")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(suggestion.isEmpty ? Color.gray.opacity(0.4) : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .disabled(suggestion.isEmpty || isSubmitting)
        .buttonStyle(BouncyButtonStyle())
        .padding(24)
        .padding(.bottom, 10)
    }
}
