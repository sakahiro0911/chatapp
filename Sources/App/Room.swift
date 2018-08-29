import Vapor
import Foundation

//struct Record:Codable {
//    let username:String
//    let message:String
//}

class Room {
    var connections: [String: WebSocket]
    var messages:[Chatdata]
    let lock = NSLock()


    func bot(_ message: String) {
        send(name: "Bot", messageStr: message)
    }

    func send(name: String, messageStr: String?, num: Int = 0, ws:WebSocket? = nil ) {
    
    
        self.lock.lock()
        defer { self.lock.unlock() }
    
        if num  == 0 {
    
//            let message:String? = messageStr!.truncated(to: 256)
            var message = messageStr
            if messageStr!.count > 256 {
              let idx = messageStr!.index(messageStr!.startIndex, offsetBy: 256)
              message = String(messageStr![..<idx])
            }
            
            var record = Chatdata(username:name,message:message,num:nil)
            record.num = messages.count
            messages.append(record)
            let encoder = JSONEncoder()
            do {
              let data = try encoder.encode(record)
              let json:String = String(data: data, encoding: .utf8)!
              print("jsonstr=\(json)")
              for (username, socket) in connections {
                  guard username != name else {
                      continue
                  }
                  print("to:\(username)")
                  socket.send(json)
              }
            } catch {
              print(error.localizedDescription)
            }
        
        } else {
                    if messages.count > num {
                      for idx in (num)...(messages.count-1) {
                        var msg = messages[idx]
                        if msg.username != name {
//                          msg.message = msg.message!.truncated(to: 256)
                          let idx = msg.message!.index(msg.message!.startIndex, offsetBy: 256)
                          let message2 = String(msg.message![..<idx])
                          msg.message = message2
                          do {
                            let encoder = JSONEncoder()
                            let senddata = try encoder.encode(msg)
                            let json:String = String(data: senddata, encoding: .utf8)!
                            print("jsonstr=\(json)")
                            ws?.send(json)
                          } catch {
                            print(error.localizedDescription)
                            }
                        }
                      }
                    }
        
        
        }
        
        

    }

    init() {
        print("room init")
        connections = [:]
        messages = []
    }
    
    deinit {
        print("room delnit")
    }
}
