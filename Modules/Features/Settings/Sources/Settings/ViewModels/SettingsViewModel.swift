//
//  SettingsViewModel.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import Foundation
import SwiftUI

@MainActor
public final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var isNotificationsEnabled = false
    @Published public var isDarkModeEnabled = true
    @Published public var isAutoPlayVideosEnabled = false
    @Published public var imageQuality: ImageQuality = .high
    @Published public var cacheSize: String = "Calculating..."
    @Published public var appVersion: String = ""
    @Published public var buildNumber: String = ""
    @Published public var showingClearCacheAlert = false
    @Published public var showingResetAlert = false
    @Published public var apiStatus: APIStatus = .checking

    // MARK: - Private Properties
    private let cacheManager: CacheManagerProtocol?
    private let userDefaults = UserDefaults.standard

    // MARK: - Computed Properties
    public var notificationStatusText: String {
        isNotificationsEnabled ? "Enabled" : "Disabled"
    }

    public var cacheStatusText: String { cacheSize }

    // MARK: - Initialization
    public init(cacheManager: CacheManagerProtocol? = nil) {
        self.cacheManager = cacheManager
        loadSettings()
        loadAppInfo()
        calculateCacheSize()
        checkAPIStatus()
    }

    // MARK: - Public Methods
    public func toggleNotifications() {
        isNotificationsEnabled.toggle()
        saveSettings()
        if isNotificationsEnabled { requestNotificationPermission() }
    }

    public func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        saveSettings()
        applyTheme()
    }

    public func toggleAutoPlayVideos() {
        isAutoPlayVideosEnabled.toggle()
        saveSettings()
    }

    public func updateImageQuality(_ quality: ImageQuality) {
        imageQuality = quality
        saveSettings()
    }

    public func clearCache() {
        Task {
            if let manager = cacheManager {
                await manager.clearAll()
                calculateCacheSize()
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
            }
        }
    }

    public func resetSettings() {
        isNotificationsEnabled = false
        isDarkModeEnabled = true
        isAutoPlayVideosEnabled = false
        imageQuality = .high

        userDefaults.removeObject(forKey: "notifications_enabled")
        userDefaults.removeObject(forKey: "dark_mode_enabled")
        userDefaults.removeObject(forKey: "auto_play_videos")
        userDefaults.removeObject(forKey: "image_quality")
        userDefaults.removeObject(forKey: "FavoriteCharacters")
        userDefaults.removeObject(forKey: "RecentSearches")

        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
    }

    public func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789") {
            UIApplication.shared.open(url)
        }
    }

    public func shareApp() -> [Any] {
        let text = "Check out MarvelApp - Your guide to the Marvel Universe!"
        let url = URL(string: "https://apps.apple.com/app/id123456789")!
        return [text, url]
    }

    public func openPrivacyPolicy() {
        if let url = URL(string: "https://marvelapp.com/privacy") {
            UIApplication.shared.open(url)
        }
    }

    public func openTermsOfService() {
        if let url = URL(string: "https://marvelapp.com/terms") {
            UIApplication.shared.open(url)
        }
    }

    public func contactSupport() {
        if let url = URL(string: "mailto:support@marvelapp.com") {
            UIApplication.shared.open(url)
        }
    }

    public func reportBug() {
        let email = "bugs@marvelapp.com"
        let subject = "Bug Report - MarvelApp \(appVersion)"
        let body = """
        ---
        App Version: \(appVersion)
        Build: \(buildNumber)
        Device: \(UIDevice.current.model)
        iOS: \(UIDevice.current.systemVersion)
        """

        if let url = URL(
            string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        ) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Private Methods
    private func loadSettings() {
        isNotificationsEnabled = userDefaults.bool(forKey: "notifications_enabled")
        isDarkModeEnabled = userDefaults.object(forKey: "dark_mode_enabled") as? Bool ?? true
        isAutoPlayVideosEnabled = userDefaults.bool(forKey: "auto_play_videos")

        if let qualityRaw = userDefaults.string(forKey: "image_quality"),
           let quality = ImageQuality(rawValue: qualityRaw) {
            imageQuality = quality
        }
    }

    private func saveSettings() {
        userDefaults.set(isNotificationsEnabled, forKey: "notifications_enabled")
        userDefaults.set(isDarkModeEnabled, forKey: "dark_mode_enabled")
        userDefaults.set(isAutoPlayVideosEnabled, forKey: "auto_play_videos")
        userDefaults.set(imageQuality.rawValue, forKey: "image_quality")
    }

    private func loadAppInfo() {
        appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
    }

    private func calculateCacheSize() {
        Task {
            if let manager = cacheManager {
                let size = await manager.getCacheSize()
                cacheSize = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .binary)
            } else {
                let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                if let size = try? FileManager.default.sizeOfDirectory(at: URL(fileURLWithPath: documents)) {
                    cacheSize = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .binary)
                }
            }
        }
    }

    private func checkAPIStatus() {
        Task {
            apiStatus = .checking
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            let publicKey = Bundle.main.object(forInfoDictionaryKey: "MARVEL_PUBLIC_KEY") as? String ?? ""
            let privateKey = Bundle.main.object(forInfoDictionaryKey: "MARVEL_PRIVATE_KEY") as? String ?? ""

            if !publicKey.isEmpty && !privateKey.isEmpty &&
                publicKey != "YOUR_PUBLIC_KEY_HERE" && privateKey != "YOUR_PRIVATE_KEY_HERE" {
                apiStatus = .online
            } else {
                apiStatus = .offline
            }
        }
    }

    private func requestNotificationPermission() {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                if !granted {
                    isNotificationsEnabled = false
                    saveSettings()
                }
            } catch {
                isNotificationsEnabled = false
                saveSettings()
            }
        }
    }

    private func applyTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = isDarkModeEnabled ? .dark : .light }
        }
    }
}
