/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.util.HashMap;
import java.util.Iterator;

import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lib.*;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.widget.Toast;

import com.zhexin.hdzdy.R;
import com.onekes.kxllx.CommonUtil;
import com.onekes.kxllx.ShareUtil;
import com.onekes.kxllx.PayUtil;

public class AppActivity extends Cocos2dxActivity {
	public static AppActivity sActivity				= null;
	public static Handler sHandler					= null;
	// message type define
	public static final int MT_SHARE				= 10;
	public static final int MT_SHARE_SUCCESS		= 11;
	public static final int MT_SHARE_FAIL			= 12;
	public static final int MT_SHARE_CANCEL			= 13;
	public static final int MT_PAY					= 20;
	public static final int MT_PAY_SUCCESS			= 21;
	public static final int MT_PAY_FAIL				= 22;
	public static final int MT_PAY_CANCEL			= 23;
	// lua handler
	private static int mShareHandler				= 0;
	private static int mPayHandler					= 0;
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		sActivity = this;
		sHandler = new Handler() {
			public void handleMessage(Message msg) {
				Log.e("cocos2d-x", "handleMessage -> msg: " + msg.what);
				int luaHandler = 0;
				String result = "";
				boolean showToast = false;
				switch (msg.what) { 
					case MT_SHARE:
						ShareUtil.share(msg.obj.toString());
						break;
					case MT_SHARE_SUCCESS:
						luaHandler = mShareHandler;
						mShareHandler = 0;
						result = "success";
						showToast = true;
						break;
					case MT_SHARE_FAIL:
						luaHandler = mShareHandler;
						mShareHandler = 0;
						result = "fail";
						showToast = true;
						break;
					case MT_SHARE_CANCEL:
						luaHandler = mShareHandler;
						mShareHandler = 0;
						result = "cancel";
						showToast = true;
						break;
					case MT_PAY:
						PayUtil.pay(msg.obj.toString());
						break;
					case MT_PAY_SUCCESS:
						luaHandler = mPayHandler;
						mPayHandler = 0;
						result = "success";
						showToast = true;
						break;
					case MT_PAY_FAIL:
						luaHandler = mPayHandler;
						mPayHandler = 0;
						result = "fail";
						showToast = true;
						break;
					case MT_PAY_CANCEL:
						luaHandler = mPayHandler;
						mPayHandler = 0;
						result = "cancel";
						showToast = true;
						break;
				}
				callLuaFunctionWithId(sActivity, luaHandler, result);
				if (showToast) {
					if (msg.obj instanceof Integer) {
						Toast.makeText(sActivity, Integer.parseInt(msg.obj.toString()), msg.arg1).show();
					} else if (msg.obj instanceof String) {
						Toast.makeText(sActivity, msg.obj.toString(), msg.arg1).show();
					}
				}
			}
		};
		CommonUtil.onCreate(this);
		PayUtil.onCreate(this);
	    ShareUtil.onCreate(this);
	}
	
	public boolean onKeyUp(int keyCode, KeyEvent event) {
    	// exit program when key back is entered
    	if (KeyEvent.KEYCODE_BACK == keyCode) {
    		javaProxy(302, "", 0);
    	}
        return super.onKeyDown(keyCode, event);
    }
	
	public void onResume() {
        super.onResume();
        CommonUtil.onResume(this);
        PayUtil.onResume(this);
        ShareUtil.onResume(this);
    }
    
    public void onPause() {
        super.onPause();
        CommonUtil.onPause(this);
        PayUtil.onPause(this);
        ShareUtil.onPause(this);
    }
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		CommonUtil.onActivityResult(requestCode, resultCode, data);
		PayUtil.onActivityResult(requestCode, resultCode, data);
		ShareUtil.onActivityResult(requestCode, resultCode, data);
	}
    
	/***************************************************************************************
	******************************** BEGIN lua interface module
	***************************************************************************************/
	public static void callLuaFunctionWithId(Cocos2dxActivity activity, final int funcId, final String param) {
		Log.e("cocos2d-x", "callLuaFunctionWithId -> funcId: " + funcId + ", param: " + param);
		if (funcId > 0) {
			activity.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcId, param);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(funcId);
				}
			});
		}
	}
	
	public static void callLuaGlobalFunctionWithName(Cocos2dxActivity activity, final String funcName, final String param) {
		Log.e("cocos2d-x", "callLuaGlobalFunctionWithName -> funcName: " + funcName + ", param: " + param);
		if (!funcName.equals("")) {
			activity.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(funcName, param);
				}
			});
		}
	}
	
	public static String javaProxy(int type, String data, int handler) {
		Log.e("cocos2d-x", "javaProxy -> type: " + type + ", data: " + data + ", handler: " + handler);
		try {
			data = EncodingUtils.getString(data.getBytes(), "UTF-8");
			switch (type) {
			case 101:		// get mac address
				String macAddress = ((WifiManager)sActivity.getSystemService(WIFI_SERVICE)).getConnectionInfo().getMacAddress();
				if (null == macAddress){
					return "_";
				}
				return macAddress;
			case 102:		// get sim state
				TelephonyManager telManager = (TelephonyManager)sActivity.getSystemService(Context.TELEPHONY_SERVICE);
				if (TelephonyManager.SIM_STATE_READY != telManager.getSimState()) {
					return "SIM_NULL";
				}
		        String operator = telManager.getSimOperator(); 
		    	if (operator.equals("46000") || operator.equals("46002") || operator.equals("46007")) {
		    		return "SIM_YD";		// 移动
				} else if (operator.equals("46001") || operator.equals("46006")) {
		    		return "SIM_LT";		// 联通
		    	} else if (operator.equals("46003") || operator.equals("46005")) {
		    		return "SIM_DX";		// 电信
		    	} else {
		    		return "SIM_UNKNOWN";	// 未知
		    	}
			case 103:		// get channel id
				ApplicationInfo info = sActivity.getPackageManager().getApplicationInfo(sActivity.getPackageName(), PackageManager.GET_META_DATA);
				return String.valueOf(info.metaData.getInt("DC_CHANNEL"));
			case 104:		// get device id
				return Secure.getString(sActivity.getContentResolver(), Secure.ANDROID_ID);
			case 105:		// get bundle version
				return sActivity.getPackageManager().getPackageInfo(sActivity.getPackageName(), 0).versionName;
			case 201:		// share
				Message shareMsg = new Message();
				shareMsg.what = MT_SHARE;
				shareMsg.obj = data;
		        mShareHandler = handler;
		        sHandler.sendMessage(shareMsg);
				break;
			case 202:		// pay
				Message payMsg = new Message();
				payMsg.what = MT_PAY;
				payMsg.obj = data;
				mPayHandler = handler;
		        sHandler.sendMessage(payMsg);
				break;
			case 203:		// record custom event
				CommonUtil.recordEvent(data);
				break;
			case 204:		// record pay event
				CommonUtil.recordPay(data);
				break;
			case 205:		// record level start event
				CommonUtil.recordLevelStart(data);
				break;
			case 206:		// record level finish event
				CommonUtil.recordLevelFinish(data);
				break;
			case 207:		// record level fail event
				CommonUtil.recordLevelFail(data);
				break;
			case 208:		// record custom event with value
				String event208 = "";
				HashMap<String, String> map208 = new HashMap<String, String>();
				JSONObject obj208 = new JSONObject(data);
				Iterator<String> iter208 = obj208.keys();
				while (iter208.hasNext()) {
					String key208 = (String)iter208.next();
					String value208 = obj208.getString(key208);
					if (key208.equals("event")) {
						event208 = value208;
					} else {
						map208.put(key208, value208);
					}
				}
				if (!event208.equals("")) {
					CommonUtil.recordEvent(event208, map208);
				}
				break;
			case 301:		// copy string
				final String tempStr = data;
				sActivity.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						if (android.os.Build.VERSION.SDK_INT > 11) {
							android.content.ClipboardManager c = (android.content.ClipboardManager) sActivity.getSystemService(sActivity.CLIPBOARD_SERVICE);
							c.setText(tempStr);
						} else {
							android.text.ClipboardManager c = (android.text.ClipboardManager) sActivity.getSystemService(sActivity.CLIPBOARD_SERVICE);
							c.setText(tempStr);
						}
					}
				});
				break;
			case 302:		// exit
				new AlertDialog.Builder(sActivity)
				.setTitle(R.string.exit_dialog_title)
				.setMessage(R.string.exit_dialog_msg)
				.setPositiveButton(R.string.exit_dialog_btn_yes, new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface arg0, int arg1) {
						// TODO Auto-generated method stub
						callLuaGlobalFunctionWithName(sActivity, "applicationDidEnterBackground", "");
						CommonUtil.onDestroy(sActivity);
						PayUtil.onDestroy(sActivity);
						ShareUtil.onDestroy(sActivity);
						android.os.Process.killProcess(android.os.Process.myPid());
					}
				})
				.setNegativeButton(R.string.exit_dialog_btn_no, null)
				.show();
				break;
			case 303:		// open more
				break;
			case 304:		// register notify
				break;
			case 305:		// add notify
				break;
			case 306:		// remove notify by type
				break;
			case 307:		// remove notify by key
				break;
			case 308:		// clear noitfy
				break;
			case 309:		// register
				CommonUtil.register(sActivity);
				break;
			case 310:		// login
				CommonUtil.login(sActivity);
				break;
			case 311:		// logout
				CommonUtil.logout(sActivity);
				break;
			default:
				break;
			}
		} catch (Exception e) {
			Log.e("cocos2d-x", "javaProxy -> exception:\n" + e.toString());
			e.printStackTrace();
		}
		return "";
	}
	/***************************************************************************************
	******************************** END lua interface module
	***************************************************************************************/
}
