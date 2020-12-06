

import SwiftUI

/// Picker type
enum AddPillPickerType {
    case none, interval, dateTime
}

/// Will allow users to add a pill to the reminders list
struct AddPillView: View {
    @State var pillName: String = ""
    @State var scheduleDate: Date = Date()
    @State var scheduleInterval: Int = 0
    @State var pickerType: AddPillPickerType = .none
    @State var addPillSelected: Bool = false

    /// Add Pill view model
    @ObservedObject var viewModel: AddPillViewModel
    @ObservedObject var baseViewModel: PillReminderViewModel
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    /// Add the pill name
                    pillNameSection
                    
                    /// Add pill interval
                    pillIntervalSection
                    
                    /// Pill dosage stepper
                    Section(header: Text("How many do you take?").font(.system(size: 20)).bold().foregroundColor(.white)) {
                        InputStepper(viewModel: viewModel)
                    }
                    
                    /// Pill type icon
                    Section(header: Text("Choose a pill icon").font(.system(size: 20)).bold().foregroundColor(.white)) {
                        PillTypeSelector(viewModel: viewModel)
                    }
                    
                    Spacer()
                    Spacer()
                }
                .applyCustomListStyle()
                .listStyle(GroupedListStyle())
            }
            
            /// Add Pill sticky button
            addPillStickyFooter
            
            /// Interval and time picker
            pickerFooterView
        }
    }
    
    /// Pill name section
    var pillNameSection: some View {
        Section(header: Text("What's the medication?").font(.system(size: 20)).bold().foregroundColor(.white)) {
            ZStack {
//                RoundedShadowView().frame(height: 50).padding(.top, -40)
                TextField("Enter medication name here", text: $pillName.onChange({ (name) in
                    self.viewModel.didEnterPillName(name)
                })).padding(.top, -30).padding(.leading, 15).padding(.trailing, 15).font(.title3)
            }
        }.padding(.top, 40)
    }
    
    /// Pill interval section
    var pillIntervalSection: some View {
        Section(header: Text("How often do you take it?").font(.system(size: 20)).bold().foregroundColor(.white)) {
            VStack {
                /// Time of day interval wit horizontal pickers
                HStack(spacing: 15) {
                    ForEach(0..<DailyTimeInterval.allCases.count, content: { index in
                        DropDownSelector(label: self.viewModel.formattedTime(interval: DailyTimeInterval.allCases[index]),
                                         title: DailyTimeInterval.allCases[index].rawValue, didSelect: {
                                            self.viewModel.didSelectDailyInterval(DailyTimeInterval.allCases[index])
                                            self.pickerType = self.pickerType != .dateTime ? .dateTime : .none
                                            self.generator.notificationOccurred(.success)
                        })
                    })
                }
            }
        }
        
    }
    
    
    /// Add this Pill sticky button
    var addPillStickyFooter: some View {
        ZStack {
            VStack {
                Spacer()
                Color.white.frame(height: 100)
            }
            .edgesIgnoringSafeArea(.bottom)
            VStack {
                Spacer()
                ZStack {
                    Color(#colorLiteral(red: 0.3333333333, green: 0.4196078431, blue: 0.1843137255, alpha: 0.4499204522)).frame(height: 100)
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(#colorLiteral(red: 0.3333333333, green: 0.4196078431, blue: 0.1843137255, alpha: 1)))
                        .frame(height: 50)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                        .alert(isPresented: $addPillSelected, content: { () -> Alert in
                            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK"), action: {
                                if self.viewModel.addedPill { self.baseViewModel.exitAddPillScreen() }
                            }))
                        })
                        .onTapGesture {
                            self.generator.notificationOccurred(.success)
                            self.viewModel.addPillReminder()
                            self.addPillSelected = true
                    }
                    Text("Add this Medication").foregroundColor(.white).bold().offset(x: 0, y: -10)
                }
               
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    /// Pickers footer view
    var pickerFooterView: some View {
        VStack {
            if pickerType != .none {
                Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.217702227))
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture { self.pickerType = .none }
                ZStack {
                    Color(#colorLiteral(red: 0.3350612819, green: 0.4195061922, blue: 0.1846913397, alpha: 1)).layoutPriority(0).frame(width: UIScreen.main.bounds.width).offset(x: 0, y: -10)
                    if pickerType == .dateTime {
                        dailyTimePicker.layoutPriority(1)
                    }
                }
                .offset(x: 0, y: pickerType == .none ? 450 : 0).animation(.spring())
            }
        }
    }
    
    /// Daily time picker
    var dailyTimePicker: some View {
        DatePicker(selection: $scheduleDate.onChange({ (date) in
            self.viewModel.didSelectDailyDate(date: date)
        }), in: viewModel.dateRange, displayedComponents: .hourAndMinute) {
            EmptyView()
        }
        
        .labelsHidden()
        .datePickerStyle(WheelDatePickerStyle())
    }
}

// MARK: - Canvas Preview
struct AddPillView_Previews: PreviewProvider {
    static var previews: some View {
        AddPillView(viewModel: AddPillViewModel(), baseViewModel: PillReminderViewModel())
            .preferredColorScheme(.dark)
    }
}
