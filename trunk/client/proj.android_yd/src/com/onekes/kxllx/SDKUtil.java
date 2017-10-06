package com.onekes.kxllx;

import java.util.HashMap;
import java.util.Iterator;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import cn.cmgame.billing.api.BillingResult;
import cn.cmgame.billing.api.GameInterface;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;

import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.game.UMGameAgent;
import com.umeng.update.UmengDialogButtonListener;
import com.umeng.update.UmengDownloadListener;
import com.umeng.update.UmengUpdateAgent;
import com.umeng.update.UpdateConfig;
import com.umeng.update.UpdateStatus;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Handler;
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
	private static boolean mForceUpdate = false;
	private static String mOperatorType = "";
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
		// umeng
		UMGameAgent.setDebugMode(true);
	    UMGameAgent.init(activity);
	    // share sdk
	    ShareSDK.initSDK(activity);
	    //移动基地
	    GameInterface.initializeApp(activity);
	    // umeng update
	    UpdateConfig.setDebug(true);
	    UmengUpdateAgent.forceUpdate(mActivity);
	    UmengUpdateAgent.setUpdateOnlyWifi(false);
	    UmengUpdateAgent.setDeltaUpdate(false);
	    UmengUpdateAgent.setDialogListener(new UmengDialogButtonListener() {
	        @Override
	        public void onClick(int status) {
	            switch (status) {
	            case UpdateStatus.Update:
	                showForceUpdateDialog(1, R.string.update_in_doing);
	                break;
	            case UpdateStatus.Ignore:
	                showForceUpdateDialog(2, R.string.update_must);
	                break;
	            case UpdateStatus.NotNow:
	                showForceUpdateDialog(2, R.string.update_must);
	                break;
	            }
	        }
	    });
	    UmengUpdateAgent.setDownloadListener(new UmengDownloadListener() {
	        @Override
	        public void OnDownloadStart() {
	            Toast.makeText(mActivity, R.string.update_in_doing, Toast.LENGTH_LONG).show();
	        }
	        @Override
	        public void OnDownloadUpdate(int progress) {
//	        	Toast.makeText(mActivity, progress + "%", Toast.LENGTH_SHORT).show();
	        }
	        @Override
	        public void OnDownloadEnd(int result, String file) {
	        	switch (result) {
	        	case UpdateStatus.DOWNLOAD_COMPLETE_FAIL:
	        		showForceUpdateDialog(2, R.string.update_fail);
	        		break;
	        	case UpdateStatus.DOWNLOAD_COMPLETE_SUCCESS:
	        		android.os.Process.killProcess(android.os.Process.myPid());
	        		break;
	        	}
	        }
	    });
	}
	//-------------------------------------------------------------------------------------
	// 2.销毁
	public static void onDestroy(Activity activity) {
		UMGameAgent.onKillProcess(activity);
	}
	//-------------------------------------------------------------------------------------
	// 3.恢复
	public static void onResume(Activity activity) {
		UMGameAgent.onResume(activity);
		if (mForceUpdate) {
			AppActivity.sActivity.pause();
        }
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
		
	}
	//-------------------------------------------------------------------------------------
	// 7.其他
	public static void onOther(Activity activity, int type, Object obj) {
	}
	/***************************************************************************************
	******************************** public interface module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.获取
	public static String get(int type, String data) {
		if (1 == type) {	// 获取运营商类型
			return mOperatorType;
		} else if (2 == type) {	// 获取音效是否开启
			return GameInterface.isMusicEnabled() ? "true" : "false";
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
		   // 移动退出接口，含确认退出UI
	    // 如果外放渠道（非移动自有渠道）限制不允许包含移动退出UI，可用exitApp接口（无UI退出）
	    GameInterface.exit(mActivity, new GameInterface.GameExitCallback() {
	      @Override
	      public void onConfirmExit() {
	    	AppActivity.javaProxy(301, "", 0);
	      }

	      @Override
	      public void onCancelExit() {
	      }
	    });  
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
		GameInterface.viewMoreGames(mActivity);
	}
	//-------------------------------------------------------------------------------------
	// 10.应用页面
	public static void appPage(String data) {
	}
	//-------------------------------------------------------------------------------------
	// 11.免责声明
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
			String ydcode = "";
			if (jsonObj.has("ydcode")) {
				ydcode = jsonObj.getString("ydcode");
			}
			 // 计费结果的监听处理，合作方通常需要在收到SDK返回的onResult时，告知用户的购买结果
		    final GameInterface.IPayCallback payCallback = new GameInterface.IPayCallback() {	
				@Override
				public void onResult(int resultCode, String billingIndex, Object obj) {
					switch (resultCode) {
						case BillingResult.SUCCESS:
							if((BillingResult.EXTRA_SENDSMS_TIMEOUT+"").equals(obj.toString())){
							// 短信计费超时
								Log.e("cocos2d", "pay -> Message Time Out -> " + billingIndex);
								mPayListener.onCallback(2, null);
								Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
							}else{
								// 支付成功
								Log.e("cocos2d", "pay -> paySuccess -> " + billingIndex);
								mPayListener.onCallback(1, null);
								Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
							}
							break;
						case BillingResult.FAILED:
							// 支付失败
							Log.e("cocos2d", "pay -> payFailed ->   " +  billingIndex);
							mPayListener.onCallback(2, null);
							Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
							break;
						default:
							// 用户取消的支付
							Log.e("cocos2d", "pay -> payCanceled -> sdkType: " + billingIndex );
							mPayListener.onCallback(3, null);
							Toast.makeText(mActivity, R.string.onekes_pay_cancel, Toast.LENGTH_SHORT).show();
							break;
					}
				}
		    };
			GameInterface.doBilling(mActivity, true, true, ydcode, null, payCallback);
		} catch(Exception e) {
			Log.e("cocos2d", "pay Exception -> " + e );
			e.printStackTrace();
		}
	}
	
	// 处理分享
	private static void handleShare(SDKListener listener) {
		try {
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
		cn.sharesdk.wechat.moments.WechatMoments.ShareParams sp = new cn.sharesdk.wechat.moments.WechatMoments.ShareParams();
		sp.shareType = Platform.SHARE_IMAGE;
		sp.imagePath = picture;
		
		SharePlatformActionListener shareListener = new SharePlatformActionListener();
		shareListener.listener = listener;
		Platform wechatPlatform = ShareSDK.getPlatform(cn.sharesdk.wechat.moments.WechatMoments.NAME);
		wechatPlatform.setPlatformActionListener(shareListener);	// 设置分享事件回调
		wechatPlatform.share(sp);
	}
		
	// 分享链接
	private static void shareUrl(String content, String url, SDKListener listener) {
		Log.e("cocos2d", "share url");
		cn.sharesdk.wechat.moments.WechatMoments.ShareParams sp = new cn.sharesdk.wechat.moments.WechatMoments.ShareParams();
		sp.shareType = Platform.SHARE_TEXT;
		sp.title = AppActivity.sActivity.getResources().getString(R.string.app_name);
		sp.text = content + " " + url;
		sp.imageData = BitmapFactory.decodeResource(AppActivity.sActivity.getResources(), R.drawable.share_icon);
		
		SharePlatformActionListener shareListener = new SharePlatformActionListener();
		shareListener.listener = listener;
		Platform wechatPlatform = ShareSDK.getPlatform(cn.sharesdk.wechat.moments.WechatMoments.NAME);
		wechatPlatform.setPlatformActionListener(shareListener);	// 设置分享事件回调
		wechatPlatform.share(sp);
	}
	
	private static void showForceUpdateDialog(int type, int tipId) {
		AppActivity.sActivity.pause();
		mForceUpdate = true;
		if (1 == type) {			// 无按钮对话框
			new AlertDialog.Builder(mActivity)
			.setTitle(R.string.app_name)
			.setMessage(tipId)
			.setCancelable(false)
			.show();
		} else if (2 == type) {		// 确定按钮对话框
			new AlertDialog.Builder(mActivity)
			.setTitle(R.string.app_name)
			.setMessage(tipId)
			.setPositiveButton(R.string.onekes_queding, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface arg0, int arg1) {
					android.os.Process.killProcess(android.os.Process.myPid());
				}
			})
			.setCancelable(false)
			.show();
		}
	}
}
