//
//  NotesVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 20.03.2021.
//

import Foundation

class NotesVM {
    
    var notes = [Note]()
    
    let currentCategory: String
    
    init(currentCategory: String) {
        self.currentCategory = currentCategory
    }
    
    public func getCurrentCategory() -> String {
        return currentCategory
    }
    
    public func fetchNotes(completion: @escaping () -> Void) {
        
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        
        notes = [Note]()
        
        DatabaseManager.shared.fetchNotes(for: email) { [weak self] notesArray in
            for note in notesArray {
                if note.parentCategory == self?.currentCategory {
                    self?.notes.append(note)
                }
            }
            completion()
        }
    }
    
    public func sortNotesDescendingByDate() {
        notes.sort {
            $0.dateCreated > $1.dateCreated
        }
    }
    
    public func addNote(note: Note) {
        notes.append(note)
        
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        DatabaseManager.shared.insertNoteItem(item: note, for: email) { success in
            if success {
                print("Note was added successfully !")
            } else {
                print("Error with adding note")
            }
        }
    }
    
    public func getNumberOfNotes() -> Int {
        return notes.count
    }
    
    public func getNoteTitle(for indexPath: IndexPath) -> String {
        return notes[indexPath.row].title
    }
}
