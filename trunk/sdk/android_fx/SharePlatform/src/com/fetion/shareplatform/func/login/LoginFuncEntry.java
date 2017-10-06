package com.fetion.shareplatform.func.login;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.fetion.shareplatform.EntryDispatcher;
import com.fetion.shareplatform.listener.IShareplatformAuthListener;
import com.fetion.shareplatform.util.Utils;

public class LoginFuncEntry {
	public static IShareplatformAuthListener loginListener;
	
	/**
	 * 本地登录页面
	 * @param context
	 * @param appKey 飞信开放平台提供的APPkey
	 */
    public static void fetionLogin(final Context context,final String appKey,IShareplatformAuthListener listener){
	    EntryDispatcher.gAppKey = appKey;
	    Log.i("LoginFuncEntry", "appKey:" + appKey);
	    LoginFuncEntry.loginListener = listener;
	    fetionAutoLogin(context, appKey);
	}
    
    /**
     * 自动登录
     * @param context
     * @param appKey
     */
    private static void fetionAutoLogin(Context context, String appKey){
    	Intent intent=new Intent(context,AutoLoginActivity.class);
    	intent.putExtra("autoLoginAppkey", appKey);
		context.startActivity(intent);
    }
    
	/**
	 * 判断当前登录是否有效
	 * @param context
	 * @return
	 */
	public static boolean fetionIsValidated(Context context){
		return Utils.selectToken(context, "FX");
	}
	
	/**
	 * 注销token
	 * @param context
	 * @return
	 */
	public static boolean fetionLogout(Context context){
		return Utils.deleteAccessToken(context, "FX");
	}
}
