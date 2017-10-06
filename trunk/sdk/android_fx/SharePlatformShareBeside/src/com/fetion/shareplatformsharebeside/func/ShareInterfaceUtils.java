package com.fetion.shareplatformsharebeside.func;

import android.content.Context;
import android.util.Log;

import com.fetion.shareplatform.EntryDispatcher;
import com.fetion.shareplatform.func.login.LoginFuncEntry;
import com.fetion.shareplatform.json.handle.FetionFeedHandler;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.listener.IFeixinShareListener;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.model.FetionFeedEntity;
import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.Utils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class ShareInterfaceUtils {
	private static String TAG = ShareInterfaceUtils.class.getSimpleName();

	/** 分享到飞信同窗 */
	public static boolean shareToFetion(int type, final Context context,
			String appId, final OauthAccessToken oauthToken,
			final SharePlatformInfo info,
			final IFeixinShareListener shareListener) {
		switch (type) {
		case EntryDispatcher.SHARE_TYPE_TEXT:
			feedText(context, oauthToken, info.getText(), shareListener);
			break;
		case EntryDispatcher.SHARE_TYPE_IMAGE:
			feedImage(context, oauthToken, info.getText(), info.getmImageUrl(),
					info.getThumbUrl(), shareListener);
			break;
		case EntryDispatcher.SHARE_TYPE_VIDEO:
			feedVideo(context, oauthToken, info.getText(), info.getTitle(),
					info.getVideoUrl(), info.getThumbUrl(), shareListener);
			break;
		case EntryDispatcher.SHARE_TYPE_WEBPAGE:
			shortUrl(context, appId, info, oauthToken, shareListener);
			break;
		}
		return false;
	}

	/**
	 * 分享Url借口 APPID 终端型号 网络情况 目标平台
	 * */
	public static void ShardUrl(String appId, String phoneNo,
			String networkState, int shardPlatform,
			final IFeixinShareListener listener) {

	}

	private static void shortUrl(final Context context, String appId,
			final SharePlatformInfo info, final OauthAccessToken oauthToken,
			final IFeixinShareListener shareListener) {
		boolean isWifi = Utils.isWifiNetwrokType(context);
		
		int Network = 0;
		if (isWifi) {
			Network = 2;
		} else {
			Network = 1;
		}
		String model = android.os.Build.MODEL;
		if (info.getPageUrl().toString().trim().length() == 0) {
			shareListener.onCompleted(false);
		}else{ 
		final String temp = info.getPageUrl().trim();
		
		int index = 0;
		String needUrl = null;
		if (temp.contains("http://")) {
			index = temp.lastIndexOf("http://");
			needUrl = info.getPageUrl().substring(index, info.getPageUrl().length());
		} else if (temp.contains("https://")) {
			index = temp.lastIndexOf("https://");
			needUrl = info.getPageUrl().substring(index, info.getPageUrl().length());
		} else {
			Log.i(TAG, "the url is illegal");
		}
		if(needUrl == null || needUrl.length() == 0){
			Log.i(TAG, "needUrl == null");
			feedText(context, oauthToken, info.getPageUrl(),
					shareListener);
		}else{
			final String behindStr = info.getPageUrl().substring(0, index);
			Log.i(TAG, "needUrl===="+needUrl);
			Log.i(TAG, "behindStr====="+behindStr);
			new PlatformHttpRequest(context).getShortUrl(needUrl, appId,
					model, Network, true, 2, new FetionPublicAccountHandler() {
						@Override
						public void onSuccess(String result) {
							Log.i(TAG, "short-----------" + result);
							if (result == null || result.length() == 0) {
								feedText(context, oauthToken, info.getPageUrl(),
										shareListener);
							} else {
								feedText(context, oauthToken, behindStr + result, shareListener);
							}
						}

						@Override
						public void onFailed(String result) {
							feedText(context, oauthToken, info.getPageUrl(),
									shareListener);
						}

						@Override
						public void onTimeOut() {
							feedText(context, oauthToken, info.getPageUrl(),
									shareListener);
						}
					});
		     }
		}
	}

	/**
	 * 发布文本或URL链接到同窗的接口
	 * 
	 * @param context
	 *            上下文
	 * @param oauthToken
	 *            用户的Token
	 * @param feedcontent
	 *            文本或URL链接
	 * @return true:成功 false:失败
	 */
	private static void feedText(final Context context,
			OauthAccessToken oauthToken, String feedcontent,
			final IFeixinShareListener shareListener) {
		if (feedcontent.toString().trim().length() == 0) {
			shareListener.onCompleted(false);
		} else {
			new PlatformHttpRequest(context).FetionFeedText(oauthToken,
					feedcontent, new FetionFeedHandler() {
						@Override
						public void onSuccess(FetionFeedEntity result) {
							if("true".equals(result.getStatus())){
								shareListener.onCompleted(true);
								Log.i(TAG, "分享成功");
							}else{
								shareListener.onCompleted(false);
								Log.i(TAG, "onSuccess 分享失败");
							}
						}

						@Override
						public void onTimeOut() {
							shareListener.onTimeOut();
							Log.i(TAG, "网络连接超时，请稍后重试");
						}

						@Override
						public void onFailure(String result) {
							setFailedInfo(context, result, shareListener);
						}
					});
		}
	}

	/**
	 * 发布图片到同窗的接口
	 * 
	 * @param context
	 *            上下文
	 * @param oauthToken
	 *            用户的Token
	 * @param feedcontent
	 *            图片的描述
	 * @param image_url
	 *            小尺寸图片URL
	 * @param image_thumbnail
	 *            大尺寸图片URL
	 * @return true:成功 false:失败
	 */
	private static void feedImage(final Context context,
			OauthAccessToken oauthToken, String feedcontent, String image_url,
			String image_thumbnail, final IFeixinShareListener shareListener) {
		new PlatformHttpRequest(context).FetionFeedImage(oauthToken,
				feedcontent, image_url, image_thumbnail,
				new FetionFeedHandler() {

					@Override
					public void onSuccess(FetionFeedEntity result) {
						if("true".equals(result.getStatus())){
							shareListener.onCompleted(true);
							Log.i(TAG, "分享成功");
						}else{
							shareListener.onCompleted(false);
							Log.i(TAG, "onSuccess 分享失败");
						}
					}

					@Override
					public void onTimeOut() {
						shareListener.onTimeOut();
						Log.i(TAG, "网络连接超时，请稍后重试");
					}

					@Override
					public void onFailure(String result) {
						setFailedInfo(context, result, shareListener);
					}
		});
	}

	/**
	 * 发布视频到同窗的接口
	 * 
	 * @param context
	 *            上下文
	 * @param oauthToken
	 *            用户的Token
	 * @param feedcontent
	 *            用户填写
	 * @param video_title
	 *            视频标题
	 * @param video_url
	 *            视频的URL链接
	 * @param video_thumbnail
	 *            视频的图片URL
	 * @return true:成功 false:失败
	 */
	private static void feedVideo(final Context context,
			OauthAccessToken oauthToken, String feedcontent,
			String video_title, String video_url, String video_thumbnail,
			final IFeixinShareListener shareListener) {
		new PlatformHttpRequest(context).FetionFeedVideo(oauthToken,
				feedcontent, video_title, video_url, video_thumbnail,
				new FetionFeedHandler() {

					@Override
					public void onSuccess(FetionFeedEntity result) {
						if("true".equals(result.getStatus())){
							shareListener.onCompleted(true);
							Log.i(TAG, "分享成功");
						}else{
							shareListener.onCompleted(false);
							Log.i(TAG, "onSuccess 分享失败");
						}
					}

					@Override
					public void onTimeOut() {
						shareListener.onTimeOut();
						Log.i(TAG, "网络连接超时，请稍后重试");
					}

					@Override
					public void onFailure(String result) {
						setFailedInfo(context, result, shareListener);
					}
				});
	}
	
	private static void setFailedInfo(Context context, String result, IFeixinShareListener shareListener){
		if(result != null){
			if(result.equals("need login")){
				Log.i(TAG, "need login");
				shareListener.onFailure("need login", 0);
				LoginFuncEntry.fetionLogout(context);
			}else{
				BaseErrorEntity errorEntity = null;
				try {
					errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
				} catch (Exception e) {
					e.printStackTrace();
				} finally{
					if(errorEntity != null){
						if("false".equals(errorEntity.getStatus())){
							int errorCode = Integer.parseInt(errorEntity.getErrorcode());
							if(errorCode == 1){
								Log.i(TAG, "分享内容字符超长(最长140个字符)");
								shareListener.onFailure("分享内容字符超长(最长140个字符)", 1);
							}else if(errorCode == 2){
								Log.i(TAG, "分享图片的类型不符");
								shareListener.onFailure("分享图片的类型不符", 2);
							}else if(errorCode == 3){
								Log.i(TAG, "分享内容重复");
								shareListener.onFailure("分享内容重复", 3);
							}else if(errorCode == 4){
								Log.i(TAG, "分享频率过限");
								shareListener.onFailure("分享频率过限", 4);
							}else if(errorCode == 5){
								Log.i(TAG, "服务器错误");
								shareListener.onFailure("服务器错误", 5);
							}else if(errorCode == 6){
								Log.i(TAG, "分享参数缺失");
								shareListener.onFailure("分享参数缺失", 6);
							}else{
								Log.i(TAG, "分享失败");
								shareListener.onFailure("分享失败", 7);
							}
						}else{
							Log.i(TAG, "分享失败");
							shareListener.onFailure("分享失败", 7);
						}
					}else{
						Log.i(TAG, "分享失败");
						shareListener.onFailure("分享失败", 7);
					}
				}
			}
		}else{
			Log.i(TAG, "请求服务器失败");
			shareListener.onFailure("请求服务器失败", 8);
		}
	}
}
