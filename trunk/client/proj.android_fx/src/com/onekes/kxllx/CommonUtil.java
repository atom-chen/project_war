package com.onekes.kxllx;

import java.util.HashMap;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import com.onekes.kxllx.CONFIG;

import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.game.UMGameAgent;
import com.umeng.update.UmengDialogButtonListener;
import com.umeng.update.UmengDownloadListener;
import com.umeng.update.UmengUpdateAgent;
import com.umeng.update.UpdateConfig;
import com.umeng.update.UpdateStatus;

import com.fetion.shareplatform.func.login.LoginFuncEntry;
import com.fetion.shareplatform.listener.IShareplatformAuthListener;
import com.fetion.shareplatform.model.OauthAccessToken;

public class CommonUtil {
	private static Activity mActivity = null;
	private static boolean mForceUpdate = false;
	
	public static void onCreate(Activity activity) {
		mActivity = activity;
		// set if show log during running
		UMGameAgent.setDebugMode(true);
	    UMGameAgent.init(mActivity);
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
	
	public static void onDestroy(Activity activity) {
		UMGameAgent.onKillProcess(activity);
	}
	
	public static void onResume(Activity activity) {
		UMGameAgent.onResume(activity);
		if (mForceUpdate) {
			AppActivity.sActivity.pause();
        }
	}
	
	public static void onPause(Activity activity) {
		UMGameAgent.onPause(activity);
	}
	
	public static void onStop(Activity activity) {
	}
	
	public static void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
	}
	
	public static void register(Activity activity) {
	}
	
	public static void login(Activity activity) {
		LoginFuncEntry.fetionLogin(activity, CONFIG.FX_APP_KEY, new IShareplatformAuthListener() {
			@Override
			public void onCompleted(OauthAccessToken token) {
				Log.e("cocos2d-x", "feixinLoginListener -> onFailure -> fetionLogin -> onCompleted");
				if (null == token) {	// token获取失败
					Log.e("cocos2d-x", "feixinLoginListener -> onFailure -> fetionLogin -> onCompleted -> token is null");
				} else {				// token获取成功
					Log.e("cocos2d-x", "feixinLoginListener -> onFailure -> fetionLogin -> onCompleted -> token: " + token.access_token);
				}
			}
			
			@Override
			public void onFailure(String message) {
				Log.e("cocos2d-x", "feixinLoginListener -> onFailure -> fetionLogin -> onFailure -> message: " + message);
			}
			
			@Override
			public void onCancle() {
				Log.e("cocos2d-x", "feixinLoginListener -> onFailure -> fetionLogin -> onCancle");
			}
		});
	}
	
	public static void logout(Activity activity) {
		if (LoginFuncEntry.fetionLogout(activity)){	
			Toast.makeText(activity, "注销成功", Toast.LENGTH_SHORT).show();;
		} else {
			Toast.makeText(activity, "注销不成功，请重试", Toast.LENGTH_SHORT).show();
		}
	}
	
	public static void openMore(Activity activity) {
	}
	
	public static void openAppPage(Activity activity) {
	}
	
	public static void recordEvent(String event) {
		MobclickAgent.onEvent(mActivity, event);
	}
	
	public static void recordEvent(String event, HashMap<String, String> value) {
		MobclickAgent.onEvent(mActivity, event, value);
	}
	
	public static void recordPay(String data) {
		try {
			JSONObject jsonObj = new JSONObject(data);
			String cash = jsonObj.getString("cash");
			String cashType = jsonObj.getString("cash_type");
			String item = jsonObj.getString("item");
			String amount = jsonObj.getString("amount");
			String price = jsonObj.getString("price");
			String source = jsonObj.getString("source");
			UMGameAgent.pay(Double.valueOf(cash), item, Integer.valueOf(amount), Double.valueOf(price), Integer.valueOf(source));
		} catch (Exception e) {
		}
	}
	
	public static void recordLevelStart(String level) {
		UMGameAgent.startLevel(level);
	}
	
	public static void recordLevelFinish(String level) {
		UMGameAgent.finishLevel(level);
	}
	
	public static void recordLevelFail(String level) {
		UMGameAgent.failLevel(level);
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
			.setPositiveButton(R.string.update_sure, new DialogInterface.OnClickListener() {
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


