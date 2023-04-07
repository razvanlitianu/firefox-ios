import XCTest
import CoreSpotlight

@testable import Client

final class UserActivityRouteTests: XCTestCase {
    func testNewTabShortcut() {
        let shortcutItem = UIApplicationShortcutItem(type: "com.example.app.NewTab", localizedTitle: "New Tab")
        let route = Route(shortcutItem: shortcutItem)
        XCTAssertEqual(route, .search(url: nil, isPrivate: false))
    }

    func testNewPrivateTabShortcut() {
        let shortcutItem = UIApplicationShortcutItem(type: "com.example.app.NewPrivateTab", localizedTitle: "New Private Tab")
        let route = Route(shortcutItem: shortcutItem)
        XCTAssertEqual(route, .search(url: nil, isPrivate: true))
    }

    func testOpenLastBookmarkShortcutWithValidUrl() {
        let userInfo = [QuickActionInfos.tabURLKey: "https://www.example.com" as NSSecureCoding]
        let shortcutItem = UIApplicationShortcutItem(type: "com.example.app.OpenLastBookmark", localizedTitle: "Open Last Bookmark", localizedSubtitle: nil, icon: nil, userInfo: userInfo)
        let route = Route(shortcutItem: shortcutItem)
        XCTAssertEqual(route, .search(url: URL(string: "https://www.example.com"), isPrivate: false))
    }

    func testOpenLastBookmarkShortcutWithInvalidUrl() {
        let userInfo = [QuickActionInfos.tabURLKey: "not a url" as NSSecureCoding]
        let shortcutItem = UIApplicationShortcutItem(type: "com.example.app.OpenLastBookmark", localizedTitle: "Open Last Bookmark", localizedSubtitle: nil, icon: nil, userInfo: userInfo)
        let route = Route(shortcutItem: shortcutItem)
        XCTAssertNil(route)
    }

    func testQRCodeShortcut() {
        let shortcutItem = UIApplicationShortcutItem(type: "com.example.app.QRCode", localizedTitle: "QR Code")
        let route = Route(shortcutItem: shortcutItem)
        XCTAssertEqual(route, .action(action: .showQRCode))
    }

    func testInvalidShortcut() {
        let shortcutItem = UIApplicationShortcutItem(type: "invalid shortcut", localizedTitle: "Invalid Shortcut")
        let route = Route(shortcutItem: shortcutItem)
        XCTAssertNil(route)
    }

    func testOpenURLUserActivity() {
        let userActivity = NSUserActivity(activityType: SiriShortcuts.activityType.openURL.rawValue)
        let route = Route(userActivity: userActivity)
        XCTAssertEqual(route, .search(url: nil, isPrivate: false))
    }

    func testWebpageURLUserActivity() {
        let url = URL(string: "https://www.example.com")!
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = url
        let route = Route(userActivity: userActivity)
        XCTAssertEqual(route, .search(url: url, isPrivate: false))
    }

    func testCoreSpotlightUserActivityWithValidUrl() {
        let urlString = "https://www.example.com"
        let userInfo = [CSSearchableItemActivityIdentifier: urlString]
        let userActivity = NSUserActivity(activityType: CSSearchableItemActionType)
        userActivity.userInfo = userInfo
        let route = Route(userActivity: userActivity)
        XCTAssertEqual(route, .search(url: URL(string: urlString), isPrivate: false))
    }

    func testCoreSpotlightUserActivityWithInvalidUrl() {
        let urlString = "not a url"
        let userInfo = [CSSearchableItemActivityIdentifier: urlString]
        let userActivity = NSUserActivity(activityType: CSSearchableItemActionType)
        userActivity.userInfo = userInfo
        let route = Route(userActivity: userActivity)
        XCTAssertNil(route)
    }

    func testUnknownUserActivity() {
        let userActivity = NSUserActivity(activityType: "unknown activity type")
        let route = Route(userActivity: userActivity)
        XCTAssertNil(route)
    }
}

