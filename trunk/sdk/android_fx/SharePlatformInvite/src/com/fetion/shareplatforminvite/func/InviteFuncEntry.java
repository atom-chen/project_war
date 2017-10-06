package com.fetion.shareplatforminvite.func;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.fetion.shareplatform.EntryDispatcher.DispatcherFriendsListListener;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.listener.IFeixinShareListener;
import com.fetion.shareplatform.listener.IShareplatformFriendsListListener;
import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.Utils;

public class InviteFuncEntry {
	private static String myToken;
	private static String TAG = InviteFuncEntry.class.getSimpleName();
	public static IShareplatformFriendsListListener gfriendsListListener;
	
	/**
	 * 发送邀请短信给好友
	 * @param context 上下文
	 * @param shareType 判断分享类型  例：文本 图片等  1:文本，2：图片，3：视频，4：网页
	 * @param sharePlatformInfo 分享实体
	 * @param appKey 飞信开放平台提供的APPkey
	 * @param listener 监听接口 
	 */
	public static void fetionInvite(Context context, int shareType,SharePlatformInfo sharePlatformInfo, 
			String appKey, final IShareplatformFriendsListListener listener){
		if (Utils.selectToken(context, "FX")) {
			gotoFeixinFriendsListActivity(context, shareType, false, 2, appKey, sharePlatformInfo, new DispatcherFriendsListListener(){
				@Override
				public void onCompleted(boolean isSuccess) {
					listener.onCompleted(isSuccess);
				}
	
				@Override
				public void onFailure(String message, int errorCode) {
					listener.onFailure(message, errorCode);
				}
	
				@Override
				public void onTimeOut() {
					listener.onTimeOut();
				}
				
			});
		}else{
			listener.onFailure("need login", 0);
		}
	}
	
	/**
	 * 分享到飞信好友(暂不对外开放)
	 * @param context 上下文
	 * @param shareType 判断分享类型  例：文本 图片等  1:文本，2：图片，3：视频，4：网页
	 * @param sharePlatformInfo 分享实体
	 * @param appKey 飞信开放平台提供的APPkey
	 * @param listener 监听接口 
	 */
	private static void sharedToFetionFriends(Context context, int shareType,SharePlatformInfo sharePlatformInfo, 
			String appKey, final IFeixinShareListener listener){
		if (Utils.selectToken(context, "FX")) {
			gotoFeixinFriendsListActivity(context, shareType, true, 1, appKey, sharePlatformInfo, new DispatcherFriendsListListener(){
	
				@Override
				public void onCompleted(boolean isSuccess) {
					listener.onCompleted(isSuccess);
				}
	
				@Override
				public void onFailure(String message, int errorCode) {
					listener.onFailure(message, errorCode);
				}
	
				@Override
				public void onTimeOut() {
					listener.onTimeOut();
				}
				
			});
		}else{
			listener.onFailure("need login", 0);
		}
	}
	
	
	/**
	 * 获取飞信好友列表
	 * @param context 上下文
	 * @param shareType 分享的的类型
	 * @param appKey 官方提供的appKey
	 * @param isShortLink 是否转换为短链接
	 * @param shareToFeiton 分享到飞信还是短信：1.飞信, 2.短信
	 * @param sharePlatformInfo 分享的实体
	 * @param friendsListListener 监听接口
	 */
	private static void gotoFeixinFriendsListActivity(final Context context, final int shareType, final boolean isShortLink, final int shareToFeiton, final String appKey, 
			final SharePlatformInfo sharePlatformInfo, IShareplatformFriendsListListener friendsListListener){
		InviteFuncEntry.gfriendsListListener = friendsListListener;
		boolean networkType = Utils.isWifiNetwrokType(context);
		int network = 1;
		if(networkType){
			network = 2;
		}else{
			network = 1;
		}
		String model = android.os.Build.MODEL;
		
		switch (shareType) {
		//feed text
		case 1:
			getFriends(context, shareType, shareToFeiton, appKey, sharePlatformInfo);
			break;
		//feed image
        case 2:
        	getFriends(context, shareType, shareToFeiton, appKey, sharePlatformInfo);
			break;
		//feed vedio
        case 3:
        	getFriends(context, shareType, shareToFeiton, appKey, sharePlatformInfo);
	        break;
	    //feed networkPage
        case 4:
        	int index = 0;
			String str = sharePlatformInfo.getPageUrl().toLowerCase();

			if (str.contains("http://")) {
				index = str.lastIndexOf("http://");
			} else if (str.contains("https://")) {
				index = str.lastIndexOf("https://");
			} else {
				Log.i(TAG, "the url is illegal");
			}
			String needUrl = sharePlatformInfo.getPageUrl().substring(index, sharePlatformInfo.getPageUrl().length());
			final String behindStr = sharePlatformInfo.getPageUrl().substring(0, index);
			Log.i(TAG, "needUrl===="+needUrl);
			Log.i(TAG, "behindStr====="+behindStr);
			

			new PlatformHttpRequest(context).getShortUrl(
					needUrl, appKey, model, network, isShortLink, 1,  new FetionPublicAccountHandler() {
						
						@Override
						public void onSuccess(String result) {
							if(result != null){
								sharePlatformInfo.setPageUrl(behindStr + result);	
							}
							getFriends(context, shareType, shareToFeiton, appKey, sharePlatformInfo);
						}
						
						@Override
						public void onFailed(String result) {
							Log.i(TAG, "onFailed");
							getFriends(context, shareType, shareToFeiton, appKey, sharePlatformInfo);
						}
						
						@Override
						public void onTimeOut() {
							Log.i(TAG, "timeout");
							getFriends(context, shareType, shareToFeiton, appKey, sharePlatformInfo);
						}
					});
			
	        break;
		}
	}
	
	private static void getFriends(final Context context, final int shareType, final int shareToFetion, final String appKey, 
			final SharePlatformInfo sharePlatformInfo){

    	myToken=Utils.getAccessToken(context, "FX");
		OauthAccessToken token = new OauthAccessToken();
		token.access_token = myToken;
		Intent intent = new Intent(context, FeixinFriendsListActivity.class);
		Bundle bundle = new Bundle();
		bundle.putSerializable(FeixinFriendsListActivity.EXTRA_KEY_ACCESSTOKEN, token);
		bundle.putSerializable(FeixinFriendsListActivity.EXTRA_KEY_SHAREPLATFORMINFO, sharePlatformInfo);
		intent.putExtra(FeixinFriendsListActivity.EXTRA_KEY_SHARETYPE, shareType);
		intent.putExtra(FeixinFriendsListActivity.EXTRA_KEY_SHARETOFETION, shareToFetion);
		intent.putExtras(bundle);
		context.startActivity(intent);
	}
}
