// swift-tools-version:5.3

// Copyright 2020 Michael F. Collins, III
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy
// of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

import PackageDescription

let package = Package(
    name: "SwiftOpenSSL",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SwiftOpenSSL",
            targets: ["libcrypto", "libssl"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "libcrypto",
            path: "lib/libcrypto.xcframework"
        ),
        .binaryTarget(
            name: "libssl",
            path: "lib/libssl.xcframework"
        )
    ]
)
