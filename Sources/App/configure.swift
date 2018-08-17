//@_exported import Vapor

import Leaf
import Vapor


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    let wss = NIOWebSocketServer.default()  // Vapor3
    
     try routes(router,wss)
//    try routes(router)
    services.register(router, as: Router.self)
    
    services.register(wss, as: WebSocketServer.self)    // Vapor3

    /// Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    
    // for chat
    try config.setup()
    
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
//        Node.fuzzy = [JSON.self, Node.self]   // forVapor3
    }
}

