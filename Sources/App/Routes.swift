import Vapor
import Foundation

//import Leaf


let room = Room()


struct Chatdata: Codable {  // Codableインターフェースを実装する
    let username: String?
    let message: String?
}

//extension WebSocket {
    //    public func optSend(_ data: LosslessDataConvertible, opcode: WebSocketOpcode, promise: Promise<Void>?) {
//        send(data, opcode: opcode, promise: promise)
//       
//    }
//}

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
    
    
//    router.websocket("foo") { (req, ws) in
//        ws.onString { websocket, string in
//            websocket.send(string: string)
//        }
//    }

    
    
   
//   wss.get(at: ["chat"], use: <#T##(WebSocket, Request) throws -> ()#>)
    
    wss.get(at:["chat"], use:{ ws0,req in
        
//        var ww:WebSocket  = ws0
        
        var eventHandler: (() -> Void)?
        
        
        var pingTimer: DispatchSourceTimer? = nil
////        var username: String? = nil

//        pingTimer = DispatchSource.makeTimerSource()
//        pingTimer?.schedule(deadline: .now(), repeating: .seconds(25))  //, leeway:  .seconds(25))
////        eventHandler =  {
////            ws.send("__ping__")
////            print("__ping__")
////        }
////        pingTimer?.setEventHandler { try? ws.ping() }    ★ws.send("__ping__")
////        pingTimer?.setEventHandler(handler: {
////            eventHandler?()
////        })
//        pingTimer?.setEventHandler {
//            ws.send("__ping__")
//            print("__ping__")
//        }
//        pingTimer?.resume()
        print("websocket get")

       var username: String? = nil
        
//        ws.onText({ (ws, text) in
//            username = ""
//        })
        
        ws0.onText({ (ws, text) in
                        
//            ws.send("\(text)")
//          do {
            
//            print("onText=\(text)")
            let data: Data? = text.data(using: .utf8)
            
          
//                       let json = try JSONSerialization.jsonObject(with: text!, options: JSONSerialization.ReadingOptions.mutableContainers) as!
            do {
//            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
//
                let json = try! JSONDecoder().decode(Chatdata.self, from: data!)
                
//                ws.send("json name:\(json.username)")
            
//             if let u = (json["username"] as? String) {
            if let u = json.username {
                print("username(save)=\(u)")
                username = u
//                room.connections[u] = ws
                 room.connections[u] = ws0
                room.bot("\(u) が参加しました。 👋")
                
                
                pingTimer?.setEventHandler {}
                pingTimer?.cancel()
                eventHandler = nil
                pingTimer = nil
                
                
                
                
                pingTimer = DispatchSource.makeTimerSource()
                pingTimer?.schedule(deadline: .now(), repeating: .seconds(20))  //, leeway:  .seconds(25))
                eventHandler =  {
                    ws.send("__ping__")
                    print("__ping__")
                }
                //        pingTimer?.setEventHandler { try? ws.ping() }    ★ws.send("__ping__")
                pingTimer?.setEventHandler(handler: {
                    eventHandler?()
                })
                //        pingTimer?.setEventHandler {
                //            ws.send("__ping__")
                //            print("__ping__")
                //        }
                pingTimer?.resume()
                print("websocket timer start")

                
                
                
            }
//            if let u = username, let m = (json["message"] as? String) {
            print("username(curent)=\(username)")
            if let u = username, let m = json.message {
                print("message=\(m)")
                if m == "disconnect" {
                    room.bot("\(u) が退出しました。")
                    room.connections.removeValue(forKey: u)
                    print("\(u) disconnect")
                    pingTimer?.setEventHandler {}
                    pingTimer?.cancel()
                    //                    pingTimer?.resume()
                    eventHandler = nil
                    pingTimer = nil
                    ws.send("disconnect")
                } else if  m == "__pong__" {
                    print("\(u) pong")
                } else {
                  room.send(name: u, message: m)
                }
            }
          } catch {
                ws.send("json error:\(error)")
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

       
      
        
        ws0.onCloseCode({ (code) in
            print("onCloseCode:\(code)")
            pingTimer?.setEventHandler {}
            pingTimer?.cancel()
            //                    pingTimer?.resume()
            eventHandler = nil
            pingTimer = nil
//            guard let u = username else {
//                return
//            }
//            print("close:\(u)")
//            room.bot("\(u) が退出しました。")
//            room.connections.removeValue(forKey: u)
        })
        
        ws0.onError({ (ws, err) in
            print(err.localizedDescription)
            room.bot("err: \(err.localizedDescription)")
            ws.send("{'message':\(err.localizedDescription)}")
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
