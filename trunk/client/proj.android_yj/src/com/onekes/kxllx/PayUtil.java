package com.onekes.kxllx;

import com.alipay.sdk.app.PayTask;
import com.onekes.kxllx.R;
import com.onekes.kxllx.CONFIG;
import com.onekes.kxllx.alipay.PayResult;
import com.onekes.kxllx.alipay.SignUtils;
import com.snowfish.cn.ganga.offline.helper.SFCommonSDKInterface;
import com.snowfish.cn.ganga.offline.helper.SFIPayResultListener;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.app.AlertDialog.Builder;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;
import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lua.AppActivity;

public class PayUtil {
	private static Activity mActivity = null;
	private static SFIPayResultListener mPayListener = null;
	// pay channel define
	private static final int PC_ALIPAY	= 1;
	// pay type define
	private static final int PT_LITTLE	= 1;
	private static final int PT_MANY	= 2;
	
	public static void onCreate(Activity activity) {
		mActivity = activity;
		mPayListener = new SFIPayResultListener() {
			@Override
			public void onSuccess(String arg0) {
				Log.e("cocos2d", "SFIPayResultListener -> onSuccess: " + arg0);
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_SUCCESS;
				msg.obj = R.string.onekes_pay_success;
				msg.arg1 = Toast.LENGTH_SHORT;
				AppActivity.sHandler.sendMessage(msg);
			}
			
			@Override
			public void onFailed(String arg0) {
				Log.e("cocos2d", "SFIPayResultListener -> onFailed: " + arg0);
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_FAIL;
				msg.obj = R.string.onekes_pay_fail;
				msg.arg1 = Toast.LENGTH_SHORT;
		        AppActivity.sHandler.sendMessage(msg);
			}
			
			@Override
			public void onCanceled(String arg0) {
				Log.e("cocos2d", "SFIPayResultListener -> onCanceled: " + arg0);
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_CANCEL;
				msg.obj = R.string.onekes_pay_cancel;
				msg.arg1 = Toast.LENGTH_SHORT;
		        AppActivity.sHandler.sendMessage(msg);
			}
		};
	}
	
	public static void onDestroy(Activity activity) {
	}
	
	public static void onResume(Activity activity) {
	}
	
	public static void onPause(Activity activity) {
	}
	
	public static void onStop(Activity activity) {
	}
	
