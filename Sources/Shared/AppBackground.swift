import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.97, blue: 0.98),
                Color(red: 0.89, green: 0.93, blue: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(Color(red: 0.69, green: 0.81, blue: 0.83).opacity(0.25))
                .frame(width: 420)
                .blur(radius: 35)
                .offset(x: 300, y: -210)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 180)
                .fill(Color.white.opacity(0.22))
                .frame(width: 520, height: 220)
                .rotationEffect(.degrees(-16))
                .offset(x: -320, y: 220)
        )
        .ignoresSafeArea()
    }
}
