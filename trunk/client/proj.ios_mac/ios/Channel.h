@interface Channel : NSObject

+(BOOL)init:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions;

+(BOOL)handle:(UIApplication*)application handleOpenURL:(NSURL*)url delegate:(id)delegate;

+(BOOL)handle:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation delegate:(id)delegate;

+(NSString*)handleLua:(NSNumber*)type data:(NSDictionary*)data handler:(NSNumber*)handler delegate:(id)delegate;

+(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

