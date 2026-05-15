//
//  DraftManager.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

class DraftManager {
    private let defaults = UserDefaults.standard
    private let draftsKey = "chat_drafts"
    private let namesKey = "chat_draft_names"

    // Guarda el mensaje y el nombre del profesional
    func saveDraft(chatId: String, text: String, professionalName: String = "") {
        var drafts = getAllDrafts()
        var names = getAllDraftNames()
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                drafts.removeValue(forKey: chatId)
                names.removeValue(forKey: chatId)
        } else {
            drafts[chatId] = text
            if !professionalName.isEmpty {
                names[chatId] = professionalName
            }
        }
        
        defaults.set(drafts, forKey: draftsKey)
        defaults.set(names, forKey: namesKey)
    }

    func getDraft(chatId: String) -> String {
        return getAllDrafts()[chatId] ?? ""
    }
    
    func getDraftName(chatId: String) -> String {
        return getAllDraftNames()[chatId] ?? ""
    }
    
    func getAllDrafts() -> [String: String] {
        return defaults.dictionary(forKey: draftsKey) as? [String: String] ?? [:]
    }

    private func getAllDraftNames() -> [String: String] {
        return defaults.dictionary(forKey: namesKey) as? [String: String] ?? [:]
    }

    func clearDraft(chatId: String) {
        var drafts = getAllDrafts()
        var names = getAllDraftNames()
        
        drafts.removeValue(forKey: chatId)
        names.removeValue(forKey: chatId)
        
        defaults.set(drafts, forKey: draftsKey)
        defaults.set(names, forKey: namesKey)
    }
    
}
