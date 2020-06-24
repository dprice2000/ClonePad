//
//  Note.swift
//  Challenge6
//
//  Created by David Price on 6/4/20.
//  Copyright © 2020 David Price. All rights reserved.
//

import Foundation

class Note: Codable {
    // We use a UITextView to display and edit the note
    // The text view's attributed string lets us edit the attributes of the text as well as the content
    // however, NSAttributedString is not a codable object.  So we cannot encode it into our JSON and
    // save it to disk.  So we convert the NSAttributedString to Data formatted as RTF
    
    var noteContents: Data!  // NSAttributedString.data as rtf
    var titleText: String!   // first line of the note
}
