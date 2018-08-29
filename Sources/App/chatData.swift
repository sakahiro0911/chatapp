//
//  chatData.swift
//  App
//
//  Created by 坂本徹雄 on 2018/08/28.
//

import Foundation

public struct Chatdata: Codable {  // Codableインターフェースを実装する
    public var username: String?
    public var message: String?
    public var num: Int?
}
