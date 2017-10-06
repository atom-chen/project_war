package com.onekes.kittycrush;

import java.util.HashMap;
import java.util.Iterator;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import cn.sharesdk.facebook.Facebook;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.onekeyshare.OnekeyShare;

import com.dataeye.DCAgent;
import com.dataeye.DCEvent;
import com.dataeye.DCReportMode;
import com.dataeye.DCVirtualCurrency;
import com.dataeye.plugin.DCLevels;
import com.onekes.kittycrush.hwgame.R;
import com.sdk.commplatform.CallbackListener;
import com.sdk.commplatform.Commplatform;
import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.game.UMGameAgent;
import com.utils.Database;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;
import android.widget.Toast;

public final class SDKUtil {
	private static Activity mActivity = null;
	private static HuaWeiPay mHuaweiPay = null;
	private static boolean mIsAppForeground = true;
	/***************************************************************************************
	******************************** public callback module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.创建
	public static void onCreate(Activity activity) {
		mActivity = activity;
		// database
		Database.create(activity, "kittycrush.db", null, 1);
		// dataeye
		DCAgent.setDebugMode(true);
		DCAgent.setReportMode(DCReportMode.DC_DEFAULT);
		// umeng
		UMGameAgent.setDebugMode(true);
	    UMGameAgent.init(activity);
	    // share sdk
	    ShareSDK.initSDK(activity);
//		ShareSDK.getPlatform(Facebook.NAME).setPlatformActionListener(new SharePlatformActionListener());
		ShareSDK.getPlatform(Facebook.NAME).SSOSetting(false);
	    // huawei
	    mHuaweiPay = new HuaWeiPay(activity);
        String packageName = activity.getPackageName();
        String version = "0.0.0";
        try {
        	PackageInfo packageInfo =  activity.getPackageManager().getPackageInfo(packageName, 0);
        	version = packageInfo.versionName;
        } catch (NameNotFoundException e) {
        	e.printStackTrace();
        }
        Commplatform.getInstance().checkVersion(version, packageName,activity);
		Log.e("cocos2d", "版本更新 :"+ packageName + " version："+ version);
	}
	//-------------------------------------------------------------------------------------
	// 2.销毁
	public static void onDestroy(Activity activity) {
		Database.close();
		DCAgent.onKillProcessOrExit();
		UMGameAgent.onKillProcess(activity);
		Commplatform.getInstance().destroy();
	}
	//-------------------------------------------------------------------------------------
	// 3.恢复
	public static void onResume(Activity activity) {
		DCAgent.onResume(activity);
		UMGameAgent.onResume(activity);
		mHuaweiPay.onResume(activity);
		if (!mIsAppForeground) {
//	        Commplatform.getInstance().pause(new OnPauseCompleteListener(activity) {
//	            @Override
//	            public void onComplete() {
//	            	mIsAppForeground = true;
//	            }
//	            
//	        });   
//	        mIsAppForeground = true;
        }
	}
	//-------------------------------------------------------------------------------------
	// 4.暂停
	public static void onPause(Activity activity) {
		DCAgent.onPause(activity);
		UMGameAgent.onPause(activity);
	}
	//-------------------------------------------------------------------------------------
	// 5.停止
	public static void onStop(Activity activity) {
		if (!AppActivity.sActivity.isAppOnForeground()) {
            //app进入后台
            mIsAppForeground = false;
        }
	}
	//-------------------------------------------------------------------------------------
	// 6.回调
	public static void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
	}
	/***************************************************************************************
	******************************** public interface module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.获取
	public static Object get(int type) {
		return null;
	}
	//-------------------------------------------------------------------------------------
	// 2.监听
	public static void listen(SDKListener listener) {
		int listenerId = listener.getId();
		if (1 == listenerId) {	// 请求商品信息
			mHuaweiPay.querySkuDetails(listener);
		} else if (2 == listenerId) {	// 漏单查询
			mHuaweiPay.checkResupplyOrder(listener);
		}
	}
	//-------------------------------------------------------------------------------------
	// 3.注册
	public static void register(SDKListener listener) {
	}
	//-------------------------------------------------------------------------------------
	// 4.登录
	public static void login(SDKListener listener) {
	}
	//-------------------------------------------------------------------------------------
	// 5.注销
	public static void logout(SDKListener listener) {
		//退出和继续的广告页
		Commplatform.getInstance().gameResumeOrExit(mActivity,
			new CallbackListener<Integer>() {
				@Override
				public void callback(int arg0, Integer arg1) 
				{
					Log.e("cocos2d", "退出广告页被关闭，用户取消退出，继续游戏--resumeListener result = " + arg0);
					Toast.makeText(mActivity,"continue", Toast.LENGTH_LONG).show();
					//退出广告页被关闭，用户取消退出，继续游戏
				}
			},
			new CallbackListener<Integer>() {
				@Override
				public void callback(int arg0, Integer arg1) 
				{
					Toast.makeText(mActivity,"exit", Toast.LENGTH_LONG).show();
					//用户确认退出，关闭游戏
					AppActivity.javaProxy(302, "", 0);
				}
		});
	}
	//-------------------------------------------------------------------------------------
	// 6.支付
	public static void pay(SDKListener listener) {
		try {
			JSONObject jsonObj 		= new JSONObject(listener.getObject().toString());
			String orderId			= jsonObj.getString("order_id");
			String productId 		= jsonObj.getString("product_id");
			mHuaweiPay.pay(orderId, productId, listener);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	//-------------------------------------------------------------------------------------
	// 7.分享
	public static void share(SDKListener listener) {
		try {
			if (!ShareSDK.getPlatform(Facebook.NAME).isClientValid()) {
		        listener.onCallback(2, null);
		        Toast.makeText(mActivity, R.string.onekes_share_fail_no_client, Toast.LENGTH_LONG).show();
				return;
			}
			JSONObject jsonObj = new JSONObject(listener.getObject().toString());
			int shareType = jsonObj.getInt("share_type");
			if (1 == shareType) {
				sharePicture(jsonObj.getString("share_pic"), listener);
			} else if (2 == shareType) {
				shareUrl(jsonObj.getString("share_content"), jsonObj.getString("share_url"), listener);
			}
		} catch(Exception e) {
			Log.e("cocos2d", "share -> exception: " + e.toString());
			e.printStackTrace();
		}
	}
	//-------------------------------------------------------------------------------------
	// 8.记录
	public static void record(String data) {
		try {
			JSONObject jsonObj = new JSONObject(data);
			int eventType = jsonObj.getInt("event_type");
			String eventValue = "";
			if (!jsonObj.isNull("event_value")) {
				eventValue = jsonObj.getString("event_value");
			}
			switch (eventType) {
			case 1:		// 自定义事件(无参数)
				DCEvent.onEvent(eventValue);
				MobclickAgent.onEvent(mActivity, eventValue);
				break;
			case 2:		// 自定义事件(带参数)
				String event = "";
				HashMap<String, String> map = new HashMap<String, String>();
				Iterator<String> iter = jsonObj.keys();
				while (iter.hasNext()) {
					String key = (String)iter.next();
					String value = jsonObj.getString(key);
					if (key.equals("event")) {
						event = value;
					} else if (!key.equals("event_type") && !key.equals("event_value")) {
						map.put(key, value);
					}
				}
				if (!event.equals("")) {
					DCEvent.onEvent(event, map);
					MobclickAgent.onEvent(mActivity, event, map);
				}
				break;
			case 3:		// 支付事件
				String cash = jsonObj.getString("cash");
				String cashType = jsonObj.getString("cash_type");
				String item = jsonObj.getString("item");
				String amount = jsonObj.getString("amount");
				String price = jsonObj.getString("price");
				String source = jsonObj.getString("source");
				DCVirtualCurrency.paymentSuccess(Double.valueOf(cash), cashType, source);
				UMGameAgent.pay(Double.valueOf(cash), item, Integer.valueOf(amount), Double.valueOf(price), Integer.valueOf(source));
				break;
			case 4:		// 关卡开始
				DCLevels.begin(eventValue);
				UMGameAgent.startLevel(eventValue);
				break;
			case 5:		// 关卡成功
				DCLevels.complete(eventValue);
				UMGameAgent.finishLevel(eventValue);
				break;
			case 6:		// 关卡失败
				DCLevels.fail(eventValue, "");
				UMGameAgent.failLevel(eventValue);
				break;
			default:
				break;
			}
		} catch(Exception e) {
			Log.e("cocos2d", "share -> exception: " + e.toString());
			e.printStackTrace();
		}
	}
	//-------------------------------------------------------------------------------------
	// 9.更多游戏
	public static void moreGame(String data) {
	}
	//-------------------------------------------------------------------------------------
	// 10.应用页面
	public static void appPage(String data) {
	}
	//-------------------------------------------------------------------------------------
	// 11.显示关于
	public static void showAbout(String data) {
	}
	/***************************************************************************************
	******************************** private module
	***************************************************************************************/
	// 分享监听
	private static class SharePlatformActionListener implements PlatformActionListener {
		public SDKListener listener = null;
		
