// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "chatapp",
    
    
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.8"),

        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        
        // .package(url: "https://github.com/vapor/json.git", from: "2.2.2"),
        // .package(url: "https://github.com/vapor/node.git", from: "2.1.5"),
         
//         .package(url: "https://github.com/vapor/websocket.git", from: "1.0.1"),
        
    ],
    targets: [
        .target(name: "App", dependencies: ["Leaf", "Vapor"],exclude: ["Config","Database","Public","Resources"]),
        .target(name: "Run", dependencies: ["App"],exclude: ["Config","Database","Public","Resources"]),
        .testTarget(name: "AppTests", dependencies: ["App"],exclude: ["Config","Database","Public","Resources"])
    ]
 
)

