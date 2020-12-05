

import SwiftUI
import Foundation

/// View model to add a pill
class AddPillViewModel: ObservableObject {
    @Published private var addPillModel = ReminderModel.buildDefaultModel()
    
    /// Set when the pill was added to the list
    var addedPill: Bool = false
    
    var pillDosage: Int {
        addPillModel.pillDosage
    }
    
    var pillType: PillType {
        addPillModel.pillType
    }
    
    var alertTitle: String {
        addedPill ? "Great Job" : "Something's missing"
    }
    
    var alertMessage: String {
        addedPill ? "Your pill reminder has been added" : "Make sure you entered the pill name and selected a time"
    }
    
    var dateRange: ClosedRange<Date> {
        var startDateComponents = DateComponents()
        var endDateComponents = DateComponents()
        
        switch addPillModel.selectedDailyInterval {
        case .morning:
            startDateComponents.hour = 0
            endDateComponents.hour = 11
            endDateComponents.minute = 59
        case .noon:
            startDateComponents.hour = 12
            endDateComponents.hour = 16
            endDateComponents.minute = 59
        case .evening:
            startDateComponents.hour = 17
            endDateComponents.hour = 23
            endDateComponents.minute = 59
        }
        
        return Calendar.current.date(from: startDateComponents)!...Calendar.current.date(from: endDateComponents)!
    }
    
    func formattedTime(interval: DailyTimeInterval) -> String {
        addPillModel.formattedTime(interval: interval)
    }
    
    // MARK: - User's actions
    func didEnterPillName(_ name: String) {
        addPillModel.pillName = name
    }
    
    func didSelectDailyInterval(_ interval: DailyTimeInterval) {
        addPillModel.selectedDailyInterval = interval
        didSelectDailyDate(date: nil)
    }
    
    func didSelectDailyDate(date: Date?) {
        if addPillModel.selectedDailyInterval == .morning {
            addPillModel.morningDate = date?.keepTimeOnly
        } else if addPillModel.selectedDailyInterval == .noon {
            addPillModel.noonDate = date?.keepTimeOnly
        } else {
            addPillModel.eveningDate = date?.keepTimeOnly
        }
    }
    
    func updatePillDosage(_ dosage: Int) {
        addPillModel.pillDosage = dosage
    }
    
    func updatePillType(_ type: PillType) {
        addPillModel.pillType = type
    }
    
    func addPillReminder() {
        if addPillModel.isValid {
            addPillModel.savePillReminder()
            addedPill = true
            requestPushNotificationsPermissions()
        } else { addedPill = false }
    }
    
    private func requestPushNotificationsPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if !granted || error != nil {
                /// User declined push notification permissions
            }
        }
    }
}
