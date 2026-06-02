import Foundation

enum TapJailConstants {
    static let appGroupID = "group.com.piperstudio.tapjail"
    static let urlScheme = "tapjail"
    static let prisonURL = URL(string: "tapjail://prison")!

    enum StorageKey {
        static let selectedActivitySelection = "selectedActivitySelection"
        static let isLockActive = "isLockActive"
        static let tapTarget = "tapTarget"
        static let sessionStartedAt = "sessionStartedAt"
    }
}

