//
//  AppDelegate.swift
//  CATiledLayerDemo
//
//  Created by zhangyinglong on 2017/1/5.
//  Copyright © 2017年 ChinaHR. All rights reserved.
//

import UIKit

let kDestImageSizeMB = CGFloat(60.0) // The resulting image will be (x)MB of uncompressed image data.
let kSourceImageTileSizeMB = CGFloat(20.0)

let bytesPerMB = CGFloat(1048576.0)
let bytesPerPixel = CGFloat(4.0)
let pixelsPerMB = ( bytesPerMB / bytesPerPixel ) // 262144 pixels, for 4 bytes per pixel.
let destTotalPixels = kDestImageSizeMB * pixelsPerMB
let tileTotalPixels = kSourceImageTileSizeMB * pixelsPerMB
let destSeemOverlap = CGFloat(2.0) // the numbers of pixels to overlap the seems where tiles meet.
let defaultTileSize = CGFloat(512.0)

//let ImageFilename = "http://cv.qiaobutang.com/uploads/company_logos/2014/12/12/20/548ae4240cf23e379a82db93/original.png"
//let ImageFilename = "http://bbs.crsky.com/1236983883/Mon_1210/25_187069_02f2a6d8ec0ce0b.jpg"
//let ImageFilename = "original.png"
let ImageFilename = "large_leaves_70mp.jpg"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 裁剪超大分辨率的图片
        let size = CGSize(width: defaultTileSize, height: defaultTileSize)
        UIImage.saveTileOfSize(size, name: ImageFilename)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

