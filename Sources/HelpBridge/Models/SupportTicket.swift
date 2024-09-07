//
//  File.swift
//  
//
//  Created by Sandor Kolotenko on 07/09/2024.
//

import Foundation

// MARK: - SupportTicket Model
public struct SupportTicket {
    let name: String
    let email: String
    let type: String
    let subject: String
    let message: String
    
    public init(name: String, email: String, type: String, subject: String, message: String) {
        self.name = name
        self.email = email
        self.type = type
        self.subject = subject
        self.message = message
    }
}
