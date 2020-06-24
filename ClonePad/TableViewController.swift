//
//  ViewController.swift
//  Challenge6
//
//  Created by David Price on 5/30/20.
//  Copyright © 2020 David Price. All rights reserved.
//

/*
 TableViewController
 
 functions:
   holds the notes array
   loads the notes from disk and populates the table view
   the first line of the note is used at the title of the note
   notes are stored with the most recently edited note on top
   create new notes
   save the notes back to disk every time we return to view
 
 */

import UIKit

class TableViewController: UITableViewController {

    var notes = [Note]()            // all of the notes
    var noteFilePath: URL?          // path to the file where we load and save the notes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add the new note button and hook it up to createNewNote
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewNote))

        // find the path to the file containing our saved notes and keep track of it.
        // notes are saved in a JSON file.  Decode them and populate the array of notes
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        noteFilePath = paths[0].appendingPathComponent("notes.ClonePad.JSON")
        if noteFilePath != nil {
            let decoder = JSONDecoder()
            do {
                let data = try Data(contentsOf: noteFilePath!)
                try notes = decoder.decode([Note].self, from: data)
            } catch {
                print("Cannot read file")
            }
        }
    } // viewDidLoad()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // the notes are stored with the most recently edited note at the top of the list.
        // create a note view controller, give it the note for this row
        // give a reference to the controller so we can save the note back to the list
        // then delete the note from the notes array.  When we finish editing the note
        // it will be appended to the front of the notes array.  If we delete the note
        // nothing will be done.
        // finaly push the controller onto the stack
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController {
            vc.note = notes[indexPath.row]
            vc.tvc = self
            notes.remove(at: indexPath.row)
            navigationController?.pushViewController(vc, animated: true)
        }
    } // tableView didSelectRowAt

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    } // tableView numberOfRowsInSelection
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // the first line of the note is the title of the note.
        // just grab that from the note class.
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let titleText = notes[indexPath.row].titleText
        cell.textLabel?.text = titleText
        return cell
    } // tableView cellForRowAt
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if we swiped to delete, remove the note from the array and then reload the table data
        // otherwise if we are adding a line, make a new note.
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            createNewNote()
        }
    } // tableView commit editingStyle

    @objc func createNewNote() {
        // create a new note class and put in an empty data object.  The NoteViewController will fail to decode that
        // and assume that we are making a new note.
        let note = Note()
        note.noteContents = Data()
        
        // populate the NoteViewController with the note and a reference to this view controller so that the child can
        // save the note to our notes array
        // put the view controller to the stack
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController {
            vc.note = note
            vc.tvc = self
            navigationController?.pushViewController(vc, animated: true)
        }
    } // createNewNote
    
    override func viewWillAppear(_ animated: Bool) {
        // when this view will appear we need to reload the tableView's data.
        // either 1 - application is loading and we need to populate the data for
        // the first time or 2- we came back from the note view and need to reshow
        // the table with the most recently edited note at the top of the list
        // then save the notes to the file.
        tableView.reloadData()
        saveNotes() // wasteful on application load, we save the notes back to file immediately after loading them
    } // viewWillAppear
    
    func saveNotes() {
        // encode the notes with the JSON encoder and write them to file.
        // we will lose edited changes to the note being editied if the app is closed when the
        // NoteViewController is active.
        
        var data = Data()
        let encoder = JSONEncoder()
        guard noteFilePath != nil else { return }
        
        do {
            try data = encoder.encode(notes)
            try data.write(to: noteFilePath!, options: [.atomicWrite])
        } catch {
            print("Unable to save data.")
        }
    } // saveNotes
        
} //TableViewController

