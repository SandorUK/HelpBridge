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

import XCTest
@testable import HelpBridge

final class HelpBridgeTests: XCTestCase {
    var service: HelpBridgeService!
    
    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        service = try HelpBridgeService(baseURL: "https://mockserver.com", urlSession: session)
    }
    
    override func tearDownWithError() throws {
        service = nil
        MockURLProtocol.requestHandler = nil
    }
    
    // MARK: - Test for Successful Submission (Completion Handler)
    func testSubmitSupportTicket_SuccessCompletion() throws {
        let ticket = SupportTicket(name: "John Doe", email: "john@example.com", type: "2", subject: "Test", message: "Test message")
        
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://mockserver.com/en/customer/create-ticket/")!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/en/customer/create-ticket")
            return (expectedResponse, nil)
        }
        
        let expectation = self.expectation(description: "Submit support ticket completion")
        
        service.submitSupportTicket(ticket) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure(let error):
                XCTFail("Expected success, but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Test for Successful Submission (Async/Await)
    @available(macOS 12.0, iOS 15.0, *)
    func testSubmitSupportTicket_SuccessAsync() async throws {
        let ticket = SupportTicket(name: "John Doe", 
                                   email: "john@example.com",
                                   type: "2",
                                   subject: "Test",
                                   message: "Test message")
        
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://mockserver.com/en/customer/create-ticket/")!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/en/customer/create-ticket")
            return (expectedResponse, nil)
        }
        
        do {
            try await service.submitSupportTicket(ticket)
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected success, but got error: \(error)")
        }
    }
    
    // MARK: - Test for HTTP Error (Completion Handler)
    func testSubmitSupportTicket_HTTPErrorCompletion() throws {
        let ticket = SupportTicket(name: "John Doe", 
                                   email: "john@example.com",
                                   type: "2",
                                   subject: "Test",
                                   message: "Test message")
        
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://mockserver.com/en/customer/create-ticket/")!,
                                               statusCode: 500,
                                               httpVersion: nil,
                                               headerFields: nil)!
        
        MockURLProtocol.requestHandler = { request in
            return (expectedResponse, nil)
        }
        
        let expectation = self.expectation(description: "Submit support ticket HTTP error")
        
        service.submitSupportTicket(ticket) { result in
            switch result {
            case .success:
                XCTFail("Expected error, but got success")
            case .failure(let error):
                if case .httpError(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)
                } else {
                    XCTFail("Expected HTTP error, but got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Test for HTTP Error (Async/Await)
    @available(macOS 12.0, iOS 15.0, *)
    func testSubmitSupportTicket_HTTPErrorAsync() async throws {
        let ticket = SupportTicket(name: "John Doe", 
                                   email: "john@example.com",
                                   type: "2",
                                   subject: "Test",
                                   message: "Test message")
        
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://mockserver.com/en/customer/create-ticket/")!,
                                               statusCode: 500,
                                               httpVersion: nil,
                                               headerFields: nil)!
        
        MockURLProtocol.requestHandler = { request in
            return (expectedResponse, nil)
        }
        
        do {
            try await service.submitSupportTicket(ticket)
            XCTFail("Expected error, but got success")
        } catch HelpBridgeError.httpError(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Expected HTTP error, but got \(error)")
        }
    }
    
    // MARK: - Test for No Internet Connection Error (Completion Handler)
    func testSubmitSupportTicket_NoInternetCompletion() throws {
        let ticket = SupportTicket(name: "John Doe", email: "john@example.com", type: "2", subject: "Test", message: "Test message")
        
        MockURLProtocol.requestHandler = { request in
            throw NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        }
        
        let expectation = self.expectation(description: "Submit support ticket no internet")
        
        service.submitSupportTicket(ticket) { result in
            switch result {
            case .success:
                XCTFail("Expected error, but got success")
            case .failure(let error):
                XCTAssertEqual(error, .noInternetConnection)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Test for No Internet Connection Error (Async/Await)
    @available(macOS 12.0, iOS 15.0, *)
    func testSubmitSupportTicket_NoInternetAsync() async throws {
        let ticket = SupportTicket(name: "John Doe", 
                                   email: "john@example.com",
                                   type: "2",
                                   subject: "Test",
                                   message: "Test message")
        
        MockURLProtocol.requestHandler = { request in
            throw NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        }
        
        do {
            try await service.submitSupportTicket(ticket)
            XCTFail("Expected error, but got success")
        } catch HelpBridgeError.noInternetConnection {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected no internet connection error, but got \(error)")
        }
    }
}

