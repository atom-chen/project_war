package com.onekes.kxllx;

import com.onekes.kxllx.R;
import com.onekes.kxllx.CONFIG;
import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.app.AlertDialog.Builder;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;
import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lua.AppActivity;

public class PayUtil {
	private static Activity mActivity = null;
	// pay type define
	private static final int PT_LITTLE	= 1;
	private static final int PT_MANY	= 2;
	
	public static void onCreate(Activity activity) {
		mActivity = activity;
	}
	
	public static void onResume(Activity activity) {
	}
	
	public static void onPause(Activity activity) {
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	}
	
	public static void onDestroy(Activity activity) {
	}
	
	public static void pay(String payJson) {
		try {
			payJson = EncodingUtils.getString(payJson.getBytes(), "UTF-8");
			JSONObject jsonObj = new JSONObject(payJson);
			int payType				= jsonObj.getInt("pay_type");
			String orderId			= jsonObj.getString("order_id");
			String totalFee 		= jsonObj.getString("total_fee");
			String productId 		= jsonObj.getString("product_id");
			String productName		= jsonObj.getString("product_name");
			String productDesc		= jsonObj.getString("product_desc");
			String company 			= jsonObj.getString("company");
			String servicePhone		= jsonObj.getString("service_phone");
			String dxCode 			= "0";
			if (jsonObj.has("tycode")) {
				dxCode = jsonObj.getString("tycode");
			}
			String ltCode 			= "0";
			if (jsonObj.has("ltcode")) {
				ltCode = jsonObj.getString("ltcode");
			}
			String ydCode 			= "0";
			if (jsonObj.has("ydcode")) {
				ydCode = jsonObj.getString("ydcode");
			}
			if (PT_LITTLE == payType) {
				payLittle(orderId, totalFee, productId, productName, productDesc, company, servicePhone, dxCode, ltCode, ydCode);
			} else if (PT_MANY == payType) {
				payMany(orderId, totalFee, productId, productName, productDesc, company, servicePhone, dxCode, ltCode, ydCode);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	// 小额支付
	private static void payLittle(String orderId, String totalFee, String productId, String productName, String productDesc, String company, String servicePhone, String dxCode, String ltCode, String ydCode) {
		String simState = AppActivity.javaProxy(102, "", 0);
		Log.e("kxllx", "payLittle -> simState: " + simState);
		if (simState.equals("SIM_NULL")) {	
		} else if (simState.equals("SIM_DX")) {
			if (dxCode.equals("0")) {
			} else {
			}
		} else if (simState.equals("SIM_LT")) {
		} else if (simState.equals("SIM_YD")) {	
		} else {	// SIM_UNKNOWN
		}
	}
	
	// 大额支付
	private static void payMany(String orderId, String totalFee, String productId, String productName, String productDesc, String company, String servicePhone, String dxCode, String ltCode, String ydCode) {
		String simState = AppActivity.javaProxy(102, "", 0);
		Log.e("kxllx", "payMany -> simState: " + simState);
		if (simState.equals("SIM_NULL")) {
		} else if (simState.equals("SIM_DX")) {
			if (dxCode.equals("0")) {
			} else {
			}
		} else if (simState.equals("SIM_LT")) {
		} else if (simState.equals("SIM_YD")) {
		} else {	// SIM_UNKNOWN
		}
	}
}


