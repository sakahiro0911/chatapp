import Vapor
//import Leaf


let room = Room()


/// Register your application's routes here.
public func routes(_ router: Router, _ wss: NIOWebSocketServer ) throws {
    // "It works" page
//    router.get { req in
//        return try req.view().render("welcome")
//    }
//
//    // Says hello
//    router.get("hello", String.parameter) { req -> Future<View> in
//        return try req.view().render("hello", [
//            "name": req.parameters.next(String.self)
//        ])
//    }
    
//    router.get("hello") { req -> Future<View> in
//        return try req.view().render("hello", ["name": "Leaf"])
//    }

    router.get("/") { req in
            return try req.view().render("welcome")
    }
    
   
//   wss.get(at: ["chat"], use: <#T##(WebSocket, Request) throws -> ()#>)
    
    wss.get(at:["chat"], use:{ ws,req in
//        var pingTimer: DispatchSourceTimer? = nil
//        var username: String? = nil
//
//        pingTimer = DispatchSource.makeTimerSource()
//        pingTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(25))
//        pingTimer?.setEventHandler { try? ws.ping() }
//        pingTimer?.resume()
        print("websocket get")
        
       var username: String? = nil
        
//        ws.onText({ (ws, text) in
//            username = ""
//        })
        
        ws.onText({ (ws, text) in
            print("onText=\(text)")
            let data: Data? = text.data(using: .utf8)
//                       let json = try JSONSerialization.jsonObject(with: text!, options: JSONSerialization.ReadingOptions.mutableContainers) as!
            do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let u = (json["username"] as? String) {
                print("username(save)=\(u)")
                username = u
                room.connections[u] = ws
                room.bot("\(u) が参加しました。 👋")
            }
            if let u = username, let m = (json["message"] as? String) {
                print("message=\(m)")
                if m == "disconnect" {
                    room.bot("\(u) が退出しました。")
                    room.connections.removeValue(forKey: u)
                    print("\(u) disconnect")
                    ws.send("disconnect")
                } else {
                  room.send(name: u, message: m)
                }
            }
            } catch {
                print ("json error")
                return
            }
            
            
            
//            let json = try JSON(bytes: text.makeBytes())

//            if let u = json.object?["username"]?.string {
//                username = u
//                room.connections[u] = ws
//                room.bot("\(u) has joined. 👋")
//            }
//
//            if let u = username, let m = json.object?["message"]?.string {
//                room.send(name: u, message: m)
//            }


        })

       
      
        
        ws.onCloseCode({ (code) in
            print("onCloseCode:\(code)")
            guard let u = username else {
                return
            }
            print("close:\(u)")
            room.bot("\(u) が退出しました。")
            room.connections.removeValue(forKey: u)
        })
        
        
        
//        ws.onClose = { ws, _, _, _ in
//            pingTimer?.cancel()
//            pingTimer = nil
//
//            guard let u = username else {
//                return
//            }
//
//            room.bot("\(u) has left")
//            room.connections.removeValue(forKey: u)
//        }

        
    })

    
    
    
    
    
    
    
    
}
