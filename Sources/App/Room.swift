import Vapor


struct Record:Codable {
    let username:String
    let message:String
}

class Room {
    var connections: [String: WebSocket]

    func bot(_ message: String) {
        send(name: "Bot", message: message)
    }

    func send(name: String, message: String) {
        let message = message.truncated(to: 256)

        let record = Record( username:name,message:message)
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
        
        
//        let messageNode: [String: NodeRepresentable] = [
//            "username": name,
//            "message": message
//        ]
//
//        guard let json = try? JSON(node: messageNode) else {
//            return
//        }

//        for (username, socket) in connections {
//            guard username != name else {
//                continue
//            }
//
//            try? socket.send(json)
//        }
    }

    init() {
        connections = [:]
    }
}
