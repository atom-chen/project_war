package com.fetion.shareplatform.network;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import android.content.Context;
import android.util.Log;

import com.fetion.shareplatform.json.handle.TaskHandler;
import com.fetion.shareplatform.model.OauthAccessToken;

public class PlatformHttpRequest {

	private static String TAG = PlatformHttpRequest.class.getSimpleName();

	HttpAsyncTaskManager manager;
	HttpsAsyncTaskManager httpsManager;
	private SortedMap<String, String> params = new TreeMap<String, String>();

	public PlatformHttpRequest(Context context) {
		manager = new HttpAsyncTaskManager(context);
		httpsManager = new HttpsAsyncTaskManager(context);
		// params.put("call_id", String.valueOf(System.currentTimeMillis()));
		// params.put("format", "json");
		// params.put("v", UrlConfig.IFEIXIN_METHOD_VERSION);
	}

	public void setParameter(String key, String value) {
		params.put(key, value);
	}

	public void setparameters(Map<String, String> map) {
		params.putAll(map);
	}

	public SortedMap<String, String> getParams() {
		return params;
	}

	/**
	 * 
	 * @param apiKey
	 *            当前应用的appkey
	 * @param secretKe
	 *            当前应用的secretKey
	 * @param token
	 *            用户token
	 */
	// public void FetionGetFriends(String apiKey, String secretKey,
	// OauthAccessToken token, TaskHandler<?> handler)
	// {
	// params.put("api_key", apiKey);
	// params.put("method", UrlConfig.IFEIXIN_METHOD_GETFRIENDS);
	// Utils.ConfigFetionSig(params, token.access_token, secretKey);
	// manager.request(UrlConfig.IFEIXIN_API_BASE_URL, 1, params, handler);
	//
	// }

