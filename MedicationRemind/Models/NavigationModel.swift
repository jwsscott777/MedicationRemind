
import SwiftUI
import Foundation

/// Main model to configure the navigation view
struct NavigationModel {
    let localizedString = NSLocalizedString("LOCALIZED-STRING-KEY", comment: "Describe what is being localized here")
   
    var title: String
   
    var subtitle: String
    var style: NavigationViewStyle
}
extension String {
    func localized() -> String {
        let path = Bundle.main.path(forResource: "en.lproj", ofType: "es-419.lproj")!
        if let bundle = Bundle(path: path) {
            let str = bundle.localizedString(forKey: self, value: nil, table: nil)
            return str
        }
        return ""
    }
}