		@Override
		public void onComplete(Platform plat, int action, HashMap<String, Object> res) {
			Log.e("cocos2d", "share onComplete, " + plat.toString() + ", " + action);
			listener.onCallback(1, null);
	        Toast.makeText(mActivity, R.string.onekes_share_success, Toast.LENGTH_LONG).show();
		}
		
		@Override
		public void onError(Platform plat, int action, Throwable t) {
			Log.e("cocos2d", "share onError, " + plat.toString() + ", " + action + ", " + t.toString());
			listener.onCallback(2, null);
	        Toast.makeText(mActivity, R.string.onekes_share_fail, Toast.LENGTH_LONG).show();
		}
		
		@Override
		public void onCancel(Platform plat, int action) {
			Log.e("cocos2d", "share onCancel, " + plat.toString() + ", " + action);
			listener.onCallback(3, null);
	        Toast.makeText(mActivity, R.string.onekes_share_cancel, Toast.LENGTH_LONG).show();
		}
	}
		
	// 分享图片
	private static void sharePicture(String picture, SDKListener listener) {
		Log.e("cocos2d", "share picture");
//		ShareParams sp = new ShareParams();
//		sp.setShareType(Platform.SHARE_IMAGE);
//		sp.setImagePath(picture);
//		sp.setText(AppActivity.sActivity.getResources().getString(R.string.app_name));
//		ShareSDK.getPlatform(Facebook.NAME).share(sp);
		
		SharePlatformActionListener shareListener = new SharePlatformActionListener();
		shareListener.listener = listener;
		OnekeyShare oks = new OnekeyShare();
		oks.setSilent(false);
		oks.setDialogMode();
		oks.setPlatform(Facebook.NAME);
		oks.setCallback(shareListener);
		oks.setImagePath(picture);
		oks.setText("");
		oks.show(mActivity);
	}
	
	// 分享链接
	private static void shareUrl(String content, String url, SDKListener listener) {
		Log.e("cocos2d", "share url");
//		ShareParams sp = new ShareParams();
//		sp.setShareType(Platform.SHARE_TEXT);
//		sp.setText(content + " " + url);
//		ShareSDK.getPlatform(Facebook.NAME).share(sp);
		
		SharePlatformActionListener shareListener = new SharePlatformActionListener();
		shareListener.listener = listener;
		OnekeyShare oks = new OnekeyShare();
		oks.setSilent(false);
		oks.setDialogMode();
		oks.setPlatform(Facebook.NAME);
		oks.setCallback(shareListener);
		oks.setText(content + " " + url);
		oks.show(mActivity);
	}
}
