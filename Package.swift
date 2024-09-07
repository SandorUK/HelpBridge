// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
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

import PackageDescription

let package = Package(
    name: "HelpBridge",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HelpBridge",
            targets: ["HelpBridge"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HelpBridge"),
        .testTarget(
            name: "HelpBridgeTests",
            dependencies: ["HelpBridge"]),
    ]
)
