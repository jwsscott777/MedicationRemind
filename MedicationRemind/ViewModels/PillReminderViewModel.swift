

import SwiftUI
import UserNotifications
import Foundation

/// Main view model to bind the view to the model and holds the business logic of the app
class PillReminderViewModel: ObservableObject {
   
    
    @Published private var navigationModel = NavigationModel(title: NSLocalizedString("Today", comment: ""), subtitle: "No medication saved", style: .reminders)
    @Published private var addPillViewModel = AddPillViewModel()
    
    /// Change the content for navigation view when user taps "+" or "x" button on the top right corner
    private func changeNavigationModelContent() {
        let style = navigationModel.style
        navigationModel.title = style == .addPillReminder ? NSLocalizedString("Add Medication", comment: "") : NSLocalizedString("Today", comment: "")
        navigationModel.subtitle = style == .addPillReminder ? NSLocalizedString("Just a few taps below", comment: "") : progressSubtitle
    }
    
    /// Navigation content
    var navigationTitle: String {
        navigationModel.title
        
    }
   
    
    var navigationSubtitle: String {
        navigationModel.subtitle
    }
    
    var navigationStyle: NavigationViewStyle {
        navigationModel.style
    }
   
    /// Reminders details
    var reminders = [ReminderModel]()

    var hasReminders: Bool {
        reminders.count > 0
    }
    
    var progressSubtitle: String {
        hasReminders ? NSLocalizedString("It's time for your meds", comment: "") : NSLocalizedString("No medication saved", comment: "")
    }
    
    func reminders(forInterval interval: DailyTimeInterval) -> [ReminderModel] {
        let models = reminders
            .filter({ interval == .morning ? $0.morningDate != nil : interval == .noon ? $0.noonDate != nil : $0.eveningDate != nil })
        switch interval {
        case .morning:
            if models.count > 0 {
                return models.count > 1 ? models.sorted(by: { $0.morningDate! < $1.morningDate! }) : models
            }
        case .noon:
            if models.count > 0 {
                return models.count > 1 ? models.sorted(by: { $0.noonDate! < $1.noonDate! }) : models
            }
        case .evening:
            if models.count > 0 {
                return models.count > 1 ? models.sorted(by: { $0.eveningDate! < $1.eveningDate! }) : models
            }
        }
        return models
    }
    
    /// Add pill view model
    var pillViewModel: AddPillViewModel {
        addPillViewModel
    }
    
   
    // MARK: - User's actions
    func getUpdatedRemindersList() {
        if navigationStyle == .reminders {
            if let storedData = UserDefaults.standard.dictionary(forKey: "reminders") {
                storedData.forEach { (pillId, pillDetails) in
                    if var details = pillDetails as? [String: Any] {
                        details["id"] = pillId
                        if let model = ReminderModel.build(dictionary: details), !self.reminders.contains(where: { $0.id == pillId }) {
                            self.reminders.append(model)
                        }
                    }
                }
            }
            setupRemindersNotifications()
            changeNavigationModelContent()
        }
    }
    
    func addPill() {
        navigationModel.style = .addPillReminder
        addPillViewModel = AddPillViewModel()
        changeNavigationModelContent()
    }
    
    func exitAddPillScreen() {
        navigationModel.style = .reminders
        getUpdatedRemindersList()
    }
   
    func pillReminderSelected(id: String) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].markPillTaken()
        getUpdatedRemindersList()
    }
    
    func deleteReminder(id: String) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders.remove(at: index)
        deleteRemindersIfNeeded()
    }
    
    
    // MARK: - Reminders updates
    private func deleteRemindersIfNeeded() {
        if var storedData = UserDefaults.standard.dictionary(forKey: "reminders") {
            storedData.forEach { (pillId, pillDetails) in
                if !self.reminders.compactMap({ $0.id }).contains(pillId) {
                    storedData.removeValue(forKey: pillId)
                }
            }
            UserDefaults.standard.set(storedData, forKey: "reminders")
            UserDefaults.standard.synchronize()
            getUpdatedRemindersList()
            removeNotificationsIfNeeded()
        }
    }
    
    private func setupRemindersNotifications() {
        reminders.forEach { (reminder) in
            if let notificationComponents = reminder.notificationDate, !UserDefaults.standard.bool(forKey: reminder.id) {
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("It's time to take your \(reminder.pillName)", comment: "")
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: notificationComponents, repeats: true)
                let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let errorMessage = error?.localizedDescription {
                        print("NOTIFICATION ERROR: \(errorMessage)")
                    } else {
                        UserDefaults.standard.set(true, forKey: reminder.id)
                        UserDefaults.standard.synchronize()
                    }
                }
            }
        }
    }
    
    private func removeNotificationsIfNeeded() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            request.forEach { (request) in
                if !self.reminders.compactMap({ $0.id }).contains(request.identifier) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    print("REMOVED NOTIFICATION")
                }
                if let components = request.trigger as? UNCalendarNotificationTrigger {
                    print("TITLE: \(request.content.title)\nDATE: \(components.dateComponents)\n")
                }
            }
        }
    }
}
