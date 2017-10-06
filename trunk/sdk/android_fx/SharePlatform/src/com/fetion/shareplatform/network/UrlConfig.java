package com.fetion.shareplatform.network;

public class UrlConfig {
	
	/**认证的url**/
	public static final String IFEIXIN_OAUTH_URL = "https://i.feixin.10086.cn/oauth2/authorize?";
//	public static final String IFEIXIN_OAUTH_URL = "https://i.fx-func.com/oauth2/authorize?";
	
	/**支付的url**/
	public static final String IFEIXIN_PAY_URL = "https://i.feixin.10086.cn/api/payorder?";
	
	/**订单查询url**/
	public static final String IFEIXIN_ORDER_QUERY_URL = "https://i.feixin.10086.cn/api/orderquery?";
//	public static final String IFEIXIN_ORDER_QUERY_URL = "https://i.fx-func.com/api/orderquery?";
	
	/**获取access token的url**/
	public static final String IFEIXIN_ACCESSTOKEN_URL = "https://i.feixin.10086.cn/oauth2/access_token?";
//	public static final String IFEIXIN_ACCESSTOKEN_URL = "https://i.fx-func.com/oauth2/access_token?";
	
	/**认证的回访url，用以接受token**/
	public static final String IFEIXIN_OAUTH_REDIRECT_URL = "http://shareplateformsdk.com";
	
	/**同窗API的baseurl**/
	public static final String IFEIXIN_API_BASE_URL = "http://i.feixin.10086.cn/api";
//	public static final String IFEIXIN_API_BASE_URL = "https://i.fx-func.com/api/user";
	
	/**请求短链地址**/
//	public static final String IFEIXIN_SHORT_URL = "http://i.fx-func.com/api/sdktinyurl";
	
	/**登录请求地址**/
	public static final String IFEIXIN_AUTOLOGIN_URL = "https://i.feixin.10086.cn/api";

	// 请求方式
	public static final String IFEIXIN_AUTHMETHOD = "sig";
	
	public static final String IFEIXIN_METHOD_VERSION = "2";
	
	
	/**
	 * 下面是具体方法名
	 */
	public static final String IFEIXIN_METHOD_GETFRIENDS = "friends.getfriends";
	
	
}
