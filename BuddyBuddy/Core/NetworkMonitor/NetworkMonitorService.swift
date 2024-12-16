//
//  NetworkMonitorService.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 12/12/24.
//

import UIKit
import Network

protocol NetworkMonitorInterface: AnyObject {
    func startMonitoring()
    func stopMonitoring()
}

final class NetworkMonitorService: NetworkMonitorInterface {
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            switch path.status {
            case .satisfied:
                print("연결 O")
                self.dismissNetworkWindow()
            case .unsatisfied:
                print("연결 X")
                self.showNetworkWindow()
            default:
                print("연결 X")
                self.showNetworkWindow()
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func showNetworkWindow() {
        /// 네트워크 끊겼을 때 보내는 Notification
        NotificationCenter.default.post(
            name: .networkDisconnected,
            object: nil
        )
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let networkWindow = NetworkWindow(windowScene: windowScene)
                networkWindow.makeKeyAndVisible()
                
                let sceneDelegate = windowScene.delegate as? SceneDelegate
                sceneDelegate?.networkWindow = networkWindow
            }
        }
    }
    
    private func dismissNetworkWindow() {
        /// 네트워크 돌아왔을 때 보내는 Notification
        NotificationCenter.default.post(
            name: .networkConnected,
            object: nil
        )
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let sceneDelegate = windowScene.delegate as? SceneDelegate
                sceneDelegate?.networkWindow = nil
            }
        }
    }
}
