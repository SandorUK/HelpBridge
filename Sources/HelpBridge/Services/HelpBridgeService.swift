/* HelpBridge is licensed under the MIT License.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 Attribution:
 This software contains contributions by Sandor Kolotenko.
 */

import Foundation

// MARK: - HelpBridgeService
public class HelpBridgeService: HelpBridgeServiceProtocol {
    
    private var baseURL: String
    private var urlSession: URLSession
    
    // MARK: - Initialisation
    required public init(baseURL: String? = nil, urlSession: URLSession = .shared) throws {
        if let envBaseURL = ProcessInfo.processInfo.environment["HELPBRIDGE_BASE_URL"] {
            self.baseURL = envBaseURL
        } else if let providedBaseURL = baseURL {
            self.baseURL = providedBaseURL
        } else {
            throw HelpBridgeError.missingBaseURL
        }
        self.urlSession = urlSession  // Allow injection of custom URLSession
    }
    
    // MARK: - Async Throws Version
    @available(iOS 13.0.0, *)
    public func submitSupportTicket(_ ticket: SupportTicket) async throws {
        let fullURLString = "\(baseURL)/en/customer/create-ticket/"
        
        guard let url = URL(string: fullURLString) else {
            throw HelpBridgeError.networkError(message: "Invalid URL")
        }
        
        var request = createRequest(url: url)
        request.httpBody = createBody(with: ticket)
        
        do {
            let (_, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HelpBridgeError.networkError(message: "Invalid response format")
            }
            
            if httpResponse.statusCode == 200 {
                // Check the response data to ensure the ticket was submitted successfully.
                // For now, assuming if HTTP status is 200, it's successful.
                return
            } else {
                throw HelpBridgeError.httpError(statusCode: httpResponse.statusCode)
            }
        } catch let error as HelpBridgeError {
            throw error
        } catch let error as NSError {
            switch error.code {
            case -1009:
                throw HelpBridgeError.noInternetConnection
            case NSURLErrorTimedOut:
                throw HelpBridgeError.timeout
            default:
                throw HelpBridgeError.networkError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Completion Handler Version
    public func submitSupportTicket(_ ticket: SupportTicket, completion: @escaping (Result<Void, HelpBridgeError>) -> Void) {
        let fullURLString = "\(baseURL)/en/customer/create-ticket/"
        
        guard let url = URL(string: fullURLString) else {
            completion(.failure(.networkError(message: "Invalid URL")))
            return
        }
        
        var request = createRequest(url: url)
        request.httpBody = createBody(with: ticket)
        
        sendRequest(request, completion: completion)
    }
    
    // MARK: - Private Helper Methods
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-GB,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("u=0, i", forHTTPHeaderField: "Priority")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("multipart/form-data; boundary=\(APIConstants.boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(baseURL, forHTTPHeaderField: "Referer")
        
        return request
    }
    
    private func createBody(with ticket: SupportTicket) -> Data? {
        let body = """
        \(APIConstants.boundaryPadding)Content-Disposition: form-data; name="name"\r\n\r\n\(ticket.name)\r
        \(APIConstants.boundaryPadding)Content-Disposition: form-data; name="from"\r\n\r\n\(ticket.email)\r
        \(APIConstants.boundaryPadding)Content-Disposition: form-data; name="type"\r\n\r\n\(ticket.type)\r
        \(APIConstants.boundaryPadding)Content-Disposition: form-data; name="subject"\r\n\r\n\(ticket.subject)\r
        \(APIConstants.boundaryPadding)Content-Disposition: form-data; name="reply"\r\n\r\n\(ticket.message)\r
        ------WebKitFormBoundaryq0qKH8apUNfyKGNp--\r\n
        """
        
        return body.data(using: .utf8)
    }
    
    private func sendRequest(_ request: URLRequest, completion: @escaping (Result<Void, HelpBridgeError>) -> Void) {
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                switch error.code {
                case -1009:
                    completion(.failure(.noInternetConnection))
                case NSURLErrorTimedOut:
                    completion(.failure(.timeout))
                default:
                    completion(.failure(.networkError(message: error.localizedDescription)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(.success(()))
                } else {
                    completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: Support Ticket Sumbission

    // MARK: - Usage Example with Async/Await
    @available(macOS 12.0, iOS 15.0, *)
    func submitTicketAsync() async {
        do {
            let service = try HelpBridgeService(baseURL: nil) // Or pass a custom URL if available
            let ticket = SupportTicket(name: "Banana Rama",
                                       email: "isandor@me.com",
                                       type: "2",
                                       subject: "My Test App Support Ticket 2",
                                       message: "Oh this support ticket is a test22222!")
            
            try await service.submitSupportTicket(ticket)
            print("Support ticket submitted successfully.")
        } catch HelpBridgeError.missingBaseURL {
            print("Error: HelpBridge base URL not set.")
        } catch HelpBridgeError.noInternetConnection {
            print("No Internet connection. Please reconnect and try again.")
        } catch HelpBridgeError.timeout {
            print("We didn't hear back from the support server in time, please try again later.")
        } catch HelpBridgeError.httpError(let statusCode) {
            print("Error occurred while submitting support ticket. HTTP Status Code: \(statusCode)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    // MARK: - Usage Example with Completion Handler
    func submitTestTicketWithCompletion() {
        do {
            let service = try HelpBridgeService(baseURL: nil) // Or pass a custom URL if available
            let ticket = SupportTicket(name: "HelpBridge Swift Package",
                                       email: "happy.user@yopmail.com",
                                       type: "1",
                                       subject: "HelpBridge Swift Package Test Ticket",
                                       message: "Lorem ipsum dolor sit amet!\nLorem ipsum dolor sit amet!")
            
            service.submitSupportTicket(ticket) { result in
                switch result {
                case .success:
                    print("Support ticket submitted successfully.")
                case .failure(let error):
                    switch error {
                    case .missingBaseURL:
                        print("Error: HelpBridge base URL not set.")
                    case .noInternetConnection:
                        print("No Internet connection. Please reconnect and try again.")
                    case .timeout:
                        print("We didn't hear back from the support server in time, please try again later.")
                    case .httpError(let statusCode):
                        print("Error occurred while submitting support ticket. HTTP Status Code: \(statusCode)")
                    case .networkError(let message):
                        print("Network error: \(message)")
                    case .ticketSubmissionFailed:
                        print("Error occurred while submitting support ticket. Please try again later.")
                    }
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}
