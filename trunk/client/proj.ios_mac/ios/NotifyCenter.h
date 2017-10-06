#import <Foundation/Foundation.h>

@interface NotifyCenter : NSObject

// 注册推送通知功能
+(void)regist;

// 添加通知,type:通知类型,key:通知关键字,msg:通知文本,delay:延迟时间(秒)
+(void)add:(NSNumber*)type key:(NSNumber*)key msg:(NSString*)msg delay:(NSNumber*)delay;

// 删除通知,type:通知类型
+(void)removeType:(NSNumber*)type;

// 删除通知,key:通知关键字
+(void)removeKey:(NSNumber*)key;

// 清除通知
+(void)clear;

// 重置通知数量
+(void)reset;

@end
