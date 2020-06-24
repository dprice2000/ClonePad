//
//  NoteViewController.swift
//  Challenge6
//
//  Created by David Price on 5/30/20.
//  Copyright © 2020 David Price. All rights reserved.

/*
    NoteViewController
 
    This class displays the note in a UITextView.  We manipulate the attributedText of the view
    A bar button item is created to handle deleting a note
    Convert the attributed string into RTF format and update the note class with the new note
 
 */

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var noteView: UITextView!    // UITextView display and edit the note
    var note: Note!                             // Note object for current view
    var deleteThisNote =  false                 // am I going to delete this note?
    weak var tvc: TableViewController!          // reference to the creating view controller so we can save our note
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // convert the RTF data into an attributed string.
        // if that fails, we make a new note
        do
        {
            noteView.attributedText = try NSAttributedString(data: note.noteContents,
                                                             options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                                                             documentAttributes: nil)
        } catch {
            noteView.attributedText = NSAttributedString(string:"This is a new note")
        }
        // add the delete button and hook it up to the deleteNote method
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))

        // add observers to listed for the keyboard appearing and disappearing
        // adjust the view size to fit around the keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    } // viewDidLoad
    
    override func viewWillDisappear(_ animated: Bool) {
        // add the note back into the array of notes
        // if we are deleting this note, do nothing.  It was removed from the array when we started editing.
        if deleteThisNote == true {
            return
        }
        
        // assert that we were set up properly
        assert(tvc != nil)
        assert(note != nil)
        
        // convert the attributed string into RTF format.
        // separate out of the first line as the title of the note for the text view.
        // add it to the front of the array of notes
        
        note.noteContents = try? noteView.attributedText.data(from: .init(location: 0, length: noteView.attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        let titleText = noteView.attributedText.string.split(separator: "\n")[0].base
        note.titleText = titleText
        tvc.notes.insert(note, at: 0)
    } // viewWillDisappaer

    @objc func deleteNote() {
        // toss up an alert to confirm that the user wants to delete their note.
        // if yes, set deleteThisNote to true otherwise, do nothing.
        let ac = UIAlertController(title: "Confirm deletion", message: "Are you sure?", preferredStyle: .alert)
        let actionConfirmed = UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            self?.navigationController?.popViewController(animated: true)
            self?.deleteThisNote = true
        }
        let actionCanceled = UIAlertAction(title: "No", style: .cancel)

        ac.addAction(actionConfirmed)
        ac.addAction(actionCanceled)
        present(ac, animated: true)
    } // deleteNote


    @objc func adjustForKeyboard(notification: Notification) {
        // this resizes the noteView so that it does not get lost under the keyboard

        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        // grab the size of the keyboard frame
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        // if it is disappearing, let the text view have the whole screen
        // otherwise, inset the text view so it doesn't appaer behind the keyboard
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteView.contentInset = .zero
        } else {
            noteView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        // scroll the text view so that the cursor is onscreen.  Otherwise the user will be
        // editing off screen
        noteView.scrollIndicatorInsets = noteView.contentInset
        let selectedRange = noteView.selectedRange
        noteView.scrollRangeToVisible(selectedRange)
    } // adjustForKeyboard
    
}
