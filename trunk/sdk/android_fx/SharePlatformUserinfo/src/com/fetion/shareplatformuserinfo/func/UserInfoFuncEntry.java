package com.fetion.shareplatformuserinfo.func;

import android.content.Context;
import android.util.Log;

import com.fetion.shareplatform.json.handle.UserInfoHandler;
import com.fetion.shareplatform.listener.UserInfoListener;
import com.fetion.shareplatform.model.UserInfo;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.Utils;

public class UserInfoFuncEntry {
    private static String TAG = UserInfoFuncEntry.class.getSimpleName();
	private static String myToken;
	
	/**
	 * 获取个人信息（登录用户）
	 * @param context 上下文
	 * @param UserInfoListener 用来监听获取userinfo实体
	 * */
	public static void fetionGetUserInfo(final Context context, final UserInfoListener listener){
		if (Utils.selectToken(context, "FX")) {
			myToken = Utils.getAccessToken(context, "FX");
			new PlatformHttpRequest(context).FetionGetUserInfo(myToken, new UserInfoHandler() {

				@Override
				public void onSuccess(UserInfo result) {
					if(result != null){
						listener.onCompleted(result);
						Log.i(TAG, "获取成功");
					}else{
						listener.onFailure("获取用户信息错误");
						Log.i(TAG, "获取用户信息错误");
					}
				}

				@Override
				public void onFailed(String result) {
					if(result != null){
						if("need login".equals(result)){
							listener.onFailure("need login");
							Log.i(TAG, "get userinfo need login");
						}else{
							listener.onFailure("获取用户信息失败");
							Log.i(TAG, "获取用户信息失败");
						}
					}else{
						listener.onFailure("请求服务器失败");
						Log.i(TAG, "请求服务器失败");
					}
				}
				@Override
				public void onTimeOut() {
					listener.onTimeOut();
					Log.i(TAG, "网络连接超时，请稍后重试");
				}
			});
		}else{
			listener.onFailure("need login");
			Log.i(TAG,"get userinfo need login");
		}
	}
}
