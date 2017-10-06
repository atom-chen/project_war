package com.fetion.shareplatformpublicaccount.func;

import com.example.shareplatformpublicaccount.R;
import com.fetion.shareplatform.func.login.LoginFuncEntry;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.listener.IFeixinAccountListener;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.Utils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import android.content.Context;
import android.util.Log;

public class PublicAccountFuncEntry {
	private static String TAG = PublicAccountFuncEntry.class.getSimpleName();
	private static String myToken;
	
	/**
	 * 飞信公共账号绑定
	 * @param context 上下文
	 * @param accountId  公共账号id
	 * @param listener 服务器返回数据回调接口
	 */
	public static void fetionBindPublicAccounts(final Context context, final String accountId, final IFeixinAccountListener listener){
		if(Utils.isNetworkAvaliable(context)){
			if (!Utils.selectToken(context, "FX")) {
	    		listener.onFailure(context.getString(R.string.publicaccount_need_login), 0);	
			} else {
				myToken = Utils.getAccessToken(context, "FX");
				new PlatformHttpRequest(context).FetionPublicAccountBind(myToken,
					accountId, new FetionPublicAccountHandler() {
						@Override
						public void onSuccess(String result) {
							Log.i(TAG, "关注公众号成功");
							listener.onCompleted();
						}

						@Override
						public void onFailed(String result) {
							Log.i(TAG, "onFailed"+result);
							if(result != null){
								if(result.equals("need login")){
									Log.i(TAG, "bind need login");
									listener.onFailure(context.getString(R.string.publicaccount_need_login), 0);
									LoginFuncEntry.fetionLogout(context);
								}else{
									BaseErrorEntity errorEntity = null;
									try {
										errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
									} catch (Exception e) {
										e.printStackTrace();
									}
									if(errorEntity != null){
										if("false".equals(errorEntity.getStatus())){
											int errorCode = Integer.parseInt(errorEntity.getErrorcode());
											if(errorCode == 1){
												Log.i(TAG, "已关注成功,请不要重复关注");
												listener.onFailure(context.getString(R.string.publicaccount_bind_repeat), 1);
											}else if(errorCode == 2){
												Log.i(TAG, "关注公众号失败");
												listener.onFailure(context.getString(R.string.publicaccount_bind_failed), 2);
											}else{
												Log.i(TAG, "关注公众号失败");
												listener.onFailure(context.getString(R.string.publicaccount_bind_failed), 2);
											}
										}
									}else{
										Log.i(TAG, "关注公众号失败");
										listener.onFailure(context.getString(R.string.publicaccount_bind_failed), 2);
									}
								}
							}else{
								Log.i(TAG, "连接服务器失败");
								listener.onFailure(context.getString(R.string.publicaccount_requestsever_failed), 3);
							}
						}

						@Override
						public void onTimeOut() {
							listener.onTimeOut();
							Log.i(TAG, "网络连接超时，请稍后重试");
						}
					});
			}
		}else{
			Log.i(TAG, "网络连接错误");
			listener.onNetError();
		}
	}
	
	/**
	 * 飞信公共账号解绑
	 * @param context 上下文
	 * @param accountId  公共账号id
	 * @param listener 服务器返回数据回调接口
	 */
    public static void fetionUnbindPublicAccounts(final Context context, final String accountId, final IFeixinAccountListener listener){
    	if(Utils.isNetworkAvaliable(context)){
    		if (!Utils.selectToken(context, "FX")) {
        		listener.onFailure(context.getString(R.string.publicaccount_need_login), 0);
    		} else {
    			myToken = Utils.getAccessToken(context, "FX");
    			new PlatformHttpRequest(context).FetionPublicAccountUnbind(myToken,
    					accountId, new FetionPublicAccountHandler() {
    						@Override
    						public void onSuccess(String result) {
    							listener.onCompleted();
    							Log.i(TAG, "取消关注公众号成功");
    						}

    						@Override
    						public void onFailed(String result) {
    							if(result != null){
    								if(result.equals("need login")){
    									Log.i(TAG, "unbind need login");
    									listener.onFailure(context.getString(R.string.publicaccount_need_login), 0);
    									LoginFuncEntry.fetionLogout(context);
    								}else{
    									BaseErrorEntity errorEntity = null;
        								try {
        									errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
        								} catch (Exception e) {
        									e.printStackTrace();
        								}
        								if(errorEntity != null){
        									if("false".equals(errorEntity.getStatus())){
        										int errorCode = Integer.parseInt(errorEntity.getErrorcode());
        										if(errorCode == 1){
        											listener.onFailure(context.getString(R.string.publicaccount_unbind_failed), 1);
        											Log.i(TAG, "取消关注公众号失败");
        										}else{
        											Log.i(TAG, "取消关注公众号失败");
        											listener.onFailure(context.getString(R.string.publicaccount_unbind_failed), 1);
        										}
        									}
        								}else{
        									Log.i(TAG, "取消关注公众号失败");
        									listener.onFailure(context.getString(R.string.publicaccount_unbind_failed), 1);
        								}
        								
    								}
    							}else{
    								Log.i(TAG, "连接服务器失败");
    								listener.onFailure(context.getString(R.string.publicaccount_requestsever_failed), 2);
    							}
    						}

    						@Override
    						public void onTimeOut() {
    							Log.i(TAG, "网络连接超时，请稍后重试");
    							listener.onTimeOut();
    						}
    					});
    		}
    	}else{
    		Log.i(TAG, "网络连接错误");
    		listener.onNetError();
    	}
    	
	}
}
