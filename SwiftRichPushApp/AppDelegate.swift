//
//  AppDelegate.swift
//  SwiftRichPushApp
//
//  Created by Ikeda Natsumo on 2016/12/08 (update on 2020/03/23).
//  Copyright 2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
//

import UIKit
import NCMB
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    // APIキーの設定
    let applicationkey = "YOUR_NCMB_APPLICATIONKEY"
    let clientkey      = "YOUR_NCMB_CLIENTKEY"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // SDKの初期化
        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey)
        
        // Register notification
        registerForPushNotifications()
        
        // MARK: アプリが起動されるときに実行される処理を追記する場所
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            NCMBPush.handleRichPush(userInfo: notification)
        }
        
        return true
    }
    
    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        let installation = NCMBInstallation()
        installation.setDeviceTokenFromData(data: deviceToken)
        installation.saveInBackground { (error) in
            
        }
    }

    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let notiData = userInfo as? [String : AnyObject] {
            NCMBPush.handleRichPush(userInfo: notiData)
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                granted, error in
                print("Permission granted: \(granted)") // 3
                guard granted else { return }
                self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
}

