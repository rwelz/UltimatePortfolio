//
//  ContentView.swift
//  TestLogging
//
//  Created by Robert Welz on 06.10.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            "ContentView appeared".debugLog() // CustomStringConvertible-debugLog
            let issue = Issue.example
            let issues = [issue]
            MyUnifiedLogger.logTopIssues(resultSet: issues, loglevel: .notice)
            MyUnifiedLogger.logIssuesCount(resultSet: issues, loglevel: .notice)
            MyUnifiedLogger.logData(data: "This is a Test of logData", loglevel: .notice)
            MyUnifiedLogger.logString("This is a Test of logString", loglevel: .notice)
        }
    }
}

#Preview {
    ContentView()
}
