#import "Channel.h"
#import "AppController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MobClick.h"
#import "MobClickGameAnalytics.h"
#import "ShareSDK/ShareSDK.h"
#import "WXApi.h"
#import "FacebookConnection/ISSFacebookApp.h"
#import "AppStore.h"
#import "NotifyCenter.h"

@implementation Channel

+(BOOL)init:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [MobClick setLogEnabled:YES];
    [MobClick setAppVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [MobClick startWithAppkey:@"559a284e67e58e563c0016b4" reportPolicy:REALTIME channelId:CHANNEL_ID];
    [ShareSDK registerApp:@"5d44c06f45d0"];
    if ([@"20001" isEqual:CHANNEL_ID]) {           // 自有中文,微信
        [ShareSDK connectWeChatTimelineWithAppId:@"wx499b4372c2483e58"
                                       appSecret:@"8a31a10e005f6cb2669cc00ca8de1c8a"
                                       wechatCls:[WXApi class]];
    } else if ([@"20002" isEqual:CHANNEL_ID]) {    // 自有英文,Facebook
        [ShareSDK connectFacebookWithAppKey:@"1457615714529785"
                                  appSecret:@"eafd4ac1c9ee0ee823798ca0d69e37cb"];
        id<ISSFacebookApp> facebookApp = (id<ISSFacebookApp>)[ShareSDK getClientWithType:ShareTypeFacebook];
        [facebookApp setIsAllowWebAuthorize:YES];
    }
    return YES;
}

+(BOOL)handle:(UIApplication*)application handleOpenURL:(NSURL*)url delegate:(id)delegate {
    return [ShareSDK handleOpenURL:url
                        wxDelegate:delegate];
}

+(BOOL)handle:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation delegate:(id)delegate {
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:delegate];
}

