import Vapor
import Foundation

//import Leaf


let room = Room()


//struct Chatdata: Codable {  // Codableインターフェースを実装する
//    let username: String?
//    let message: String?
//    let num: Int?
//}



/// Register your application's routes here.
public func routes(_ router: Router, _ wss: NIOWebSocketServer ) throws {

    


    router.get("/") { req in
         return try req.view().render("welcome")
    }
    
    

   
    
    wss.get(at:["chat"], use:{ ws0,req in
        
        
//        var eventHandler: (() -> Void)?
        
//        var pingTimer: DispatchSourceTimer? = nil

        print("websocket get")

        var username: String? = nil
        
        
        ws0.onText({ (ws, text) in
                        
            let data: Data? = text.data(using: .utf8)
            
          
            do {	// 例外Catch
            let json = try! JSONDecoder().decode(Chatdata.self, from: data!)
                
            
            if let u = json.username {
                print("username(save)=\(u)")
                username = u
                room.connections.removeValue(forKey: u)//★★★★★★★★★
                if let num = json.num { // 初回はnumが入らないようにJSを制御
                  room.send(name: u, messageStr: nil, num:num+1, ws:ws)
                
                
                
//                    if room.messages.count > num+1 {
//                      for idx in (num+1)...(room.messages.count-1) {
//                        var msg = room.messages[idx]
//                        // 自分以外のメッセージを再送
//                        if msg.username != u {
//                          msg.message = msg.message.truncated(to: 256)
//                          let encoder = JSONEncoder()
//                          do {
//                            let senddata = try encoder.encode(msg)
//                            let json:String = String(data: senddata, encoding: .utf8)!
//                            print("jsonstr=\(json)")
//                            try? ws.send(json)
//                          } catch {
//                              print(error.localizedDescription)
//                          }
//                        }
//                      }
//                    }
                    
                    
                        
            
                }
                room.connections[u] = ws	//★★★★★★★★★
                room.bot("\(u) が参加しました。 👋")

                        // messagesの排他制御は？？？？★★★★★★★★★★★★★★★★★★★★★★★★★再送中に別の人が送ろうとした場合
                
//                pingTimer?.setEventHandler {}
//                pingTimer?.cancel()
//                eventHandler = nil
//                pingTimer = nil
                
//                pingTimer = DispatchSource.makeTimerSource()
//                pingTimer?.schedule(deadline: .now(), repeating: .seconds(30))  //, leeway:  .seconds(25))
//                eventHandler =  {
//                    ws.send("__ping__")
//                    print("__ping__")
//                }
                //        pingTimer?.setEventHandler { try? ws.ping() }    ★ws.send("__ping__")
//                pingTimer?.setEventHandler(handler: {
//                    eventHandler?()
//                })

//                pingTimer?.resume()
//                print("websocket timer start")

            }
//            print("username(curent)=\(username)")
            if let u = username, let m = json.message {
                print("message=\(m)")
                if m == "disconnect" {
                    room.bot("\(u) が退出しました。")
                    room.connections.removeValue(forKey: u)
                    print("\(u) disconnect")
//                    pingTimer?.setEventHandler {}
//                    pingTimer?.cancel()
                    //                    pingTimer?.resume()
//                    eventHandler = nil
//                    pingTimer = nil
                    ws.send("disconnect")
                } else if  m == "__pong__" {
                    print("\(u) pong")
                } else {
                  room.send(name: u, messageStr: m)
                }
            }
            } catch {	// 例外Catch
                ws.send("json error:\(error)")
                print ("json error")
                return
            }
            
            
            

        })

       
      
        
        ws0.onCloseCode({ (code) in
            print("onCloseCode:\(code)")
//            pingTimer?.setEventHandler {}
//            pingTimer?.cancel()
            //                    pingTimer?.resume()
//            eventHandler = nil
//            pingTimer = nil
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
//            ws.send("{'message':\(err.localizedDescription)}")
        })


        
    })


    
    
}
