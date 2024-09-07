//
//  File.swift
//  
//
//  Created by Sandor Kolotenko on 07/09/2024.
//

import Foundation

// MARK: - HelpBridgeError
public enum HelpBridgeError: Error, Equatable {
    case missingBaseURL
    case networkError(message: String)
    case httpError(statusCode: Int)
    case noInternetConnection
    case timeout
    case ticketSubmissionFailed
}
