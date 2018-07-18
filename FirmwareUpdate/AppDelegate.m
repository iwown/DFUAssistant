//
//  AppDelegate.m
//  FirmwareUpdate
//
//  Created by west on 16/9/19.
//  Copyright © 2016年 west. All rights reserved.
//
#import "FileManager.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "IVRootViewController.h"
#import "DCViewController.h"
#import <YCNetworkLibrary/YCNetworkLibrary.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [YCNetworkSetting shareSetting].baseUrl = @"http://betaapi.iwown.com";
    
    DCViewController *faseVC = [[DCViewController alloc] init];
    faseVC.tabBarItem.title = @"快速升级";
    faseVC.tabBarItem.image=[UIImage imageNamed:@"profile"];
    UINavigationController *navA = [[UINavigationController alloc] initWithRootViewController:faseVC];

    IVRootViewController *rootVC = [[IVRootViewController alloc] init];
    rootVC.tabBarItem.title = @"分类升级";
    rootVC.tabBarItem.image=[UIImage imageNamed:@"device"];
    UINavigationController *navB = [[UINavigationController alloc] initWithRootViewController:rootVC];

    UITabBarController *tb = [[UITabBarController alloc]init];
    tb.viewControllers = @[navA,navB];
    self.window.rootViewController = tb;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark -
#pragma mark Image view

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    UINavigationController *navigation = (UINavigationController *)application.keyWindow.rootViewController;
    ViewController *displayController = (ViewController *)navigation.topViewController;
    NSString *path = [url absoluteString];
    NSMutableString *string = [[NSMutableString alloc] initWithString:path];
    if ([path hasPrefix:@"file://"]) {
        [string replaceOccurrencesOfString:@"file://" withString:@"" options:NSCaseInsensitiveSearch  range:NSMakeRange(0, path.length)];
    }
    [displayController handleUrlString:string];
    
    return YES;
}

#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    UINavigationController *navigation = (UINavigationController *)application.keyWindow.rootViewController;
    ViewController *displayController ;
    for (UIViewController *vc in navigation.viewControllers) {
        if ([vc isKindOfClass:[ViewController class]]) {
            displayController = (ViewController *)vc;
        }
    }
    NSString *path = [url absoluteString];
    NSMutableString *string = [[NSMutableString alloc] initWithString:path];
    if ([path hasPrefix:@"file://"]) {
        [string replaceOccurrencesOfString:@"file://" withString:@"" options:NSCaseInsensitiveSearch  range:NSMakeRange(0, path.length)];
    }
    [displayController handleUrlString:string];
    
    [FileManager createDirWithPath:DirectoryPath];
    NSString *filePathTo = [[DirectoryPath stringByAppendingString:@"/"] stringByAppendingString:[[string componentsSeparatedByString:@"/"] lastObject]];
    [FileManager moveFileFrom:string toAnotherPath:filePathTo];
    
    //获取当前目录下的所有文件
    
    
    //获取一个文件或文件夹
    /*NSString *selectedFile = (NSString*)[directoryContents objectAtIndex: indexPath.row];
    
    //拼成一个完整路径
    [directoryPath stringByAppendingPathComponent: selectedFile];
    
    
    
    [displayController.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
    [displayController.label setText:[options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey]];
    */
    return YES;
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
