import SwiftUI

extension Sound {
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "caf") ?? Bundle.main.url(forResource: rawValue, withExtension: "wav")
    }
}
