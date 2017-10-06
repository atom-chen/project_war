/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "CCLuaBridge.h"
#import "Channel.h"
#import "NotifyCenter.h"

@implementation AppController

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;
static AppController* s_appController;
static RootViewController* s_viewController;
static UIActivityIndicatorView* s_loading;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    cocos2d::Application *app = cocos2d::Application::getInstance();
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();

    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                     pixelFormat: (NSString*)cocos2d::GLViewImpl::_pixelFormat
                                     depthFormat: cocos2d::GLViewImpl::_depthFormat
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];

    [eaglView setMultipleTouchEnabled:YES];
    
    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = eaglView;

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    
    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden: YES];

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    s_appController = self;
    s_viewController = viewController;
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    [Channel init:application didFinishLaunchingWithOptions:launchOptions];
    app->run();
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [Channel handle:application
             handleOpenURL:url
                  delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [Channel handle:application
                   openURL:url
         sourceApplication:sourceApplication
                annotation:annotation
                  delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::Director::getInstance()->resume();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
    [NotifyCenter reset];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [Channel alertView:alertView clickedButtonAtIndex:buttonIndex];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
}


- (void)dealloc {
    [super dealloc];
}

+(void)callLuaFunctionWithId:(NSNumber*)funcId param:(NSString*)param {
    NSLog(@"callLuaFunctionWithId -> funcId: %d, param: %s", [funcId intValue], [param UTF8String]);
    if ([funcId intValue] > 0) {
        cocos2d::LuaBridge::pushLuaFunctionById([funcId intValue]);
        cocos2d::LuaBridge::getStack()->pushString([param UTF8String]);
        cocos2d::LuaBridge::getStack()->executeFunction(1);
        cocos2d::LuaBridge::releaseLuaFunctionById([funcId intValue]);
    }
}

+(void)callLuaGlobalFunctionWithName:(NSString*)funcName param:(NSString*)param {
    NSLog(@"callLuaGlobalFunctionWithName -> funcName: %s, param: %s", [funcName UTF8String], [param UTF8String]);
    if (![funcName isEqualToString:@""]) {
        lua_State* state = cocos2d::LuaBridge::getStack()->getLuaState();
        lua_getglobal(state, [funcName UTF8String]);
        if (!lua_isfunction(state, -1)) {
            CCLOG("[LUA ERROR] name '%s' does not represent a Lua function", [funcName UTF8String]);
            lua_pop(state, 1);
            return;
        }
        cocos2d::LuaBridge::getStack()->pushString([param UTF8String]);
        cocos2d::LuaBridge::getStack()->executeFunction(1);
    }
}

+(NSString*)ocProxy:(NSDictionary*)data {
    NSLog(@"ocProxy -> data:\n%s", [[data description] UTF8String]);
    NSNumber* type = [data objectForKey:@"type"];
    NSNumber* handler = [data objectForKey:@"handler"];
    return [Channel handleLua:type
                         data:data
                      handler:handler
                     delegate:self];
}

+(void)showToast:(NSString*)text {
    CGRect screenRect = [UIScreen mainScreen].applicationFrame;
    CGFloat width = 220;
    CGFloat height = 40;
    CGFloat x = screenRect.size.width/2 - width/2;
    CGFloat y = screenRect.size.height - 150;
    UILabel* hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.backgroundColor = [UIColor lightGrayColor];
    hintLabel.layer.masksToBounds = YES;
    hintLabel.layer.cornerRadius = 6.0;
    hintLabel.alpha = 1.0;
    hintLabel.text = text;
    [s_viewController.view addSubview:hintLabel];
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{hintLabel.alpha = 0.0;}
                     completion:^(BOOL finished){
                         [hintLabel removeFromSuperview];
                     }];
}

+(void)showLoading {
    if (nil == s_loading) {
        s_loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        s_loading.frame = CGRectMake(0, 0, 30, 30);
        [s_loading setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2)];
        s_loading.hidesWhenStopped = NO;
        s_loading.color = [UIColor blackColor];
        [s_viewController.view addSubview:s_loading];
        [s_loading startAnimating];
    }
    [s_loading setHidden:FALSE];
    s_viewController.view.userInteractionEnabled = NO;
}

+(void)hideLoading {
    if (s_loading) {
        [s_loading setHidden:TRUE];
    }
    s_viewController.view.userInteractionEnabled = YES;
}

+(void)showAlert:(NSInteger)tag title:(NSString*)title msg:(NSString*)msg cancel:(NSString*)cancel sure:(NSString*)sure {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:msg
                                                    delegate:s_appController
                                           cancelButtonTitle:cancel
                                           otherButtonTitles:nil]
                          autorelease];
    [alert addButtonWithTitle:sure];
    [alert setTag:tag];
    [alert show];
}

@end

