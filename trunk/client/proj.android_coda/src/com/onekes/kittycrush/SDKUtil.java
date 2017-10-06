package com.onekes.kittycrush;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import cn.sharesdk.facebook.Facebook;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.onekeyshare.OnekeyShare;

import com.codapayments.sdk.CodaSDK;
import com.codapayments.sdk.model.ItemInfo;
import com.codapayments.sdk.model.PayInfo;
import com.dataeye.DCAgent;
import com.dataeye.DCEvent;
import com.dataeye.DCReportMode;
import com.dataeye.DCVirtualCurrency;
import com.dataeye.plugin.DCLevels;
import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.game.UMGameAgent;
import com.onekes.kittycrush.SDKListener;
import com.codapayments.sdk.model.PayResult;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

public final class SDKUtil {
	private static Activity mActivity = null;
	private static Handler mHandler = null;
	private static final int MT_PAY = 10;
	private static final int MT_PAY_SUCCESS = 11;
	private static final int MT_PAY_FAIL = 12;
	private static final int MT_PAY_CANCEL = 13;
	private static final int MT_SHARE = 20;
	private static final int MT_SHARE_SUCCESS = 21;
	private static final int MT_SHARE_FAIL = 22;
	private static final int MT_SHARE_CANCEL = 23;
	private static SDKListener mPayListener = null;
//	private static GooglePlayPay mGoogleplayPay = null;
	/***************************************************************************************
	******************************** public callback module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.创建
	public static void onCreate(Activity activity) {
		mActivity = activity;
		mHandler = new Handler() {
			public void handleMessage(Message msg) {
				if (MT_PAY == msg.what) {
	    			handlePay((SDKListener)msg.obj);
	    		} else if (MT_PAY_SUCCESS == msg.what) {
	    		} else if (MT_PAY_FAIL == msg.what) {
	    		} else if (MT_PAY_CANCEL == msg.what) {
	    		} else if (MT_SHARE == msg.what) {
	    			handleShare((SDKListener)msg.obj);
	    		} else if (MT_SHARE_SUCCESS == msg.what) {
	    		} else if (MT_SHARE_FAIL == msg.what) {
	    		} else if (MT_SHARE_CANCEL == msg.what) {
	    		}
			}
		};
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
		// google play
//		mGoogleplayPay = new GooglePlayPay(activity, null);
	}
	//-------------------------------------------------------------------------------------
	// 2.销毁
	public static void onDestroy(Activity activity) {
		DCAgent.onKillProcessOrExit();
	}
	//-------------------------------------------------------------------------------------
	// 3.恢复
	public static void onResume(Activity activity) {
		DCAgent.onResume(activity);
	}
	//-------------------------------------------------------------------------------------
	// 4.暂停
	public static void onPause(Activity activity) {
		UMGameAgent.onPause(activity);
	}
	//-------------------------------------------------------------------------------------
	// 5.停止
	public static void onStop(Activity activity) {
	}
	//-------------------------------------------------------------------------------------
	// 6.活动
	public static void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
//		if (null != mGoogleplayPay.helper && mGoogleplayPay.helper.handleActivityResult(requestCode, resultCode, data)) {
//			Log.e("cocos2d", "PayUtil -> onActivityResult -> success, requestCode: " + requestCode + ", resultCode: " + resultCode);
//		} else if (null != mPayListener) {
//			Log.e("cocos2d", "PayUtil -> onActivityResult -> fail, requestCode: " + requestCode + ", resultCode: " + resultCode);
//			mPayListener.onCallback(2, null);
//		    Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
//		}
	}
	//-------------------------------------------------------------------------------------
	// 7.其他
	public static void onOther(Activity activity, int type, Object obj) {
		PayResult payResult = (PayResult)obj;
		if (null == payResult && null == mPayListener) {
			return;
		}
		if (0 == payResult.getResultCode()) {	// success
			mPayListener.onCallback(1, null);
		    Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
		} else {
			mPayListener.onCallback(2, null);
			if (payResult.getResultDesc() != null && payResult.getResultDesc().length() > 0) {
				Toast.makeText(mActivity, payResult.getResultDesc(), Toast.LENGTH_SHORT).show();
			} else {
				Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
			}
		}
	}
	/***************************************************************************************
	******************************** public interface module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.获取
	public static String get(int type, String data) {
		if (1 == type) {	// 获取运营商类型
		} else if (2 == type) {	// 获取音效是否开启
		}
		return "";
	}
	//-------------------------------------------------------------------------------------
	// 2.监听
	public static void listen(SDKListener listener) {
		int listenerId = listener.getId();
		if (1 == listenerId) {	// 请求商品信息
		} else if (2 == listenerId) {	// 漏单查询
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
		new AlertDialog.Builder(mActivity)
		.setTitle(R.string.onekes_tishi)
		.setMessage(R.string.onekes_exit_msg)
		.setPositiveButton(R.string.onekes_queding, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface arg0, int arg1) {
				AppActivity.javaProxy(301, "", 0);
			}
		})
		.setNegativeButton(R.string.onekes_quxiao, null)
		.show();
	}
	//-------------------------------------------------------------------------------------
	// 6.支付
	public static void pay(SDKListener listener) {
		Message msg = new Message();
		msg.what = MT_PAY;
		msg.obj = listener;
		mHandler.sendMessage(msg);
	}
	//-------------------------------------------------------------------------------------
	// 7.分享
	public static void share(SDKListener listener) {
		Message msg = new Message();
		msg.what = MT_SHARE;
		msg.obj = listener;
		mHandler.sendMessage(msg);
	}
	//-------------------------------------------------------------------------------------
	// 8.记录
	public static void record(String data) {
		try {
			JSONObject jsonObj = new JSONObject(data);
			switch (jsonObj.getInt("tag")) {
			case 1:		// 自定义事件(无参数)
				MobclickAgent.onEvent(mActivity, jsonObj.getString("event"));
				break;
			case 2:		// 自定义事件(带参数)
				jsonObj.remove("tag");
				String event = "";
				HashMap<String, String> map = new HashMap<String, String>();
				Iterator<String> iter = jsonObj.keys();
				while (iter.hasNext()) {
					String key = (String)iter.next();
					String value = jsonObj.getString(key);
					if (key.equals("event")) {
						event = value;
					} else {
						map.put(key, value);
					}
				}
				if (!event.equals("")) {
					MobclickAgent.onEvent(mActivity, event, map);
				}
				break;
			case 3:		// 支付事件
				String cash = jsonObj.getString("cash");
				String item = jsonObj.getString("item");
				String amount = jsonObj.getString("amount");
				String price = jsonObj.getString("price");
				String source = jsonObj.getString("source");
				UMGameAgent.pay(Double.valueOf(cash), item, Integer.valueOf(amount), Double.valueOf(price), Integer.valueOf(source));
				break;
			case 4:		// 关卡开始
				UMGameAgent.startLevel(jsonObj.getString("level"));
				break;
			case 5:		// 关卡成功
				UMGameAgent.finishLevel(jsonObj.getString("level"));
				break;
			case 6:		// 关卡失败
				UMGameAgent.failLevel(jsonObj.getString("level"));
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
//		Intent intent312 = new Intent("com.google.android.finsky.VIEW_MY_DOWNLOADS");
//		intent312.setComponent(new ComponentName("com.android.vending", "com.android.vending.AssetBrowserActivity"));
//		intent312.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//		sActivity.startActivity(intent312);
		
		new AlertDialog.Builder(mActivity)
		.setTitle(R.string.onekes_tishi)
		.setMessage(R.string.onekes_remark_msg)
		.setPositiveButton(R.string.onekes_queding, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface arg0, int arg1) {
				Intent intent312 = new Intent();
				intent312.setAction(Intent.ACTION_VIEW);
				intent312.setData(Uri.parse("market://details?id=" + mActivity.getPackageName()));
				mActivity.startActivity(intent312);
			}
		})
		.setNegativeButton(R.string.onekes_quxiao, null)
		.setCancelable(false)
		.show();
	}
	//-------------------------------------------------------------------------------------
	// 11.显示关于
	public static void showAbout(String data) {
	}
	/***************************************************************************************
	******************************** private module
	***************************************************************************************/
	// 处理支付
	private static void handlePay(SDKListener listener) {
		mPayListener = listener;
		try {
			JSONObject jsonObj = new JSONObject(listener.getObject().toString());
			int payType				= jsonObj.getInt("pay_type");
			String orderId			= jsonObj.getString("order_id");
			String totalFee 		= jsonObj.getString("total_fee");
			String productId 		= jsonObj.getString("product_id");
			String productName		= jsonObj.getString("product_name");
			String productDesc		= jsonObj.getString("product_desc");
			String company 			= jsonObj.getString("company");
			String servicePhone		= jsonObj.getString("service_phone");
			String gpcode			= "";
			if (jsonObj.has("gpcode")) {
				gpcode = jsonObj.getString("gpcode");
			}
//			if (!gpcode.equals("")) {
//				mGoogleplayPay.pay(gpcode, listener);
//			}
			ArrayList<ItemInfo> items = new ArrayList<ItemInfo>();
			items.add(new ItemInfo(totalFee, productName, Double.parseDouble(totalFee), (short)0));
			PayInfo info = new PayInfo(CONFIG.IDN_API_KEY, orderId, CONFIG.IDN_COUNTRY_CODE, CONFIG.IDN_CURRENCY_CODE, CONFIG.ENVIRONMENT, items);
			CodaSDK.getInstance(mActivity, AppActivity.class).pay(info);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	// 处理分享
	private static void handleShare(SDKListener listener) {
		try {
			if (!ShareSDK.getPlatform(Facebook.NAME).isClientValid()) {
				listener.onCallback(2, null);
				Toast.makeText(mActivity, R.string.onekes_share_fail_no_client, Toast.LENGTH_LONG).show();
				return;
			}
			JSONObject jsonObj = new JSONObject(listener.getObject().toString());
			int shareType = jsonObj.getInt("share_type");
			if (1 == shareType) {
				sharePicture(jsonObj.getString("share_pic"));
			} else if (2 == shareType) {
				shareUrl(jsonObj.getString("share_content"), jsonObj.getString("share_url"));
			}
		} catch(Exception e) {
			Log.e("cocos2d", "share -> exception: " + e.toString());
			e.printStackTrace();
		}
	}
	
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
