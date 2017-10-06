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

import cn.egame.terminal.paysdk.EgamePay;
import cn.egame.terminal.paysdk.EgamePayListener;
import cn.egame.terminal.sdk.log.EgameAgent;

import com.ffcs.inapppaylib.PayHelper;
import com.ffcs.inapppaylib.bean.Constants;
import com.ffcs.inapppaylib.bean.response.BaseResponse;

public class PayUtil {
	private static Activity mActivity = null;
	// pay type define
	private static final int PT_LITTLE	= 1;
	private static final int PT_MANY	= 2;
	
	public static void onCreate(Activity activity) {
		mActivity = activity;
		EgamePay.init(activity);
	}
	
	public static void onResume(Activity activity) {
		EgameAgent.onResume(activity);
	}
	
	public static void onPause(Activity activity) {
		EgameAgent.onPause(activity);
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	}
	
	public static void onDestroy(Activity activity) {
		EgamePay.exit(activity);
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
				payDX_inapppay(dxCode);
//				payDX_egame(dxCode, productName);
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
				payDX_inapppay(dxCode);
//				payDX_egame(dxCode, productName);
			}
		} else if (simState.equals("SIM_LT")) {
		} else if (simState.equals("SIM_YD")) {
		} else {	// SIM_UNKNOWN
		}
	}
	
	// 电信支付,inapppay
	private static void payDX_inapppay(String dxCode) {
		PayHelper payHelper = PayHelper.getInstance(mActivity);
		payHelper.init(CONFIG.DX_APP_ID, CONFIG.DX_APP_KEY);
		Handler handler = new Handler() {
			public void handleMessage(android.os.Message msg) {
				Log.e("kxllx", "payDX_inapppay, msg: " + msg.what);
				BaseResponse resp = null;
				Message appMsg = null;
				switch (msg.what) {
					case Constants.RESULT_DLG_CLOSE:
					case Constants.RESULT_PAY_SUCCESS:
						resp = (BaseResponse)msg.obj;
						appMsg = new Message();
						appMsg.what = AppActivity.MT_PAY_SUCCESS;
						if (null == resp) {
							appMsg.obj = R.string.onekes_pay_success;
						} else {
							appMsg.obj = resp.getRes_code() + "1:" + resp.getRes_message();
						}
						appMsg.arg1 = Toast.LENGTH_SHORT;
				        AppActivity.sHandler.sendMessage(appMsg);
						break;
					case Constants.RESULT_VALIDATE_FAILURE:
						resp = (BaseResponse)msg.obj;
						appMsg = new Message();
						appMsg.what = AppActivity.MT_PAY_FAIL;
						if (null == resp) {
							appMsg.obj = R.string.onekes_pay_fail;
						} else {
							appMsg.obj = resp.getRes_code() + "2:" + resp.getRes_message();
						}
						appMsg.arg1 = Toast.LENGTH_SHORT;
				        AppActivity.sHandler.sendMessage(appMsg);
						break;
					case Constants.RESULT_PAY_FAILURE:
						resp = (BaseResponse)msg.obj;
						appMsg = new Message();
						appMsg.what = AppActivity.MT_PAY_FAIL;
						if (null == resp) {
							appMsg.obj = R.string.onekes_pay_fail;
						} else {
							appMsg.obj = resp.getRes_code() + "3:" + resp.getRes_message();
						}
						appMsg.arg1 = Toast.LENGTH_SHORT;
				        AppActivity.sHandler.sendMessage(appMsg);
						break;
					default:
						appMsg = new Message();
						appMsg.what = AppActivity.MT_PAY_FAIL;
						appMsg.obj = "pay fail, error code: " + String.valueOf(msg.what);
						appMsg.arg1 = Toast.LENGTH_SHORT;
				        AppActivity.sHandler.sendMessage(appMsg);
						break;
				}
			};
		};
		payHelper.pay(mActivity, dxCode, handler, "onekes");
	}
	
	// 电信支付,egame
	private static void payDX_egame(String dxCode, String produceName) {
		HashMap payParams = new HashMap();
		payParams.put(EgamePay.PAY_PARAMS_KEY_TOOLS_ALIAS, dxCode);
		payParams.put(EgamePay.PAY_PARAMS_KEY_TOOLS_DESC, produceName);
		
		final Builder dialog = new Builder(mActivity);
		dialog.setTitle("提示");
		
		EgamePay.pay(mActivity, payParams, new EgamePayListener() {
			@Override
			public void paySuccess(Map params) {
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_SUCCESS;
				AppActivity.sHandler.sendMessage(msg);
				dialog.setMessage(params.get(EgamePay.PAY_PARAMS_KEY_TOOLS_DESC) + "支付成功");
				dialog.show();
			}
			
			@Override
			public void payFailed(Map params, int errorInt) {
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_FAIL;
				AppActivity.sHandler.sendMessage(msg);
				dialog.setMessage(params.get(EgamePay.PAY_PARAMS_KEY_TOOLS_DESC) + "支付失败：错误代码：" + errorInt);
				dialog.show();
			}
			
			@Override
			public void payCancel(Map params) {
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_CANCEL;
				AppActivity.sHandler.sendMessage(msg);
				dialog.setMessage(params.get(EgamePay.PAY_PARAMS_KEY_TOOLS_DESC) + "支付已取消");
				dialog.show();
			}
		});
	}
}


