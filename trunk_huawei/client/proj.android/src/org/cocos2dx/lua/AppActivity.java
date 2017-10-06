/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d.org

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

import java.util.List;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.WindowManager;

import com.onekes.kittycrush.hwgame.R;
import com.onekes.kittycrush.SDKListener;
import com.onekes.kittycrush.SDKUtil;
import com.utils.NotifyCenter;

public class AppActivity extends Cocos2dxActivity {
	public static AppActivity sActivity		= null;
	public static Handler sHandler			= null;
	// message type define
	public static final int MT_SHARE		= 1;
	public static final int MT_PAY			= 2;
	/***************************************************************************************
	******************************** BEGIN override interface module
	***************************************************************************************/
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);      
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		sActivity = this;
		sHandler = new Handler() {
			public void handleMessage(Message msg) {
				if (MT_SHARE == msg.what) {
					SDKListener listener = new SDKListener(0, msg.obj) {
						@Override
						public void onCallback(int resultCode, Object resultObject) {
							callLuaFunctionWithId(sActivity, this.get("handler", 0).intValue(), String.valueOf(resultCode));
						}
					};
					listener.set("handler", msg.arg1);
					SDKUtil.share(listener);
				} else if (MT_PAY == msg.what) {
					SDKListener listener = new SDKListener(0, msg.obj) {
						@Override
						public void onCallback(int resultCode, Object resultObject) {
							callLuaFunctionWithId(sActivity, this.get("handler", 0).intValue(), String.valueOf(resultCode));
						}
					};
					listener.set("handler", msg.arg1);
					SDKUtil.pay(listener);
				}
			}
		};
		SDKUtil.onCreate(this);
	}
	
	@Override
	protected void onDestroy() {
		Log.e("cocos2d", "============================================ onDestroy");
		super.onDestroy();
		SDKUtil.onDestroy(this);
	}
	
	@Override
	public void onResume() {
        super.onResume();
        SDKUtil.onResume(this);
    }
    
	@Override
	protected void onPause() {
        super.onPause();
        SDKUtil.onPause(this);
    }
	
	@Override
    protected void onStop() {
        super.onStop();
        SDKUtil.onStop(this);
    }
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		SDKUtil.onActivityResult(this, requestCode, resultCode, data);
	}
	
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
    	// exit program when key back is entered
    	if (KeyEvent.KEYCODE_BACK == keyCode) {
    		SDKUtil.logout(null);
    	}
        return super.onKeyDown(keyCode, event);
    }
	/***************************************************************************************
	******************************** BEGIN member interface module
	***************************************************************************************/
	public void pause() {
		this.onPause();
	}
	
	public boolean isNetworkConnected() {
		ConnectivityManager connectivityManager = (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
		if (null == connectivityManager) {
			return false;
		}
		NetworkInfo[] networkInfo = connectivityManager.getAllNetworkInfo();
		if (null != networkInfo && networkInfo.length > 0) {
            for (int i = 0; i < networkInfo.length; i++) {
                if (NetworkInfo.State.CONNECTED == networkInfo[i].getState()) {
                    return true;
                }
            }
        }
		return false;
	}
	
	public boolean isAppOnForeground() {
		ActivityManager activityManager = (ActivityManager)getSystemService(Context.ACTIVITY_SERVICE);
        List<RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
        if (null == appProcesses) {
            return false;
        }
        for (RunningAppProcessInfo appProcess : appProcesses) {
            if (RunningAppProcessInfo.IMPORTANCE_FOREGROUND == appProcess.importance && appProcess.processName.equals(getPackageName())) {
                return true;
            }
        }
        return false;
	}
	
	public String getMacAddress() {
		String macAddress = ((WifiManager)getSystemService(WIFI_SERVICE)).getConnectionInfo().getMacAddress();
		if (null == macAddress) {
			return "";
		}
		return macAddress;
	}
	
	public String getSimState() {
		TelephonyManager telManager = (TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE);
		if (TelephonyManager.SIM_STATE_READY != telManager.getSimState()) {
			return "SIM_NULL";		// Null
		}
        String operator = telManager.getSimOperator();
    	if (operator.equals("46000") || operator.equals("46002") || operator.equals("46007")) {
    		return "SIM_YD";		// China Mobile
		} else if (operator.equals("46001") || operator.equals("46006")) {
			return "SIM_LT";		// China Unicom
    	} else if (operator.equals("46003") || operator.equals("46005")) {
    		return "SIM_DX";		// China Telecom
    	} else {
    		return "SIM_UNKNOWN";	// Unknown
    	}
	}
	
	public void copyString(final String str) {
		runOnUiThread(new Runnable() {
			@SuppressWarnings("deprecation")
			@Override
			public void run() {
				Object cs = getSystemService(Activity.CLIPBOARD_SERVICE);
				if (android.os.Build.VERSION.SDK_INT > 11) {
					((android.content.ClipboardManager)cs).setText(str);
				} else {
					((android.text.ClipboardManager)cs).setText(str);
				}
			}
		});
	}
	/***************************************************************************************
	******************************** BEGIN lua interface module
	***************************************************************************************/
	public static void callLuaFunctionWithId(Activity activity, final int funcId, final String param) {
		Log.e("cocos2d", "callLuaFunctionWithId -> funcId: " + funcId + ", param: " + param);
		if (null == (Cocos2dxActivity)activity || funcId <= 0) {
			return;
		}
		((Cocos2dxActivity)activity).runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcId, param);
			}
		});
	}
	
	public static void callLuaGlobalFunctionWithName(Activity activity, final String funcName, final String param) {
		Log.e("cocos2d", "callLuaGlobalFunctionWithName -> funcName: " + funcName + ", param: " + param);
		if (null == (Cocos2dxActivity)activity || funcName.equals("")) {
			return;
		}
		((Cocos2dxActivity)activity).runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(funcName, param);
			}
		});
	}
	
	public static String javaProxy(final int type, final String data, final int handler) {
		Log.e("cocos2d", "javaProxy -> type: " + type + ", data: " + data + ", handler: " + handler);
		try {
			switch (type) {
			case 101:		// get mac address
				return sActivity.getMacAddress();
			case 102:		// get sim state
				return sActivity.getSimState();
			case 103:		// get channel id
				ApplicationInfo appInfo = sActivity.getPackageManager().getApplicationInfo(sActivity.getPackageName(), PackageManager.GET_META_DATA);
				return String.valueOf(appInfo.metaData.getInt("UMENG_CHANNEL"));
			case 104:		// get device id
				return Secure.getString(sActivity.getContentResolver(), Secure.ANDROID_ID);
			case 105:		// get bundle version
				return sActivity.getPackageManager().getPackageInfo(sActivity.getPackageName(), 0).versionName;
			case 106:		// query goods info list
				SDKUtil.listen(new SDKListener(1, data) {
					public void onCallback(int resultCode, Object resultObject) {
						callLuaFunctionWithId(sActivity, handler, 1 == resultCode ? ((JSONObject)resultObject).toString() : "");
					}
				});
				break;
			case 107:		// query resupply order list
				SDKUtil.listen(new SDKListener(2, data) {
					public void onCallback(int resultCode, Object resultObject) {
						callLuaFunctionWithId(sActivity, handler, 1 == resultCode ? ((JSONObject)resultObject).toString() : "");
					}
				});
				break;
			case 201:		// share
				Message shareMsg = new Message();
				shareMsg.what = MT_SHARE;
				shareMsg.obj = data;
				shareMsg.arg1 = handler;
		        sHandler.sendMessage(shareMsg);
				break;
			case 202:		// pay
				Message payMsg = new Message();
				payMsg.what = MT_PAY;
				payMsg.obj = data;
				payMsg.arg1 = handler;
		        sHandler.sendMessage(payMsg);
				break;
			case 203: {		// record custom event
					JSONObject jsonObj = new JSONObject();
					jsonObj.put("event_type", 1);
					jsonObj.put("event_value", data);
					SDKUtil.record(jsonObj.toString());
				}
				break;
			case 204: {		// record pay event
					JSONObject jsonObj = new JSONObject(data);
					jsonObj.put("event_type", 3);
					SDKUtil.record(jsonObj.toString());
				}
				break;
			case 205: {		// record level start event
					JSONObject jsonObj = new JSONObject();
					jsonObj.put("event_type", 4);
					jsonObj.put("event_value", data);
					SDKUtil.record(jsonObj.toString());
				}
				break;
			case 206: {		// record level finish event
					JSONObject jsonObj = new JSONObject();
					jsonObj.put("event_type", 5);
					jsonObj.put("event_value", data);
					SDKUtil.record(jsonObj.toString());
				}
				break;
			case 207: {		// record level fail event
					JSONObject jsonObj = new JSONObject();
					jsonObj.put("event_type", 6);
					jsonObj.put("event_value", data);
					SDKUtil.record(jsonObj.toString());
				}
				break;
			case 208: {		// record custom event with value
					JSONObject jsonObj = new JSONObject(data);
					jsonObj.put("event_type", 2);
					SDKUtil.record(jsonObj.toString());
				}
				break;
			case 301:		// copy string
				sActivity.copyString(data);
				break;
			case 302:		// exit
				callLuaGlobalFunctionWithName(sActivity, "applicationDidEnterBackground", "");
				SDKUtil.onDestroy(sActivity);
				sActivity.finish();
				android.os.Process.killProcess(android.os.Process.myPid());
				break;
			case 303:		// open more
				SDKUtil.moreGame(data);
				break;
			case 304:		// register notify
				NotifyCenter.regist(sActivity, NotifyReceiver.class);
				break;
			case 305:		// add notify
				JSONObject obj305 = new JSONObject(data);
				int notifyType = obj305.getInt("notify_type");
				int notifyKey = obj305.getInt("notify_key");
				String notifyTitle = sActivity.getResources().getString(R.string.app_name);
				String notifyMsg = obj305.getString("notify_msg");
				long notifyDelay = obj305.getLong("notify_delay");
				NotifyCenter.add(notifyType, notifyKey, notifyTitle, notifyMsg, notifyDelay);
				break;
			case 306:		// remove notify by type
				NotifyCenter.removeType(Integer.parseInt(data));
				break;
			case 307:		// remove notify by key
				NotifyCenter.removeKey(Integer.parseInt(data));
				break;
			case 308:		// clear noitfy
				NotifyCenter.clear();
				break;
			case 309:		// register
				SDKUtil.register(null);
				break;
			case 310:		// login
				SDKUtil.login(null);
				break;
			case 311:		// logout
				SDKUtil.logout(null);
				break;
			case 312:		// open to app page
				SDKUtil.appPage(data);
				break;
			default:
				break;
			}
		} catch (Exception e) {
			Log.e("cocos2d", "javaProxy -> exception:\n" + e.toString());
			e.printStackTrace();
		}
		return "";
	}
	/***************************************************************************************
	******************************** END lua interface module
	***************************************************************************************/
}
