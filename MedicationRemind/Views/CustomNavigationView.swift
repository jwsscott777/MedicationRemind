
//

import SwiftUI

/// Navigation View Style
enum NavigationViewStyle {
    case reminders, addPillReminder
}

/// Custom navigation view with bottom rounded corners
struct CustomNavigationView: View {
    // Bottom corner radius
    private let cornerRadius: CGFloat = 30
    
    // Navigation view colors
    private let blueColor: Color = Color(#colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0, alpha: 1))
    private let orangeColor: Color = Color(#colorLiteral(red: 0.3960784314, green: 0.4039215686, blue: 0, alpha: 1))
    
    // Navigation view model
    @ObservedObject var viewModel: PillReminderViewModel

    var body: some View {
        let style = viewModel.navigationStyle
        let title = viewModel.navigationTitle
        let subtitle = viewModel.navigationSubtitle
        
        return ZStack(alignment: .leading) {
            /// Navigation shape with bottom rounded corners
            RoundedCorner(radius: cornerRadius,
                          corners: [.bottomLeft, .bottomRight])
                .foregroundColor(style == .reminders ? blueColor : orangeColor)
                .edgesIgnoringSafeArea(.top)
                .animation(.easeIn)
            HStack {
                VStack(alignment: .leading) {
                    /// Navigation title is mandatory
                    Text(title)
                        .font(Font.custom("Helvetica", size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    /// Navigation subtitle is optional
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(Font.custom("Helvetica", size: 25))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                PlusCloseButton(viewModel: viewModel).padding(.trailing, 25)
            }
            .padding(.top, 20)
            .padding(.leading, 22)
            .padding(.bottom, 30)
        }
        .frame(height: 120)
    }
}


// MARK: - Canvas Preview
struct CustomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationView(viewModel: PillReminderViewModel())
    }
}
