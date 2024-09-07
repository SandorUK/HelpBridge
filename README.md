# HelpBridge

**HelpBridge** is a Swift package that simplifies the process of submitting support tickets to multiple helpdesk systems via API. Initially designed for UVDesk, this package can be extended to support other systems like Azure DevOps in the future.

## Features

- Submit support tickets to helpdesk platforms via API.
- Supports both `async`/`await` and completion handler-based API requests.
- Handles common networking issues such as timeouts and lack of internet connection.
- Easily configurable base URL via environment variables or explicit initialization.

## Installation

### Swift Package Manager (SPM)

Add HelpBridge as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-repository/HelpBridge.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["HelpBridge"]
)
```

## Configuration

### Environment Variable

You can configure the base URL using an environment variable:

```
export HELPBRIDGE_BASE_URL=https://support.your-helpdesk.com
```

Alternatively, you can pass the base URL directly during initialization.

## Usage

### 1. Import HelpBridge

```swift
import HelpBridge
```

### 2. Define a Support Ticket

Create a `SupportTicket` object with the required fields:

```swift
let ticket = SupportTicket(
    name: "John Doe",
    email: "johndoe@example.com",
    type: "2", // This can be the type of ticket you are submitting
    subject: "Issue with the app",
    message: "I'm encountering a bug in the app."
)
```

### 3. Submitting a Ticket

You can submit a support ticket using either a completion handler or the `async`/`await` version.

#### Completion Handler Example

```swift
do {
    let service = try HelpBridgeService(baseURL: "https://support.your-helpdesk.com")
    
    service.submitSupportTicket(ticket) { result in
        switch result {
        case .success:
            print("Support ticket submitted successfully.")
        case .failure(let error):
            handleHelpBridgeError(error)
        }
    }
} catch {
    print("Initialization error: \(error)")
}

func handleHelpBridgeError(_ error: HelpBridgeError) {
    switch error {
    case .missingBaseURL:
        print("Error: HelpBridge base URL not set.")
    case .noInternetConnection:
        print("No Internet connection. Please reconnect and try again.")
    case .timeout:
        print("Request timed out. Please try again later.")
    case .httpError(let statusCode):
        print("HTTP Error: \(statusCode). Could not submit the ticket.")
    case .networkError(let message):
        print("Network error: \(message)")
    case .ticketSubmissionFailed:
        print("Ticket submission failed for unknown reasons.")
    }
}
```

#### Async/Await Example

```swift
@available(macOS 12.0, iOS 15.0, *)
func submitTicketAsync() async {
    do {
        let service = try HelpBridgeService(baseURL: "https://support.your-helpdesk.com")
        let ticket = SupportTicket(
            name: "John Doe",
            email: "johndoe@example.com",
            type: "2",
            subject: "Issue with the app",
            message: "I'm encountering a bug in the app."
        )
        
        try await service.submitSupportTicket(ticket)
        print("Support ticket submitted successfully.")
    } catch HelpBridgeError.missingBaseURL {
        print("Error: HelpBridge base URL not set.")
    } catch HelpBridgeError.noInternetConnection {
        print("No Internet connection. Please reconnect and try again.")
    } catch HelpBridgeError.timeout {
        print("Request timed out. Please try again later.")
    } catch HelpBridgeError.httpError(let statusCode) {
        print("HTTP Error: \(statusCode). Could not submit the ticket.")
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

### Error Handling

Errors are handled through the `HelpBridgeError` enum. This enum covers common network errors, HTTP errors, and more:

- `.missingBaseURL`: Base URL not provided.
- `.networkError(message: String)`: General network error with a message.
- `.httpError(statusCode: Int)`: Non-200 HTTP status codes.
- `.noInternetConnection`: No internet connection.
- `.timeout`: Request timed out.
- `.ticketSubmissionFailed`: Ticket submission failed for unknown reasons.

## License

HelpBridge is licensed under the MIT License.

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

