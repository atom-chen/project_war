package com.onekes.kxllx;

import java.util.HashMap;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;

import com.dataeye.DCAgent;
import com.dataeye.DCEvent;
import com.dataeye.DCReportMode;
import com.dataeye.DCVirtualCurrency;
import com.dataeye.plugin.DCLevels;
import com.umeng.analytics.MobclickAgent;

public class CommonUtil {
	public static void onCreate(Activity activity) {
		// set if show log during running
		DCAgent.setDebugMode(true);
	    DCAgent.setReportMode(DCReportMode.DC_DEFAULT);
	    MobclickAgent.setDebugMode(true);
	    MobclickAgent.openActivityDurationTrack(false);
	    MobclickAgent.updateOnlineConfig(activity);
	}
	
	public static void onResume(Activity activity) {
		DCAgent.onResume(activity);
        MobclickAgent.onResume(activity);
	}
	
	public static void onPause(Activity activity) {
		DCAgent.onPause(activity);
        MobclickAgent.onPause(activity);
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	}
	
	public static void onDestroy(Activity activity) {
		DCAgent.onKillProcessOrExit();
		MobclickAgent.onKillProcess(activity);
	}
	
	public static void register(Activity activity) {
	}
	
	public static void login(Activity activity) {
	}
	
	public static void logout(Activity activity) {
	}
	
	public static void recordEvent(String data) {
		DCEvent.onEvent(data);
	}
	
	public static void recordEvent(String event, HashMap<String, String> value) {
		DCEvent.onEvent( event, value);
	}
	
	public static void recordPay(String data) {
		try {
			JSONObject jsonObj = new JSONObject(data);
			String cash = jsonObj.getString("cash");
			String cashType = jsonObj.getString("cash_type");
			String source = jsonObj.getString("source");
			DCVirtualCurrency.paymentSuccess(Double.valueOf(cash), cashType, source);
		} catch (Exception e) {
		}
	}
	
	public static void recordLevelStart(String level) {
		DCLevels.begin(level);
	}
	
	public static void recordLevelFinish(String level) {
		DCLevels.complete(level);
	}
	
	public static void recordLevelFail(String level) {
		DCLevels.fail(level, "");
	}
}


