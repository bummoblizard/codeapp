//
//  searchBar.swift
//  Code App
//
//  Created by Ken Chung on 5/12/2020.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    @State private var isEditing = false
    let searchAction: (() -> Void)?
    var clearAction: (() -> Void)? = nil
    let placeholder: String
    let cornerRadius: CGFloat?

    var body: some View {
        HStack {
            TextField(placeholder, text: $text, onCommit:{searchAction?()})
                .font(.system(size: 14))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color.init(id: "input.background"))
                .cornerRadius(cornerRadius ?? 15)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        if isEditing && text != "" {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded({
                                            self.text = ""
                                            clearAction?()
                                        })
                                )
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
        }
    }
}