+(NSString*)handleLua:(NSNumber*)type data:(NSDictionary*)data handler:(NSNumber*)handler delegate:(id)delegate {
    switch ([type intValue]) {
        case 101: {     // get mac address
            NSString* ssid = @"Not Found";
            NSString* macIp = @"Not Found";
            CFArrayRef myArray = CNCopySupportedInterfaces();
            if (nil != myArray) {
                CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFStringRef(CFArrayGetValueAtIndex(myArray, 0)));
                if (nil != myDict) {
                    NSDictionary* dict = (NSDictionary*)CFBridgingRelease(myDict);
                    ssid = [dict valueForKey:@"SSID"];
                    macIp = [dict valueForKey:@"BSSID"];
                    return macIp;
                }
            }
            return @"";
        }
        case 102: {     // get sim state
            return @"SIM_UNKNOWN";
        }
        case 103: {     // get channel id
            return CHANNEL_ID;
        }
        case 104: {     // get device id
            NSString* deviceID = @"";
            Class cls = NSClassFromString(@"UMANUtil");
            SEL deviceIDSelector = @selector(openUDIDString);
            if (cls && [cls respondsToSelector:deviceIDSelector]) {
                deviceID = [cls performSelector:deviceIDSelector];
            }
            return deviceID;
        }
        case 105: {     // get bundle version
            return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        }
		case 106:		// get goods info list
			break;
		case 107:		// get resupply order list
			break;
		case 108:		// get operator type
			break;
		case 109:		// get is sound on
			break;
		case 201:		// register
			break;
		case 202:		// login
			break;
		case 203:		// logout
			break;
        case 204: {		// pay
            [[AppStore getInstance]pay:[data objectForKey:@"ascode"] handler:handler];
            break;
        }
        case 205: {     // share
            NSString* shareContent = [data objectForKey:@"share_content"];
            NSString* shareURL = [data objectForKey:@"share_url"];
            NSString* sharePicture = [data objectForKey:@"share_pic"];
            ShareType shareType = ShareTypeAny;
            if ([@"20001" isEqual:CHANNEL_ID]) {            // 自有中文
                shareType = ShareTypeWeixiTimeline;
            } else if ([@"20002" isEqual:CHANNEL_ID]) {     // 自有英文
                shareType = ShareTypeFacebook;
                shareContent = [shareContent stringByAppendingFormat:@" %@\n", shareURL];
            }
            SSPublishContentMediaType mediaType = SSPublishContentMediaTypeImage;
            if ([sharePicture isEqualToString:@""]) {
                sharePicture = [[NSBundle mainBundle] pathForResource:@"Icon-180" ofType:@"png"];
                mediaType = SSPublishContentMediaTypeNews;
            }
            id<ISSContent> publishContent = [ShareSDK content:shareContent
                                               defaultContent:shareContent
                                                        image:[ShareSDK imageWithPath:sharePicture]
                                                        title:shareContent
                                                          url:shareURL
                                                  description:shareContent
                                                    mediaType:mediaType];
            [ShareSDK showShareViewWithType:shareType
                                  container:nil
                                    content:publishContent
                              statusBarTips:YES
                                authOptions:nil
                               shareOptions:nil
                                     result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    if (SSResponseStateSuccess == state) {
                                        NSLog(NSLocalizedString(@"TEXT_ShARE_SUCCESS", @"分享成功"));
                                        [AppController callLuaFunctionWithId:handler param:@"success"];
                                        [AppController showToast:SHARE_SUCCESS_MSG];
                                    } else if (SSResponseStateFail == state) {
                                        NSLog(NSLocalizedString(@"TEXT_ShARE_FAIL", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                        [AppController callLuaFunctionWithId:handler param:@"fail"];
                                        [AppController showToast:[NSString stringWithFormat:SHARE_FAIL_MSG, (int)[error errorCode], [error errorDescription]]];
                                    } else if (SSResponseStateCancel == state) {
                                        NSLog(NSLocalizedString(@"TEXT_ShARE_CANCEL", @"分享取消"));
                                        [AppController callLuaFunctionWithId:handler param:@"cancel"];
                                        [AppController showToast:SHARE_CANCEL_MSG];
                                    }
                                }];
            break;
        }
        case 206: {     // record
			NSNumber* tag = [data objectForKey:@"tag"];
			switch ([tag intValue]) {
				case 1:		// custom event
					[MobClick event:[data objectForKey:@"event"]];
                    break;
				case 2: {	// custom event with value
					NSString* event = @"";
					NSMutableDictionary* map = [[NSMutableDictionary alloc] init];
					NSArray* keys = [data allKeys];
					for (int i=0; i<[keys count]; i++) {
						NSString* key = [NSString stringWithFormat:@"%@", [keys objectAtIndex:i]];
						NSString* value = [NSString stringWithFormat:@"%@", [data objectForKey:key]];
						if ([key isEqualToString:@"event"]) {
							event = value;
						} else if (![key isEqualToString:@"type"] && ![key isEqualToString:@"handler"] && ![key isEqualToString:@"tag"]) {
							[map setObject:value forKey:key];
						}
					}
					if (![event isEqualToString:@""]) {
						[MobClick event:event attributes:map];
					}
					break;
				}
				case 3: {	// pay event
					double cash = [[data objectForKey:@"cash"] doubleValue];
					int source = [[data objectForKey:@"source"] intValue];
					NSString* item = [data objectForKey:@"item"];
					int amount = [[data objectForKey:@"amount"] intValue];
					double price = [[data objectForKey:@"price"] doubleValue];
					[MobClickGameAnalytics pay:cash source:source item:item amount:amount price:price];
					break;
				}
				case 4:		// level start event
					[MobClickGameAnalytics startLevel:[data objectForKey:@"level"]];
					break;
				case 5:		// level finish event
					[MobClickGameAnalytics finishLevel:[data objectForKey:@"level"]];
					break;
				case 6:		// level fail event
					[MobClickGameAnalytics failLevel:[data objectForKey:@"level"]];
					break;
				default:
					break;
			}
            break;
        }
		case 207:		// more game
			break;
		case 208:		// app page
			[AppController showAlert:1 title:@"" msg:REAMRK_MSG cancel:REAMARK_NO sure:REAMRK_YES];
			break;
		case 209:		// show about
			break;
		case 301:		// kill game
			break;
		case 302: {		// copy string
            NSString* str = [data objectForKey:@"str"];
            if (!str || 0 == [str length]) {
                CFStringRef strRef = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
                CFRelease(strRef);
                str = [(NSString*)strRef autorelease];
            }
            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = str;
            break;
        }
        case 303: {		// register notify
            [NotifyCenter regist];
            break;
        }
        case 304: {     // add notify
            NSNumber* notifyType = [data objectForKey:@"notify_type"];
            NSNumber* notifyKey = [data objectForKey:@"notify_key"];
            NSString* notifyMsg = [data objectForKey:@"notify_msg"];
            NSNumber* notifyDelay = [data objectForKey:@"notify_delay"];
            [NotifyCenter add:notifyType key:notifyKey msg:notifyMsg delay:notifyDelay];
            break;
        }
        case 305: {     // remove notify by type
            [NotifyCenter removeType:[data objectForKey:@"notify_type"]];
            break;
        }
        case 306: {     // remove notify by key
            [NotifyCenter removeKey:[data objectForKey:@"notify_key"]];
            break;
        }
        case 307: {     // clear notify
            [NotifyCenter clear];
            break;
        }
        default:
            break;
    }
    return @"";
}

+(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView -> tag:%ld, buttonIndex:%ld", (long)[alertView tag], (long)buttonIndex);
    switch ([alertView tag]) {
        case 1: {
            if (1 == buttonIndex) {
                NSString* str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", @"1015754316"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            }
            break;
        }
        default:
        break;
    }
}

@end

