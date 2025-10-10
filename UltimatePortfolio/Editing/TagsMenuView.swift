//
//  TagsMenuView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 05.06.25.
//

import SwiftUI

struct TagsMenuView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController

    var body: some View {
#if os(watchOS)
        LabeledContent("Tags", value: issue.issueTagsList)
#else
        Menu {
            // show selected tags first
            ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }

            // now show unselected tags
            let otherTags = dataController.missingTags(from: issue)

            if otherTags.isEmpty == false {
                Divider()

                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)
        }
#endif
    }
}

// #Preview {
//    TagsMenuView(issue: .example)
//        .environmentObject(DataController(inMemory: true))
// }

struct TagsMenuView_Previews: PreviewProvider {
   static var previews: some View {
       TagsMenuView(issue: .example)
           .environmentObject(DataController(inMemory: true))
   }
}
