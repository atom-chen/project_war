/**
 * 杭州哲信支付sdk接入
 * auth: yejt
 */
package com.onekes.kxllx.hzzxpay;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.qy.pay.listener.PayAgent;

public class HzzxPay {
	/**
	 * 初始化
	 * @param sActivity	传入Activity
	 */
	public static void zxPayInit( Activity sActivity ){
		PayAgent.init(sActivity);
	}
	
	/**
	 * 支付
	 * @param sActivity	界面Activity
	 * @param sPayCode	支付码
	 * @param sMoney	支付金额字符串
	 * @param listener	支付结果监听
	 */
	public static void zxPay(Activity sActivity, String sPayCode, String sMoney, final HzzxPayListener listener){
		// 对金额进行转换
		int nFee = 0;
		try {
    		nFee = (int)(Double.parseDouble(sMoney)*100);		// 付费金额
    	} catch (Exception e) {
    		listener.onFail(-5, "the money is error");
    	}
		// 进行支付
		Handler mHandler = new Handler(){
	        @Override
	        public void handleMessage(Message msg) {
	        	Bundle bundle = msg.getData();
	        	if (bundle != null) {
	        		int code = bundle.getInt("code", -1);
	        		String sMsg = bundle.getString("msg");
	        		if (code == 0) {
	        			//支付成功
	        			listener.onSuccess(code, sMsg);
	        	 	} else {
	        	 		//支付失败
	        	 		listener.onFail(code, sMsg);
	        	 	}
	        	}
	        }
	    };
		PayAgent.pay(sActivity, mHandler, sPayCode, nFee);
	}
}
