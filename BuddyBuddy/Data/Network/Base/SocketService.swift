//
//  SocketService.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/20/24.
//

import Foundation

import RxCocoa
import SocketIO

final class SocketService: SocketProtocol {
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    private var url = URL(string: APIKey.baseURL)
    
    private let decoder = JSONDecoder()
    private let dmEventRelay = PublishRelay<DMHistoryDTO>()
    private let channelEventRelay = PublishRelay<ChannelHistoryResponseDTO>()
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: NSNotification.Name("didEnterBackground"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: NSNotification.Name("willEnterForeground"), 
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkConnected),
            name: .networkConnected,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkDisconnected),
            name: .networkDisconnected,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateURL(ID: String) {
        guard let url else { return }
        manager = SocketManager(
            socketURL: url,
            config: [.log(true), .compress]
        )
        socket = manager.socket(forNamespace: "/ws-dm-\(ID)")
        socket.on(clientEvent: .connect) { data, ack in
            print("SOCKET IS CONNECTED", data, ack)
        }
    
        socket.on(clientEvent: .disconnect) { data, ack in
            print("SOCKET IS DISCONNECTED", data, ack)
        }
        
        receiveDMMessage()
        receiveChannelMessage()
    }
    
    func establishConnection() {
        guard let url = url else {
            print("Error: URL is nil")
            return
        }
        if manager == nil {
            manager = SocketManager(
                socketURL: url,
                config: [.log(true), .compress]
            )
        }
        if let socket = socket, socket.status != .connected {
            socket.connect()
            print("socket is connected")
        } else {
            print("Error: Socket is nil")
        }
    }
    
    func closeConnection() {
        socket.disconnect()
        print("socket is disconnected")
    }
    
    func receiveDMMessage() {
        socket.on("dm") { [weak self] datadict, _ in
            guard let self, let data = datadict[0] as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let result = try self.decoder.decode(
                    DMHistoryDTO.self,
                    from: jsonData
                )
                dmEventRelay.accept(result)
            } catch {
                print(error)
            }
        }
    }
    
    func receiveChannelMessage() {
        socket.on("channel") { [weak self] datadict, _ in
            guard let self, let data = datadict[0] as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let result = try self.decoder.decode(
                    ChannelHistoryResponseDTO.self,
                    from: jsonData
                )
                channelEventRelay.accept(result)
            } catch {
                print(error)
            }
        }
    }
    
    func observeDMMessage() -> PublishRelay<DMHistoryDTO> {
        return dmEventRelay
    }
    
    func observeChannelMessage() -> PublishRelay<ChannelHistoryResponseDTO> {
        return channelEventRelay
    }
    
    @objc private func didEnterBackground() {
        closeConnection()
    }
    
    @objc private func willEnterForeground() {
        establishConnection()
    }
    
    @objc private func networkDisconnected() {
        if let socket = socket {
            closeConnection()
            print("socket is disconnected")
        } else {
            print("Error: Socket is nil")
        }
    }
    
    @objc private func networkConnected() {
        establishConnection()
    }
}
