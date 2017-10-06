package com.onekes.kxllx;

import com.onekes.kxllx.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;
import org.cocos2dx.lua.AppActivity;

import com.onekes.kxllx.CONFIG;

import com.fetion.shareplatform.EntryDispatcher;
import com.fetion.shareplatform.func.login.LoginFuncEntry;
import com.fetion.shareplatform.listener.IFeixinShareListener;
import com.fetion.shareplatform.listener.IShareplatformAuthListener;
import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatformsharebeside.func.ShareFuncEntry;

public class ShareUtil {
	private static Activity mActivity = null;
	
	public static void onCreate(Activity activity) {
		mActivity = activity;
	}
	
	public static void onDestroy(Activity activity) {
	}
	
	public static void onResume(Activity activity) {
	}
	
	public static void onPause(Activity activity) {
	}
	
	public static void onStop(Activity activity) {
	}
	
	public static void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
	}
	
	public static void share(String shareJson) {
		try {
			JSONObject jsonObj = new JSONObject(shareJson);
			int shareType = jsonObj.getInt("share_type");
			if (1 == shareType) {
				Log.e("kxllx", "share picture");
				feixinSharePicture(jsonObj.getString("share_pic"));
			} else if (2 == shareType) {
				Log.e("kxllx", "share url");
				feixinShareURL(jsonObj.getString("share_content"), jsonObj.getString("share_url"));
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	private static class FeixinShareListener implements IFeixinShareListener {
		@Override
		public void onFailure(String message, int errorCode) {
			Log.e("cocos2d-x", "feixinShareListener -> onFailure -> message: " + message + ", errorCode: " + errorCode);
			if (message.contains("need login")) {
				LoginFuncEntry.fetionLogin(mActivity, CONFIG.FX_APP_KEY, 
					new IShareplatformAuthListener() {
						@Override
						public void onCompleted(OauthAccessToken token) {
							Log.e("cocos2d-x", "feixinShareListener -> onFailure -> fetionLogin -> onCompleted");
							Message msg = new Message();
							if (null == token) {	// token获取失败
								Log.e("cocos2d-x", "feixinShareListener -> onFailure -> fetionLogin -> onCompleted -> token is null");
								msg.what = AppActivity.MT_SHARE_FAIL;
								msg.obj = R.string.str_share_fail_get_token;
							} else {				// token获取成功
								Log.e("cocos2d-x", "feixinShareListener -> onFailure -> fetionLogin -> onCompleted -> token: " + token.access_token);
								msg.what = AppActivity.MT_SHARE_SUCCESS;
								msg.obj = R.string.str_share_success;
							}
							msg.arg1 = Toast.LENGTH_LONG;
					        AppActivity.sHandler.sendMessage(msg);
						}
						
						@Override
						public void onFailure(String message) {
							Log.e("cocos2d-x", "feixinShareListener -> onFailure -> fetionLogin -> onFailure -> message: " + message);
							Message msg = new Message();
							msg.what = AppActivity.MT_SHARE_FAIL;
							msg.obj = mActivity.getResources().getString(R.string.str_share_fail_login_fx) + ", " + message;
							msg.arg1 = Toast.LENGTH_LONG;
					        AppActivity.sHandler.sendMessage(msg);
						}
						
						@Override
						public void onCancle() {
							Log.e("cocos2d-x", "feixinShareListener -> onFailure -> fetionLogin -> onCancle");
							Message msg = new Message();
							msg.what = AppActivity.MT_SHARE_CANCEL;
							msg.obj = R.string.str_share_cancel_login_fx;
							msg.arg1 = Toast.LENGTH_LONG;
					        AppActivity.sHandler.sendMessage(msg);
						}
					});
			} else {
				// 请求服务器失败
				Message msg = new Message();
				msg.what = AppActivity.MT_SHARE_FAIL;
				msg.obj = R.string.str_request_server_fail;
				msg.arg1 = Toast.LENGTH_LONG;
		        AppActivity.sHandler.sendMessage(msg);
			}
		}

		@Override
		public void onCompleted(boolean arg0) {
			Log.e("cocos2d-x", "feixinShareListener -> onCompleted -> arg0: " + arg0);
			Message msg = new Message();
			if (arg0) {	// 分享成功
				msg.what = AppActivity.MT_SHARE_SUCCESS;
				msg.obj = R.string.str_share_success;
			} else {	// 分享失败
				msg.what = AppActivity.MT_SHARE_FAIL;
				msg.obj = R.string.str_share_fail;
			}
			msg.arg1 = Toast.LENGTH_LONG;
	        AppActivity.sHandler.sendMessage(msg);
		}

		@Override
		public void onTimeOut() {
			Log.e("cocos2d-x", "feixinShareListener -> onTimeOut");
			// 网络连接超时
			Message msg = new Message();
			msg.what = AppActivity.MT_SHARE_FAIL;
			msg.obj = R.string.str_connect_timeout;
			msg.arg1 = Toast.LENGTH_LONG;
	        AppActivity.sHandler.sendMessage(msg);
		}
	}
	
	// 飞信分享图片
	private static void feixinSharePicture(String picture) {
		Log.e("cocos2d-x", "feixinSharePicture -> picture: " + picture);
		SharePlatformInfo info = new SharePlatformInfo();
		info.setTitle(mActivity.getResources().getString(R.string.app_name));
		info.setText(mActivity.getResources().getString(R.string.app_name));
		info.setmImageUrl(picture);
		ShareFuncEntry.fetionShare(mActivity,
				EntryDispatcher.APP_SHENBIAN,
				EntryDispatcher.SHARE_TYPE_IMAGE,
				info,
				CONFIG.FX_APP_KEY,
				new FeixinShareListener());
	}
	
	// 飞信分享链接
	private static void feixinShareURL(String content, String url) {
		Log.e("cocos2d-x", "feixinShareURL -> content: " + content + ", url: " + url);
		SharePlatformInfo info = new SharePlatformInfo();
//		info.setTitle(mActivity.getResources().getString(R.string.app_name));
		info.setText(content + "\n" + url);
//		info.setPageUrl(url);
		ShareFuncEntry.fetionShare(mActivity,
				EntryDispatcher.APP_SHENBIAN,
				EntryDispatcher.SHARE_TYPE_TEXT,
				info,
				CONFIG.FX_APP_KEY,
				new FeixinShareListener());
	}
}


