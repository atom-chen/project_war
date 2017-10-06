package com.onekes.kxllx;

import com.onekes.kxllx.R;
import java.util.HashMap;

import android.app.Activity;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;
import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lua.AppActivity;

public class ShareUtil {
	// share channel define
	private static final int SC_NONE	= 0;
	private static final int SC_WECHAT	= 1;
	
	public static void onCreate(Activity activity) {
	}
	
	public static void onResume(Activity activity) {
	}
	
	public static void onPause(Activity activity) {
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	}
	
	public static void onDestroy(Activity activity) {
	}
	
	public static void share(String shareJson) {
		try {
			shareJson = EncodingUtils.getString(shareJson.getBytes(), "UTF-8");
			JSONObject jsonObj = new JSONObject(shareJson);
			int shareChannel = jsonObj.getInt("share_channel");
			if (SC_NONE == shareChannel) {
			} else if (SC_WECHAT == shareChannel) {
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}


