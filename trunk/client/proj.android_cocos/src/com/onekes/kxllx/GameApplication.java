package com.onekes.kxllx;

import com.unicom.dcLoader.Utils;
import com.unicom.dcLoader.Utils.UnipayPayResultListener;

import android.app.Application;
import android.util.Log;

public class GameApplication extends Application{
	
	  public void onCreate() {
	    //cocos 联通标准支付
	    try{
		    Utils.getInstances().initSDK(this, new UnipayPayResultListener() {
	            @Override
	            public void PayResult(String arg0, int arg1, int arg2, String arg3) {
	            	Log.e("cocos2d", "initSDK -> unicom " + arg0 + " ,"+ arg1  + " ," + arg2  + " ,"  + arg3 );
	            }
	        });	
	    } catch (NoClassDefFoundError e) {
	    	Log.e("cocos2d", "initSDK -> error ", e);
        } catch (NoSuchMethodError e) {
        	Log.e("cocos2d", "initSDK -> error ", e);
        } catch (Exception e) {
        	Log.e("cocos2d", "initSDK -> error ", e);
        }
	  }
	  
}
