//
//  IssueViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 05.06.25.
//

#if canImport(CoreHaptics)
import CoreHaptics
#endif
import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    #if canImport(CoreHaptics)
    @State private var engine = try? CHHapticEngine()
    #endif

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        #if !os(watchOS)
        Menu {
            Button("Copy Issue Title", systemImage: "doc.on.doc", action: copyToClipboard)

            Button(action: toggleCompleted) {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
//            .sensoryFeedback(trigger: issue.completed) { oldValue, newValue in
//                if newValue {
//                    .success
//                } else {
//                    nil
//                }
//            }

            // habe .sensoryFeedback nicht zum laufen gebracht, vielleicht ein Bug in SwiftUI?
            // .sensoryFeedback(trigger: issue.completed) { oldValue, newValue in
            //    if newValue {
            //        .selection
            //        //.impact()
            //        //.impact(flexibility: .solid, intensity: 1.0 )
            //    } else {
            //        nil
            //    }
            // }

            // .sensoryFeedback(trigger: issue.completed){ old,new in
            //            if old == false {
            //                return .selection
            //            }
            //            else {
            //                return .impact
            //            }
            //        }
            Divider()

            Section("Tags") {
               // Can be added to menu, handled automatically by SwiftUI - its a trick
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
        #endif
    }

    func toggleCompleted() {
        issue.completed.toggle()
        // dataController.save()

	// advanced haptics: import CoreHaptics
        #if canImport(CoreHaptics)
        if issue.completed {
            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                // playing haptics didn't work, but that's okay
            }
        }
        #endif
    }

    func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = issue.title
        #elseif os(macOS)
        NSPasteboard.general.prepareForNewContents()
        NSPasteboard.general.setString(issue.issueTitle, forType: .string)
        #endif
    }
}

struct IssueViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        IssueViewToolbar(issue: Issue.example)
            .environmentObject(DataController(inMemory: true))
    }
}

// #Preview {
//    IssueViewToolbar(issue: Issue.example)
//        .environmentObject(DataController(inMemory: true))
//    }
