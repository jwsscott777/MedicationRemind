import SwiftUI

/// Will show no reminders for scenario when user first time launched the app without any reminders set
struct NoRemindersView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image("Illustration 4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250, alignment: .center)
            Text("No Reminders")
                .font(.largeTitle)
                .foregroundColor(.black)
                .bold()
                
            Text("You don't have any medication added to your list yet")
                .font(.system(size: 25))
                .foregroundColor(.black)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.leading, 35)
                .padding(.trailing, 35)
            Spacer()
            Spacer()
        }
    }
}


// MARK: - Canvas Preview
struct NoRemindersView_Previews: PreviewProvider {
    static var previews: some View {
        NoRemindersView()
            .preferredColorScheme(.dark)
    }
}
