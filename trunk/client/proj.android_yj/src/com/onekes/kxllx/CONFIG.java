package com.onekes.kxllx;


public class CONFIG {
	// 支付宝服务器地址
	public static final String ALIPAY_SERVER_URL = "https://msp.alipay.com/x.htm";
	// 合作商户ID。用签约支付宝账号登录ms.alipay.com后，在账户信息页面获取�?
	public static final String PARTNER = "2088111176646698";
	// 商户收款的支付宝账号
	public static final String SELLER = "2088111176646698";
	// 商户（RSA）私�?
	public static final String RSA_PRIVATE = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALHNQ2VF6N9y5ZYRVzYkuaNk1y2O3XWPNYr/DLnTp03tfBhkPlxa/+wr22lWYrPecNyLIkUUBsIBW/zKkbvef5o129u3lWetelChuAzlKg6SjiGAhHv2Km2BasZrGNlvriW5H4rvaHU9beGDvrZx8NI5IdHRY3Xx+ELJHmvmW64bAgMBAAECgYEAoASiUTTX3rJjWeoFWV84C4un9QKM4U6f25ard1q7SfEgLDubvDbR+VWHRIhQkJzzail2EEFzy4q5pQsSmcgngbvkg0OI4FDqmaqgoALOKt1oNrhRL93NLbE7LUd+EpST99aAgAXVjVRfYjieuY61D9hQXHJsfp87BzWDNGFVLSECQQDfbVnIaIP9Fojg9H8jwINV1vODBhrU2BiGjAH44hdfWl6b/9+0J2OvjlteaA+sEv2VDyZG1A5/iB8197hZLqYTAkEAy7kajn+tVPhhleOZi9frWcyyxne4eF/9HybA5JM7egmS9586bOi8/yS0t6MwCrxfhldHQmcfGp4nKo6BLyh42QJATDHwooXyLUeYGo+HJFws7gNGPHLCh7/CbXAl5AjGy7/379+NHNUqC97SjhmS7q3zSPhHp3P+FcQIUNFQTym3fQJAAplF4XN3fpH8jLDukH4cnnSiAy4byE1RKUiRRVkrdQ8SNN5vHFyLrKWHOKB4SGrGvSv32L0ABJLn5P8UXsmhYQJBAM3yydblVJ9SsP4/MvrkpulcbTWasVua/GhNF5tloKUyfVwKiNOQJvJUqLRgusEJl7wDnEnhFvWFW+mKpoT+lyM=";
	// 支付宝（RSA）公�?用签约支付宝账号登录ms.alipay.com后，在密钥管理页面获取�?
	public static final String RSA_ALIPAY_PUBLIC = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCeAtrNOk0Ihq4+AlQqPzFn/5MEZudvsK7IPUucdNL4r7lCS/JvZmPSbMfHsBPvMWHJhHhUui2FVGxE7EoD2axx37LD0glIvwJdIGCdxm6AZ8zHvS826qYhI1HzzpY2RQHeECyUNs6ZMNTA1c6BmuFq0kQVMl62MPUGtMMR+9dwMwIDAQAB";
	// 支付宝安全支付服务apk的名称，必须与assets目录下的apk名称�?��
	public static final String ALIPAY_PLUGIN_NAME = "alipay_plugin_20120428msp.apk";
	// 支付宝�?知服务器地址
	public static final String NOTIFY_URL = "http://112.124.65.127/api/pay/alipay_notify";
	
	// 微信：替换为你的应用从官方网站申请到的合法appId
    public static final String WX_APP_ID = "wx4ba3a089ed823555";	// 替换为你的应用从官方网站申请到的合法appId
    public static final String WX_PARTNER_ID = "1234350402";	// 商家向财付通申请的商家id
    public static final String WX_PARTNER_KEY = "8934e7d15453e97507ef794cf7b0519d";
    public static final String WX_APP_KEY = "OnekesXM5191370YZX8210501LUXIANG";
    public static final String WX_APP_SECRET = "5acd23e9b60765afcd0138c4a3c8a964"; // wx4ba3a089ed823555 对应的密钥
}
