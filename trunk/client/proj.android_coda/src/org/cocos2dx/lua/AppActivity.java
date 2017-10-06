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

import com.onekes.kittycrush.SDKListener;
import com.onekes.kittycrush.SDKUtil;
import com.utils.NotifyCenter;

import com.codapayments.sdk.interfaces.PaymentResultHandler;
import com.codapayments.sdk.model.PayResult;

public class AppActivity extends Cocos2dxActivity implements PaymentResultHandler {
	public static AppActivity sActivity = null;
	/***************************************************************************************
	******************************** BEGIN override interface module
	***************************************************************************************/
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);      
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		sActivity = this;
		SDKUtil.onCreate(this);
	}
	
	@Override
	protected void onDestroy() {
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
	
	@Override
	public void handleClose(PayResult payResult) {
		SDKUtil.onOther(this, 1, payResult)
	}
	
	@Override
	public void handleResult(PayResult payResult) {
		SDKUtil.onOther(this, 2, payResult)
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
			case 106:		// get goods info list
				SDKUtil.listen(new SDKListener(1, data, handler) {
					public void onCallback(int resultCode, Object resultObject) {
						callLuaFunctionWithId(sActivity, this.getHandler(), 1 == resultCode ? ((JSONObject)resultObject).toString() : "");
					}
				});
				break;
			case 107:		// get resupply order list
				SDKUtil.listen(new SDKListener(2, data, handler) {
					public void onCallback(int resultCode, Object resultObject) {
						callLuaFunctionWithId(sActivity, this.getHandler(), 1 == resultCode ? ((JSONObject)resultObject).toString() : "");
					}
				});
				break;
			case 108:		// get operator type
				return SDKUtil.get(1, data);
			case 109:		// get is sound on
				return SDKUtil.get(2, data);
			case 201:		// register
				SDKUtil.register(null);
				break;
			case 202:		// login
				SDKUtil.login(null);
				break;
			case 203:		// logout
				SDKUtil.logout(null);
				break;
			case 204:		// pay
				SDKUtil.pay(new SDKListener(0, data, handler) {
					public void onCallback(int resultCode, Object resultObject) {
						callLuaFunctionWithId(sActivity, this.getHandler(), String.valueOf(resultCode));
					}
				});
				break;
			case 205:		// share
				SDKUtil.share(new SDKListener(0, data, handler) {
					public void onCallback(int resultCode, Object resultObject) {
						callLuaFunctionWithId(sActivity, this.getHandler(), String.valueOf(resultCode));
					}
				});
				break;
			case 206:		// record event
				SDKUtil.record(data);
				break;
			case 207:		// more game
				SDKUtil.moreGame(data);
				break;
			case 208:		// app page
				SDKUtil.appPage(data);
				break;
			case 209:		// show about
				SDKUtil.showAbout(data);
				break;
			case 301:		// kill game
				callLuaGlobalFunctionWithName(sActivity, "applicationDidEnterBackground", "");
				SDKUtil.onDestroy(sActivity);
				sActivity.finish();
				android.os.Process.killProcess(android.os.Process.myPid());
				break;
			case 302:		// copy string
				sActivity.copyString(data);
				break;
			case 303:		// register notify
				NotifyCenter.regist(sActivity, NotifyReceiver.class);
				break;
			case 304: {		// add notify
					JSONObject obj = new JSONObject(data);
					NotifyCenter.add(obj.getInt("tag"), obj.getInt("key"), obj.getString("title"), obj.getString("msg"), obj.getLong("delay"));
				}
				break;
			case 305:		// remove notify by type
				NotifyCenter.removeType(Integer.parseInt(data));
				break;
			case 306:		// remove notify by key
				NotifyCenter.removeKey(Integer.parseInt(data));
				break;
			case 307:		// clear noitfy
				NotifyCenter.clear();
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
