//
//  SettingsView.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import DesignSystem
import SwiftUI

public struct SettingsView: View {
    // MARK: - Properties
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingShareSheet = false

    // MARK: - Initialization
    public init(viewModel: SettingsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            List {
                generalSection
                displaySection
                dataStorageSection
                aboutSection
                supportSection
                legalSection

                #if DEBUG
                developerSection
                #endif
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Clear Cache", isPresented: $viewModel.showingClearCacheAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { viewModel.clearCache() }
            } message: {
                Text("This will delete all cached images and data. The app will need to download content again.")
            }
            .alert("Reset Settings", isPresented: $viewModel.showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { viewModel.resetSettings() }
            } message: {
                Text("This will reset all settings to their default values and clear your favorites and search history.")
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheetView(items: viewModel.shareApp())
            }
        }
    }

    // MARK: - General Section
    private var generalSection: some View {
        Section {
            Toggle(isOn: $viewModel.isNotificationsEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications")
                        Text(viewModel.notificationStatusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.red)
                }
            }
            .onChange(of: viewModel.isNotificationsEnabled) { _ in
                viewModel.toggleNotifications()
            }

            Toggle(isOn: $viewModel.isDarkModeEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dark Mode")
                        Text("Use dark theme")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                }
            }
            .onChange(of: viewModel.isDarkModeEnabled) { _ in
                viewModel.toggleDarkMode()
            }
        } header: {
            SettingsSectionHeaderView(title: "General", systemImage: "gearshape.fill", color: .secondary)
        }
    }

    // MARK: - Display Section
    private var displaySection: some View {
        Section {
            Picker(selection: $viewModel.imageQuality) {
                ForEach(ImageQuality.allCases, id: \.self) { quality in
                    VStack(alignment: .leading) {
                        Text(quality.title)
                        Text(quality.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(quality)
                }
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Image Quality")
                        Text(viewModel.imageQuality.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.blue)
                }
            }
            .onChange(of: viewModel.imageQuality) { newValue in
                viewModel.updateImageQuality(newValue)
            }

            Toggle(isOn: $viewModel.isAutoPlayVideosEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto-play Videos")
                        Text("Play videos automatically")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .onChange(of: viewModel.isAutoPlayVideosEnabled) { _ in
                viewModel.toggleAutoPlayVideos()
            }
        } header: {
            SettingsSectionHeaderView(title: "Display", systemImage: "display", color: .secondary)
        }
    }

    // MARK: - Data & Storage Section
    private var dataStorageSection: some View {
        Section {
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cache Size")
                        Text(viewModel.cacheStatusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "externaldrive.fill")
                        .foregroundColor(.orange)
                }

                Spacer()

                Button("Clear") { viewModel.showingClearCacheAlert = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }

            Button {
                viewModel.showingResetAlert = true
            } label: {
                Label {
                    Text("Reset All Settings")
                        .foregroundColor(.red)
                } icon: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.red)
                }
            }
        } header: {
            SettingsSectionHeaderView(title: "Data & Storage", systemImage: "externaldrive", color: .secondary)
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle.fill")
                    .foregroundColor(.blue)
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Build", systemImage: "hammer.fill")
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.buildNumber)
                    .foregroundColor(.secondary)
            }

            Button { viewModel.rateApp() } label: {
                Label {
                    Text("Rate MarvelApp")
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }

            Button { showingShareSheet = true } label: {
                Label {
                    Text("Share MarvelApp")
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }
            }
        } header: {
            SettingsSectionHeaderView(title: "About", systemImage: "info.circle", color: .secondary)
        }
    }

    // MARK: - Support Section
    private var supportSection: some View {
        Section {
            Button { viewModel.contactSupport() } label: {
                Label {
                    Text("Contact Support")
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                }
            }

            Button { viewModel.reportBug() } label: {
                Label {
                    Text("Report a Bug")
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "ladybug.fill")
                        .foregroundColor(.red)
                }
            }

            Link(destination: URL(string: "https://marvelapp.com/faq")!) {
                Label {
                    HStack {
                        Text("FAQ")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        } header: {
            SettingsSectionHeaderView(title: "Support", systemImage: "questionmark.circle", color: .secondary)
        }
    }

    // MARK: - Legal Section
    private var legalSection: some View {
        Section {
            Button { viewModel.openPrivacyPolicy() } label: {
                Label {
                    HStack {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.purple)
                }
            }

            Button { viewModel.openTermsOfService() } label: {
                Label {
                    HStack {
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                }
            }

            HStack {
                Label {
                    VStack(alignment: .leading) {
                        Text("Data © Marvel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("© 2025 MARVEL")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "c.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        } header: {
            SettingsSectionHeaderView(title: "Legal", systemImage: "doc.text", color: .secondary)
        }
    }

    // MARK: - Developer Section (Debug Only)
    #if DEBUG
    private var developerSection: some View {
        Section {
            HStack {
                Label("API Status", systemImage: "network")
                    .foregroundColor(.blue)
                Spacer()
                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.apiStatus.color)
                        .frame(width: 8, height: 8)
                    Text(viewModel.apiStatus.text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button {
                fatalError("Test crash")
            } label: {
                Label {
                    Text("Force Crash")
                        .foregroundColor(.red)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
        } header: {
            SettingsSectionHeaderView(title: "Developer", systemImage: "hammer.fill", color: .secondary)
        }
    }
    #endif
}
