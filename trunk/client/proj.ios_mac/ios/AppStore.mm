#import "AppStore.h"
#import "AppController.h"

@implementation AppStore
NSNumber* mHandler = 0;

+(AppStore*)getInstance {
    static AppStore *sInstance = nil;
    if (nil == sInstance) {
        sInstance = [[AppStore alloc] init];
    }
    return sInstance;
}

-(BOOL)pay:(NSString*)appstoreCode handler:(NSNumber*)handler {
    if ([appstoreCode isEqualToString:@""] || [appstoreCode isEqualToString:@"0"] || [appstoreCode isEqualToString:@"nil"]) {
        NSLog(@"支付失败, App Store 支付码不正确, code = %s", [appstoreCode UTF8String]);
        [AppController showToast:[NSString stringWithFormat:PAY_MSG_001, [appstoreCode UTF8String]]];
        return YES;
    }
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"支付失败, 用户禁止应用内付费购买");
        [AppController showToast:PAY_MSG_002];
        return FALSE;
    }
    // 处理未完成的交易
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    if (transactions.count > 0) {
        SKPaymentTransaction* transaction = [transactions firstObject];
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
            [self completeTransaction:transaction];
            return YES;
        } else if (SKPaymentTransactionStateFailed == transaction.transactionState) {
            [self failedTransaction:transaction];
            return FALSE;
        }
        NSLog(@"支付等待中, 请稍等...");
        [AppController showToast:PAY_MSG_003];
        return FALSE;
    }
    NSLog(@"请求获取产品信息");
    [AppController showLoading];
    mHandler = handler;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    NSSet* productIdentifiers = [NSSet setWithObject:appstoreCode];
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
    return YES;
}

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response {
    if (0 == [response.products count]) {
        NSLog(@"支付失败, 无法获取产品信息");
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
        [AppController callLuaFunctionWithId:mHandler param:@"fail"];
        [AppController showToast:PAY_MSG_004];
        [AppController hideLoading];
        mHandler = 0;
        return;
    }
    NSLog(@"产品信息获取成功, 请求购买");
    // 发送购买商品请求
    SKPayment* payment = [SKPayment paymentWithProduct:response.products[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions {
    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:    // 交易完成
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:       // 交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:     // 交易恢复
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction*)transaction {
    NSLog(@"支付成功");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [AppController callLuaFunctionWithId:mHandler param:@"success"];
    [AppController showToast:PAY_SUCCESS_MSG];
    [AppController hideLoading];
    mHandler = 0;
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction {
    if (SKErrorPaymentCancelled == transaction.error.code) {
        NSLog(@"支付取消");
        [AppController callLuaFunctionWithId:mHandler param:@"cancel"];
        [AppController showToast:PAY_CANCES_MSG];
    } else {
        NSLog(@"支付失败");
        [AppController callLuaFunctionWithId:mHandler param:@"fail"];
        [AppController showToast:PAY_FAIL_MSG];
    }
    [AppController hideLoading];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    mHandler = 0;
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
