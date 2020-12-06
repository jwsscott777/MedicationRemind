import SwiftUI

/// Custom views struct to encapsulate most of the custom views used by the application
struct CustomView: View {
    var body: some View {
        VStack {
            RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                .frame(height: 120)
                .foregroundColor(.secondary)
                .edgesIgnoringSafeArea(.top)
            ReminderView(reminderModel: ReminderModel.buildDefaultModel())
            RoundedShadowView()
                .frame(height: 50)
            DropDownSelector(label: "Is the time correct?")
            HStack {
                DropDownSelector(label: "8:00 AM", title: "Morning")
                DropDownSelector(label: "12:00 PM", title: "Noon")
                DropDownSelector(label: "8:00 AM", title: "Evening")
            }
            InputStepper(viewModel: AddPillViewModel())
            PillTypeSelector(viewModel: AddPillViewModel())
            Spacer()
        }
    }
}

/// Rounded corner shape by providing which corners to be rounded
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

/// Plus/Close button
struct PlusCloseButton: View {
    @ObservedObject var viewModel: PillReminderViewModel
    private let buttonSize: CGFloat = 35
    private let buttonWeight: CGFloat = 7
    
    let generator = UINotificationFeedbackGenerator()
 
    
    var body: some View {
        let navigationStyle = viewModel.navigationStyle
        let rotationAngle = Angle(degrees: navigationStyle == .reminders ? 0 : 45)
        
        return ZStack {
            RoundedRectangle(cornerRadius: buttonWeight/2).frame(width: buttonSize, height: buttonWeight)
            RoundedRectangle(cornerRadius: buttonWeight/2).frame(width: buttonWeight, height: buttonSize)
        }
        .rotationEffect(rotationAngle).animation(.default)
        .onTapGesture {
            self.generator.notificationOccurred(.success)
            if navigationStyle == .reminders {
                self.viewModel.addPill()
            } else {
                self.viewModel.exitAddPillScreen()
            }
        }
        .foregroundColor(.white)
    }
}

/// Triangle shape used for drop down items in 'add a pill' screen
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

/// Drop down selection for 'add a pill' screen
struct DropDownSelector: View {
    var label: String
    var title: String?
    var didSelect: (() -> Void)?
    
    var body: some View {
        VStack {
            if title != nil {
                Text(title!)
                    .foregroundColor(.secondary)
                    .padding(.bottom, -8)
            }
            ZStack {
                RoundedShadowView()
                HStack {
                    Text(label)
                        .padding(.leading, 8)
                        .font(Font.custom("Helvetica", size: 16))
                        .minimumScaleFactor(0.3)
                       
                    Triangle()
                        .rotationEffect(Angle(degrees: 180))
                        .frame(width: 15, height: 12)
                }
            }
            .frame(height: 50)
            .onTapGesture {
                self.didSelect?()
                
            }
        }
    }
}

/// Input Stepper to in/decrease dosage
struct InputStepper: View {
    private let stepperButtonSize: CGFloat = 25
    @ObservedObject var viewModel: AddPillViewModel
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedShadowView()
            HStack(spacing: 45) {
                stepperButton(increase: false)
                Text("\(viewModel.pillDosage)")
                stepperButton(increase: true)
            }
        }
        .frame(height: 50)
    }
    
    func stepperButton(increase: Bool) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color(#colorLiteral(red: 0.3960784314, green: 0.6980392157, blue: 0, alpha: 1)))
                .frame(width: stepperButtonSize, height: stepperButtonSize)
            Text(increase ? "+" : "-")
                .font(Font.custom("Helvetica", size: 25)).bold()
                .foregroundColor(.white)
                .offset(x: 0.5, y: -1.5)
        }
        .opacity(!increase && self.viewModel.pillDosage == 1 ? 0.5 : 1.0)
        .onTapGesture {
            self.generator.notificationOccurred(.success)
            self.viewModel.objectWillChange.send()
            if !increase && self.viewModel.pillDosage == 1 { return }
            let dosage = increase ? self.viewModel.pillDosage + 1 : self.viewModel.pillDosage - 1
            self.viewModel.updatePillDosage(dosage)
        }
    }
}

/// Pill type selector
struct PillTypeSelector: View {
    @ObservedObject var viewModel: AddPillViewModel
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedShadowView()
            HStack {
                Spacer()
                ForEach(0..<PillType.allCases.count) { index in
                    Image(PillType.allCases[index].rawValue)
                        .opacity(self.viewModel.pillType == PillType.allCases[index] ? 1.0 : 0.4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            self.generator.notificationOccurred(.success)
                            self.viewModel.objectWillChange.send()
                            self.viewModel.updatePillType(PillType.allCases[index])
                    }
                }
                Spacer()
            }
        }
        .frame(height: 50)
    }
}

/// Rounded Shadow View
struct RoundedShadowView: View {
    var customOpacity: Double = 0.5
    var body: some View {
        /// Background view with shadow
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.white)
            .shadow(radius: 5)
            .opacity(customOpacity)
    }
}

/// Reminder view
struct ReminderView: View {
    @ObservedObject var reminderModel: ReminderModel
    var reminderDailyInterval: DailyTimeInterval = .morning
    
    var body: some View {
        ZStack {
            RoundedShadowView(customOpacity: reminderModel.didTakePill ? 0.35 : 0.5)
            /// Pill name, Details and Time
            HStack {
                Image(reminderModel.pillType.rawValue)
                    .frame(width: 45)
                    .aspectRatio(contentMode: .fit)
                VStack(alignment: .leading) {
                    Text(reminderModel.pillName)
                        .font(Font.custom("Helvetica", size: 20))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    Text(reminderModel.formattedDosage)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(reminderModel.formattedTime(interval: reminderDailyInterval))
                    .padding(.bottom, 40)
                    .foregroundColor(.black)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .opacity(reminderModel.didTakePill ? 0.35 : 1.0)
        }
        .foregroundColor(.clear)
        .frame(height: 90)
    }
}

/// Helps hiding the line separator for a list as well as clear color for header view
struct CustomListViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.onAppear {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = .black
            UITableView.appearance().allowsSelection = false
            UITableViewCell.appearance().selectionStyle = .none
            UITableViewCell.appearance().backgroundColor = .black
            UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
        }
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func applyCustomListStyle() -> some View {
        modifier(CustomListViewModifier())
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

extension Date {
    var keepTimeOnly: Date {
        var components = DateComponents()
        components.hour = Calendar.current.component(.hour, from: self)
        components.minute = Calendar.current.component(.minute, from: self)
        return Calendar.current.date(from: components)!
    }
}

// MARK: - Canvas Preview
struct CustomViews_Previews: PreviewProvider {
    static var previews: some View {
        CustomView()
            .preferredColorScheme(.dark)
    }
}
