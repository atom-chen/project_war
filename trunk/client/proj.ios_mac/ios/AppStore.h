#import <StoreKit/StoreKit.h>

@interface AppStore : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

+(AppStore*)getInstance;

-(BOOL)pay:(NSString*)appstoreCode handler:(NSNumber*)handler;

@end
