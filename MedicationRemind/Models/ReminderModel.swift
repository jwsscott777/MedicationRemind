

import SwiftUI
import Foundation

/// Pill type
enum PillType: String, CaseIterable {
    case blue = "regular_blue"
    case white = "regular_white"
    case orange = "regular_orange"
    case polygon = "polygon_blue"
    case red = "regular_red"
    case other = "other"
}

/// Daily time interval
enum DailyTimeInterval: String, CaseIterable {
    case morning = "Morning"
    case noon = "Noon"
    case evening = "Evening"
}

/// Main model to hold details about a pill reminder
class ReminderModel: ObservableObject, Identifiable {
    var id: String = ""
    var pillName: String
    @Published var pillDosage: Int
    @Published var pillType: PillType = .blue
    var selectedDailyInterval: DailyTimeInterval = .morning
    @Published var didTakePill: Bool = false
    
    /// Daily time intervals
    var morningDate: Date?
    var noonDate: Date?
    var eveningDate: Date?
    
    /// Reset taken indicator if needed
    private var recordDay: Int = 0 {
        didSet {
            if let currentDay = Calendar.current.dateComponents([.day], from: Date()).day, recordDay != currentDay {
                self.didTakePill = false
            }
        }
    }
    
    /// Initializer
    init(id: String, pillName: String, pillDosage: Int, pillType: PillType, selectedDailyInterval: DailyTimeInterval,
         didTakePill: Bool, morningDate: Date?, noonDate: Date?, eveningDate: Date?) {
        self.id = id
        self.pillName = pillName
        self.pillDosage = pillDosage
        self.pillType = pillType
        self.selectedDailyInterval = selectedDailyInterval
        self.didTakePill = didTakePill
        self.morningDate = morningDate
        self.noonDate = noonDate
        self.eveningDate = eveningDate
    }
    
    /// Determine if the model is valid
    var isValid: Bool {
        !pillName.isEmpty && (morningDate != nil || noonDate != nil || eveningDate != nil)
    }
    
    /// Formatted time
    func formattedTime(interval: DailyTimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var date = morningDate
        if interval == .noon {
            date = noonDate
        } else if interval == .evening {
            date = eveningDate
        }
        guard let selectedDate = date else {
            return "NONE"
        }
        return formatter.string(from: selectedDate)
    }
    
    /// Formatted dosage
    var formattedDosage: String {
        "Take \(pillDosage) pill\(pillDosage > 1 ? "s" : "")"
    }
    
    /// Return dictionary from the model
    var dictionary: [String: Any] {
        var data = [String: Any]()
        data["id"] = id
        data["name"] = pillName
        data["dosage"] = pillDosage
        data["type"] = pillType.rawValue
        data["morning"] = morningDate
        data["noon"] = noonDate
        data["evening"] = eveningDate
        data["taken"] = false
        if let day = Calendar.current.dateComponents([.day], from: Date()).day {
            data["recordDay"] = day
        }
        return data
    }
    
    /// Notification schedule date details
    var notificationDate: DateComponents? {
        var components: DateComponents?
        if let morning = morningDate {
            components = Calendar.current.dateComponents([.hour, .minute], from: morning)
        } else if let noon = noonDate {
            components = Calendar.current.dateComponents([.hour, .minute], from: noon)
        } else if let evening = eveningDate {
            components = Calendar.current.dateComponents([.hour, .minute], from: evening)
        }
        return components
    }
    
    /// Custom initializer
    static func build(dictionary: [String: Any]) -> ReminderModel? {
        if let id = dictionary["id"] as? String, let name = dictionary["name"] as? String,
            let dosage = dictionary["dosage"] as? Int, let type = dictionary["type"] as? String, let taken = dictionary["taken"] as? Bool {
            let model = ReminderModel(id: id, pillName: name, pillDosage: dosage, pillType: PillType(rawValue: type) ?? .blue, selectedDailyInterval: .morning, didTakePill: taken, morningDate: dictionary["morning"] as? Date, noonDate: dictionary["noon"] as? Date, eveningDate: dictionary["evening"] as? Date)
            model.recordDay = dictionary["recordDay"] as? Int ?? 0
            return model
        }
        return nil
    }
    
    static func buildDefaultModel() -> ReminderModel {
        return ReminderModel(id: "", pillName: "", pillDosage: 1, pillType: .blue, selectedDailyInterval: .morning, didTakePill: false, morningDate: nil, noonDate: nil, eveningDate: nil)
    }
    
    /// Mark pill as taken
    func markPillTaken() {
        didTakePill = !didTakePill
        var data = [String: Any]()
        if let dictionary = UserDefaults.standard.dictionary(forKey: "reminders") {
            data = dictionary
            if var details = data[id] as? [String: Any] {
                details["taken"] = didTakePill
                if let day = Calendar.current.dateComponents([.day], from: Date()).day {
                    details["recordDay"] = day
                }
                data[id] = details
            }
            UserDefaults.standard.set(data, forKey: "reminders")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Save pill reminder
    func savePillReminder() {
        var data = [String: Any]()
        if let savedData = UserDefaults.standard.dictionary(forKey: "reminders") { data = savedData }
        
        if morningDate != nil {
            var updatedDictionary = dictionary
            updatedDictionary.removeValue(forKey: "noon")
            updatedDictionary.removeValue(forKey: "evening")
            data[UUID().uuidString] = updatedDictionary
        }
        
        if noonDate != nil {
            var updatedDictionary = dictionary
            updatedDictionary.removeValue(forKey: "morning")
            updatedDictionary.removeValue(forKey: "evening")
            data[UUID().uuidString] = updatedDictionary
        }
        
        if eveningDate != nil {
            var updatedDictionary = dictionary
            updatedDictionary.removeValue(forKey: "morning")
            updatedDictionary.removeValue(forKey: "noon")
            data[UUID().uuidString] = updatedDictionary
        }
        
        UserDefaults.standard.set(data, forKey: "reminders")
        UserDefaults.standard.synchronize()
    }
}

struct ReminderModel_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
