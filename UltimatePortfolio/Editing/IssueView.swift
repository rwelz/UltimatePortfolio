//
//  IssueView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 15.05.25.
//

import SwiftUI

// TODO: make app backwards compatible down to macOS 11
// TODO: make app backwards compatible down to iOS 14
// TODO: check if obsolete app group entries were removed from server:
// TODO: https://developer.apple.com/account/resources/identifiers/list
// TODO: and from Xcode project under "Signing & Capabilities -> App Groups"
struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController

    @State private var showingNotificationsError = false
    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                        .labelsHidden()

                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)

                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)

                }

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }

                TagsMenuView(issue: issue)
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical)
                    .labelsHidden()
                }
            }
            Section("Reminders") {
                Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())

                if issue.reminderEnabled {
                   DatePicker(
                       "Reminder time",
                       selection: $issue.issueReminderTime,
                       displayedComponents: .hourAndMinute
                   )
                }
            }
        }
        .formStyle(.grouped)
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        .alert("Oops!", isPresented: $showingNotificationsError) {
        #if os(macOS)
            SettingsLink {
                    Text("Check Settings")
                }
            #else
            Button("Check Settings", action: showAppSettings)
            #endif
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: issue.reminderEnabled) {
            updateReminder()
        }
        .onChange(of: issue.reminderTime) {
            updateReminder()
        }
    }

#if os(iOS)
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }
#endif

    func updateReminder() {
        dataController.removeReminders(for: issue)

        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)

                if success == false {
                    issue.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
}
