//
//  EditorInstance.swift
//  Code App
//
//  Created by Ken Chung on 5/12/2020.
//

import Foundation
import SwiftUI

class EditorInstance: Identifiable, Equatable, Hashable, ObservableObject {

    static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let type: tabType

    @Published var lastSavedVersionId = 1
    @Published var currentVersionId = 1
    
    var id = UUID()
    var url: String
    var content: String
    var compareTo: String? = nil
    var image: Image? = nil
    var encoding: String.Encoding = .utf8
    var fileWatch: FolderMonitor?
    var isDeleted = false
    
    var isSaved: Bool {
        lastSavedVersionId == currentVersionId
    }
    var displayName: String {
        if type == .diff {
            let name1 = url.components(separatedBy: "/").last?.removingPercentEncoding ?? ""
            let name2 =
                compareTo!.components(separatedBy: "/").last?.removingPercentEncoding ?? ""
            if compareTo!.hasPrefix("file://previous") {
                return "\(name1) (Working Tree)"
            }
            return "\(name2) ↔ \(name1)"
        }
        if url.hasSuffix("{welcome}") {
            return NSLocalizedString("Welcome", comment: "")
        }
        if type == .preview {
            let name =
                url.replacingOccurrences(of: "{preview}", with: "").components(separatedBy: "/")
                .last?.removingPercentEncoding ?? ""
            return "Preview: " + name
        }
        return url.components(separatedBy: "/").last?.removingPercentEncoding ?? ""
    }

    init(
        url: String, content: String, type: tabType, encoding: String.Encoding = .utf8,
        compareTo: String? = nil, image: Image? = nil,
        fileDidChange: ((fileState, String?) -> Void)? = nil
    ) {
        self.url = url
        self.content = content
        self.type = type
        self.encoding = encoding
        self.compareTo = compareTo
        self.image = image

        if fileDidChange != nil, let url = URL(string: url), url.scheme == "file" {
            self.fileWatch = FolderMonitor(url: url)

            self.fileWatch?.folderDidChange = {
                if let content = try? String(contentsOf: url, encoding: self.encoding) {
                    if self.lastSavedVersionId == self.currentVersionId {
                        self.content = content
                        fileDidChange?(.modified, content)
                        self.lastSavedVersionId = self.currentVersionId
                    }
                }
            }
            self.fileWatch?.startMonitoring()
        }

    }

    deinit {
        self.fileWatch?.stopMonitoring()
    }

    enum fileState {
        case deleted
        case modified
    }

    enum tabType {
        case file
        case preview
        case diff
        case image
        case video
        case any
    }
}
