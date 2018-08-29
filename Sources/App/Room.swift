import Vapor
import Foundation

//struct Record:Codable {
//    let username:String
//    let message:String
//}

class Room {
    var connections: [String: WebSocket]
    var messages:[Chatdata]
    let lockObj = NSObject()

    func bot(_ message: String) {
        send(name: "Bot", messageStr: message)
    }

    func send(name: String, messageStr: String?, num: Int = 0, ws:WebSocket? = nil ) {
    
    
        objc_sync_enter(lockObj)
    
        if num  == 0 {
    
            let message:String? = messageStr!.truncated(to: 256)

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
                  try? socket.send(json)
              }
            } catch {
              print(error.localizedDescription)
            }
        
        } else {
                    if messages.count > num {
                      for idx in (num)...(messages.count-1) {
                        var msg = messages[idx]
                        if msg.username != name {
                          msg.message = msg.message!.truncated(to: 256)
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
        
        objc_sync_exit(lockObj)

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
