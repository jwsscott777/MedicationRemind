


import SwiftUI

/// Will show a list of reminders
struct RemindersListView: View {
    @ObservedObject var viewModel: PillReminderViewModel
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        List {
            Spacer(minLength: 1)
            ForEach(0..<DailyTimeInterval.allCases.count) { index in
                if self.viewModel.reminders(forInterval: DailyTimeInterval.allCases[index]).count > 0 {
                    Section(header: Text(DailyTimeInterval.allCases[index].rawValue).font(.system(size: 20)).bold().padding(.bottom, -10)) {
                        ForEach(self.viewModel.reminders(forInterval: DailyTimeInterval.allCases[index])) { reminder in
                            ReminderView(reminderModel: reminder, reminderDailyInterval: DailyTimeInterval.allCases[index])
                                .onTapGesture {
                                    self.generator.notificationOccurred(.success)
                                    self.viewModel.pillReminderSelected(id: reminder.id)
                            }
                            .onLongPressGesture {
                                self.generator.notificationOccurred(.error)
                                self.viewModel.deleteReminder(id: reminder.id)
                            }
                        }
                    }
                }
            }
        }
        .applyCustomListStyle()
        .environment(\.defaultMinListRowHeight, 110)
        .listStyle(GroupedListStyle())
        .padding(.top, -145)
    }
}

// MARK: - Canvas Preview
struct RemindersListView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersListView(viewModel: PillReminderViewModel())
    }
}