	public static void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
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
			String dxCode 			= "";
			if (jsonObj.has("tycode")) {
				dxCode = jsonObj.getString("tycode");
			}
			String ltCode 			= "";
			if (jsonObj.has("ltcode")) {
				ltCode = jsonObj.getString("ltcode");
			}
			String ydCode 			= "";
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
		Log.e("cocos2d", "payLittle -> simState: " + simState + ", dxCode: " + dxCode + ", ltCode: " + ltCode + ", ydCode: " + ydCode);
		if (simState.equals("SIM_NULL")) {
			payALi(orderId, productName, productDesc, totalFee);
		} else if (simState.equals("SIM_DX")) {
			if (dxCode.equals("")) {
				payALi(orderId, productName, productDesc, totalFee);
			} else {
				SFCommonSDKInterface.pay(mActivity, dxCode, mPayListener);
			}
		} else if (simState.equals("SIM_LT")) {
			if (ltCode.equals("")) {
				payALi(orderId, productName, productDesc, totalFee);
			} else {
				SFCommonSDKInterface.pay(mActivity, ltCode, mPayListener);
			}
		} else if (simState.equals("SIM_YD")) {
			if (ydCode.equals("")) {
				payALi(orderId, productName, productDesc, totalFee);
			} else {
				SFCommonSDKInterface.pay(mActivity, ydCode, mPayListener);
			}
		} else {	// SIM_UNKNOWN
			payALi(orderId, productName, productDesc, totalFee);
		}
	}
		
		// 大额支付
	private static void payMany(String orderId, String totalFee, String productId, String productName, String productDesc, String company, String servicePhone, String dxCode, String ltCode, String ydCode) {
		IWXAPI api = WXAPIFactory.createWXAPI(mActivity, CONFIG.WX_APP_ID);	// 创建微信API
		api.registerApp(CONFIG.WX_APP_ID);	
        if (api.isWXAppInstalled() && api.isWXAppSupportAPI()) {
        	try {
        		int nFee = (int)(Double.parseDouble(totalFee)*100);		// 付费金额
//        		// 微信支付测试
        		new WXPay(api, orderId, productName, productDesc, nFee);
        	} catch (Exception e) {
        		payALi(orderId, productName, productDesc, totalFee);
        	}
        } else {
        	payALi(orderId, productName, productDesc, totalFee);
        }
	}
	
	// 支付宝
	// create the order info. 创建订单信息
	public static String getOrderInfo(String sOrderId, String subject, String body, String price) {
		// 签约合作者身份ID
		String orderInfo = "partner=" + "\"" + CONFIG.PARTNER + "\"";
		// 签约卖家支付宝账号
		orderInfo += "&seller_id=" + "\"" + CONFIG.SELLER + "\"";
		// 商户网站唯一订单号
		orderInfo += "&out_trade_no=" + "\"" + sOrderId + "\"";
		// 商品名称
		orderInfo += "&subject=" + "\"" + subject + "\"";
		// 商品详情
		orderInfo += "&body=" + "\"" + body + "\"";
		// 商品金额
		orderInfo += "&total_fee=" + "\"" + price + "\"";
		// 服务器异步通知页面路径
		orderInfo += "&notify_url=" + "\"" + CONFIG.NOTIFY_URL + "\"";
		// 服务接口名称, 固定值
		orderInfo += "&service=\"mobile.securitypay.pay\"";
		// 支付类型, 固定值
		orderInfo += "&payment_type=\"1\"";
		// 参数编码, 固定值
		orderInfo += "&_input_charset=\"utf-8\"";
		// 设置未付款交易的超时时间
		// 默认30分钟,一旦超时,该笔交易就会自动被关闭
		// 取值范围：1m～15d。
		// m-分钟,h-小时,d-天,1c-当天（无论交易何时创建，都在0点关闭）
		// 该参数数值不接受小数点，如1.5h，可转换为90m
		orderInfo += "&it_b_pay=\"30m\"";
		// extern_token为经过快登授权获取到的alipay_open_id,带上此参数用户将使用授权的账户进行支付
		// orderInfo += "&extern_token=" + "\"" + extern_token + "\"";
		// 支付宝处理完请求后，当前页面跳转到商户指定页面的路径，可空
		//orderInfo += "&return_url=\"m.alipay.com\"";
		// 调用银行卡支付，需配置此参数，参与签名， 固定值 （需要签约《无线银行卡快捷支付》才能使用）
		// orderInfo += "&paymethod=\"expressGateway\"";
		return orderInfo;
	}
	
	private static void payALi(String sOrderId, String subject, String sDesc, String price) {
		// 订单
		String orderInfo = getOrderInfo(sOrderId, subject, sDesc, price);
		// 对订单做RSA签名
		String sign = SignUtils.sign(orderInfo, CONFIG.RSA_PRIVATE);
		try {
			// 仅需对sign 做URL编码
			sign = URLEncoder.encode(sign, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		// 完整的符合支付宝参数规范的订单信息
		final String payInfo = orderInfo + "&sign=\"" + sign + "\"&sign_type=\"RSA\"";
		final Handler mHandler = new Handler() {
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case PC_ALIPAY: {
					PayResult payResult = new PayResult((String) msg.obj);
					// 支付宝返回此次支付结果及加签，建议对支付宝签名信息拿签约时支付宝提供的公钥做验签
					String resultStatus = payResult.getResultStatus();
					// 判断resultStatus 为“9000”则代表支付成功，具体状态码代表含义可参考接口文档
					Message appMsg = null;
					if (TextUtils.equals(resultStatus, "9000")) {
						appMsg = new Message();
						appMsg.what = AppActivity.MT_PAY_SUCCESS;
						appMsg.obj = R.string.onekes_pay_success;
						appMsg.arg1 = Toast.LENGTH_SHORT;
				        AppActivity.sHandler.sendMessage(appMsg);
					} else {
						// 判断resultStatus 为非“9000”则代表可能支付失败
						// “8000”代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
						if (TextUtils.equals(resultStatus, "8000")) {
							appMsg = new Message();
							appMsg.what = AppActivity.MT_PAY_FAIL;
							appMsg.obj = R.string.onekes_pay_waiting;
							appMsg.arg1 = Toast.LENGTH_SHORT;
					        AppActivity.sHandler.sendMessage(appMsg);
						} else {
							// 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误
							appMsg = new Message();
							appMsg.what = AppActivity.MT_PAY_FAIL;
							appMsg.obj = R.string.onekes_pay_fail;
							appMsg.arg1 = Toast.LENGTH_SHORT;
					        AppActivity.sHandler.sendMessage(appMsg);
						}
					}
					break;
				}
				default:
					break;
				}
			};
		};
		Runnable payRunnable = new Runnable() {
			@Override
			public void run() {
				// 构造PayTask 对象
				PayTask alipay = new PayTask(mActivity);
				// 调用支付接口，获取支付结果
				String result = alipay.pay(payInfo);
				Message msg = new Message();
				msg.what = PC_ALIPAY;
				msg.obj = result;
				mHandler.sendMessage(msg);
			}
		};
		// 必须异步调用
		Thread payThread = new Thread(payRunnable);
		payThread.start();
	}
}