	/**
	 * 从飞信同窗获取飞信好友
	 * 
	 * @param token
	 * @param handler
	 */
	public void FetionGetFriends(String access_token, TaskHandler<?> handler) {
		params.put("access_token", access_token);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/buddy.json?access_token=" + access_token, 0, params,
				handler);

	}
	
	/**
	 * 从飞信同窗获取飞信分页好友
	 * 
	 * @param token
	 * @param handler
	 */
	public void FetionGetPagerFriends(OauthAccessToken token, int page, TaskHandler<?> handler) {
		params.put("access_token", token.access_token);
		params.put("page", String.valueOf(page));
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/buddypage.json?access_token=" + token.access_token+"&page="+page, 0, params,
				handler);
	}
	
	/**
	 * 从飞信获取个人信息
	 * @param token
	 * @param handler
	 */
	public void FetionGetUserInfo(OauthAccessToken token, TaskHandler<?> handler) {
		params.put("access_token", token.access_token);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/user.json?access_token="
				+ token.access_token, 0, handler);
	}
	/**
	 * 从飞信获取个人信息
	 * @param token
	 * @param handler
	 */
	public void FetionGetUserInfo(String token, TaskHandler<?> handler) {
		params.put("access_token", token);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/user.json?access_token="
				+ token, 0, handler);
	}
	
	/**
	 * 从飞信同窗获取飞信好友分组信息
	 * @param token
	 * @param handler
	 */
	public void FetionGetFriendsGroups(OauthAccessToken token, TaskHandler<?> handler)
	{
		params.put("access_token",token.access_token);	
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL+"/android13/grouplist.json?access_token="+token.access_token, 0, params, handler);
	}
	
	/**
	 * 根据用户分组 从飞信同窗获取好友信息
	 * @param token
	 * @param groupId 分组的id
	 * @param handler
	 */
	public void FetionGetFriendsByGroups(OauthAccessToken token, int groupId, TaskHandler<?> handler)
	{
//		params.put("access_token",token.access_token);	
//		params.put("groupid",String.valueOf(groupId));
//		manager.request(UrlConfig.IFEIXIN_API_BASE_URL+"/getbuddybygroup.json", 1, params, handler);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL+"/android13/getbuddybygroup.json?access_token="+
		token.access_token+"&groupid="+String.valueOf(groupId), 0, null, handler);
	}
	
	/**
	 * 发布content到飞信同窗
	 * 
	 * @param token
	 * @param feedcontent
	 * @param handler
	 */
	public void FetionFeedText(OauthAccessToken token, String feedcontent,
			TaskHandler<?> handler) {
		String str="";
		try {
			str=URLEncoder.encode(feedcontent, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		params.put("access_token", token.access_token);
		params.put("feedcontent", str);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/feedstatus.json", 1,
				params, handler);
	}

	/**
	 * 发布图片到飞信同窗
	 * 
	 * @param token
	 * @param feedcontent
	 * @param image_url
	 * @param image_thumbnail
	 * @param handler
	 */
	public void FetionFeedImage(OauthAccessToken token, String feedcontent,
			String image_url, String image_thumbnail, TaskHandler<?> handler) {
		params.put("access_token", token.access_token);
		String str="";
		try {
			str=URLEncoder.encode(feedcontent, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		params.put("feedcontent", str);
		params.put("image_url", formatUrl(image_url));
		params.put("image_permalink", formatUrl(image_url));
		params.put("image_thumbnail", formatUrl(image_thumbnail));
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/feedstatus.json", 1,
				params, handler);
	}

	/**
	 * 发布视频到飞信同窗
	 * 
	 * @param token
	 * @param feedcontent
	 * @param video_title
	 * @param video_url
	 * @param video_thumbnail
	 * @param handler
	 */
	public void FetionFeedVideo(OauthAccessToken token, String feedcontent,
			String video_title, String video_url, String video_thumbnail,
			TaskHandler<?> handler) {
		String str="";
		try {
			str=URLEncoder.encode(feedcontent, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		params.put("access_token", token.access_token);
		params.put("feedcontent", str);
		params.put("video_title", video_title);
		params.put("video_tinyurl", null);
		params.put("video_url", formatUrl(video_url));
		params.put("video_permalink", formatUrl(video_url));
		params.put("video_thumbnail", formatUrl(video_thumbnail));
		// Utils.ConfigFetionSig(params, token.access_token, feedcontent);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/feedstatus.json", 1,
				params, handler);
	}

	/**
	 * 分享到飞信好友
	 */
	public void FetionToFriends(String token, String friendsid, String text,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("touserid", friendsid);
		params.put("text", text);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/wpasendmessage.json" , 1, params, handler);
	}
	
	/**
	 * 分享到短信
	 */
	public void FetionToMessages(String token, String friendsid, String text,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("touserid", friendsid);
		params.put("text", text);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/wpasendsms.json" , 1, params, handler);
	}
	
	/**
	 * 分享定制内容到短信
	 */
	public void FetionToFetionMessages(String token, String buddy,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("buddy[]", buddy);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/gamesmsinvite.json" , 1, params, handler);
	}

	/**
	 * 分享定制内容到短信
	 */
	public void FetionToContactMessages(String token, String phone,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("phone[]", phone);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/gamesmsinvite.json" , 1, params, handler);
	}
	
	/**
	 * 支付订单查询接口
	 * 
	 * @param token
	 * @param orderid
	 * @param handler
	 */
	public void FetionPayOrderQuery(String token, String orderId,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("orderid", orderId);
		manager.request(UrlConfig.IFEIXIN_ORDER_QUERY_URL, 1, params, handler);

	}

	/**
	 * 公共账号绑定
	 * 
	 * @param token
	 * @param number400
	 * @param handler
	 */
	public void FetionPublicAccountBind(String token, String number400,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("number400", number400);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/publicaccountbinding.json", 1, params, handler);
	}

	/**
	 * 公共账号解绑
	 * 
	 * @param token
	 * @param number400
	 * @param handler
	 */
	public void FetionPublicAccountUnbind(String token, String number400,
			TaskHandler<?> handler) {
		params.put("access_token", token);
		params.put("number400", number400);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL
				+ "/android13/publicaccountunbind.json", 1, params, handler);
	}
	
	/**
	 * 获取短链
	 * OriginalUrl	分享内容的URL地址，如某个文章的URL（一定要带http）
     * AppId	接入开放平台的应用ID，用来统计每个应用的分享量
     * TerminalType	调用SDK的终端设备型号，如手机型号
     * Network	SDK正在使用的联网方式，如3G、wifi
     * Terrace	URL内容将要分享到的目标平台，飞信(1)身边(2)其他(0)
     * isShort 是否获取短链接
	 * */

	public void getShortUrl(String OriginalUrl,String AppId,String TerminalType,int Network,boolean isShort, int Terrace,TaskHandler<?> handler){
		String result = UrlConfig.IFEIXIN_API_BASE_URL + "/android13/sdktinyurl.json";
		params.put("OriginalUrl", formatUrl(OriginalUrl));
		params.put("AppId", AppId);
		params.put("TerminalType", TerminalType);
		params.put("Network", String.valueOf(Network));
		params.put("Terrace", String.valueOf(Terrace));
				
		if(!isShort){
			params.put("istiny", "0");
		}
		Log.i(TAG,"result ulr="+ result);
		manager.request( result, 1, params, handler);
	}

	public String formatUrl(String url) {
		String result = null;
		if (url != null) {

			try {
				Log.i("wwwww", "url=" + url);
				result = URLEncoder.encode(url, "utf-8").replace("*", "*")
						.replace("~", "~").replace("+", " ");
				Log.i("wwwww", "result=" + result);
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
				Log.i("wwwww", e.getMessage());
			}
		}
		return result;
	}

	/*登录请求
	 * username 手机号/飞信号/邮箱
	 * password 用户登录密码
	 * client_id 当前应用的appkey
	 * sig 
	 */
	public void loginByPassword(String username,String password,String client_id, String sig, TaskHandler<?> handler){
		params.put("username", username);
		params.put("password", password);
		params.put("client_id", client_id);
		params.put("sig", sig);
		String info = android.os.Build.MODEL+";"+android.os.Build.VERSION.RELEASE;
		params.put("ua", formatUrl(info.replace(" ", "")));
		httpsManager.request(UrlConfig.IFEIXIN_AUTOLOGIN_URL
				+ "/android13/getaccesstokenbypw.json", 1, params, handler);
	}
	
	public void loginBycode(String username,String code,String client_id, String sig, TaskHandler<?> handler){
		params.put("username", username);
		params.put("code", code);
		params.put("client_id", client_id);
		params.put("sig", sig);
		String info = android.os.Build.MODEL+";"+android.os.Build.VERSION.RELEASE;
		params.put("ua", formatUrl(info.replace(" ", "")));
		httpsManager.request(UrlConfig.IFEIXIN_AUTOLOGIN_URL + "/android13/getaccesstokenbycode.json", 1, params,handler);
	}
	
	public void getcode(String Mobile,TaskHandler<?> handler){
		params.put("Mobile", Mobile);
		httpsManager.request(UrlConfig.IFEIXIN_AUTOLOGIN_URL + "/android13/sendsmscode.json", 1, params,handler);
	}
	
	/**
	 * 自动登录请求
	 * @param imei 手机的imei号
	 * @param apiKey 当前应用的appkey
	 * @param handler
	 */
	public void autoWpaSmsLogin(String imei, String apiKey, String sig, TaskHandler<?> handler){
		params.put("imei", imei);
		params.put("apikey", apiKey);
		params.put("sig", sig);
		String info = android.os.Build.MODEL+";"+android.os.Build.VERSION.RELEASE;
		params.put("ua", formatUrl(info.replace(" ", "")));
		httpsManager.requestAddTimeOut(UrlConfig.IFEIXIN_AUTOLOGIN_URL + "/android13/wpasmslogin.json", 1, params, 5000, handler);
	}
	
	/**
	 * 通讯录获取
	 * @param access_token 登陆获取的token
	 * @param type  1:通讯录获取       2:是否上传通讯录
	 */
	public void getSDKAddress(String access_token, int type, TaskHandler<?> handler){
		params.put("access_token", access_token);
		params.put("type", String.valueOf(type));
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/sdkaddressget.json", 1, params, handler);
	}
	
	/**
	 * 通讯录更新
	 * @param access_token 登陆获取的token
	 * @param type   1:全量(增量)添加  2：增量更新  3：增量删除
	 * @param address  Json格式的通讯录
	 * @param handler
	 */
	public void SDKAddressUp(String access_token, int type, String address, TaskHandler<?> handler){
		params.put("access_token", access_token);
		params.put("type", String.valueOf(type));
		params.put("address", address);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/sdkaddressup.json", 1, params, handler);
	}
	
	/**
	 * 好友版本号获取
	 * @param access_token 登陆获取的token
	 */
	public void getSDKBuddyVersion(String access_token, TaskHandler<?> handler){
		params.put("access_token", access_token);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/sdkbuddyversionget.json", 1, params, handler);
	}
	
	/**
	 * 游戏签到
	 * @param access_token 登陆获取的token
	 * @param handler
	 */
	public void gameSign(String access_token, TaskHandler<?> handler){
		params.put("access_token", access_token);
		manager.request(UrlConfig.IFEIXIN_API_BASE_URL + "/android13/gamesign.json", 1, params, handler);
	}
}
