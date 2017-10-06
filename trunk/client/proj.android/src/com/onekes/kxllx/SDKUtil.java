package com.onekes.kxllx;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;

import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.game.UMGameAgent;
import com.umeng.update.UmengDialogButtonListener;
import com.umeng.update.UmengDownloadListener;
import com.umeng.update.UmengUpdateAgent;
import com.umeng.update.UpdateConfig;
import com.umeng.update.UpdateStatus;

import com.alipay.sdk.app.PayTask;

import org.cocos2dx.alipay.PayResult;
import org.cocos2dx.alipay.SignUtils;

import com.ffcs.inapppaylib.PayHelper;
import com.ffcs.inapppaylib.bean.Constants;
import com.ffcs.inapppaylib.bean.response.BaseResponse;

import com.unicom.woopensmspayment.UnicomWoOpenPaymentMainActivity;
import com.unicom.woopensmspayment.utiltools.ResourceTool;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

public final class SDKUtil {
	private static Activity mActivity = null;
	private static Handler mHandler = null;
	private static final int MT_PAY = 10;
	private static final int MT_PAY_SUCCESS = 11;
	private static final int MT_PAY_FAIL = 12;
	private static final int MT_PAY_CANCEL = 13;
	private static final int MT_SHARE = 20;
	private static final int MT_SHARE_SUCCESS = 21;
	private static final int MT_SHARE_FAIL = 22;
	private static final int MT_SHARE_CANCEL = 23;
	private static SDKListener mPayListener = null;
	private static boolean mForceUpdate = false;
	/***************************************************************************************
	******************************** public callback module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.创建
	public static void onCreate(Activity activity) {
		mActivity = activity;
		mHandler = new Handler() {
	    	public void handleMessage(Message msg) {
	    		if (MT_PAY == msg.what) {
	    			handlePay((SDKListener)msg.obj);
	    		} else if (MT_PAY_SUCCESS == msg.what) {
	    		} else if (MT_PAY_FAIL == msg.what) {
	    		} else if (MT_PAY_CANCEL == msg.what) {
	    		} else if (MT_SHARE == msg.what) {
	    			handleShare((SDKListener)msg.obj);
	    		} else if (MT_SHARE_SUCCESS == msg.what) {
	    		} else if (MT_SHARE_FAIL == msg.what) {
	    		} else if (MT_SHARE_CANCEL == msg.what) {
	    		}
	    	}
	    };
		// umeng
		UMGameAgent.setDebugMode(true);
	    UMGameAgent.init(activity);
	    // share sdk
	    ShareSDK.initSDK(activity);
	    // umeng update
	    UpdateConfig.setDebug(true);
	    UmengUpdateAgent.forceUpdate(mActivity);
	    UmengUpdateAgent.setUpdateOnlyWifi(false);
	    UmengUpdateAgent.setDeltaUpdate(false);
	    UmengUpdateAgent.setDialogListener(new UmengDialogButtonListener() {
	        @Override
	        public void onClick(int status) {
	            switch (status) {
	            case UpdateStatus.Update:
	                showForceUpdateDialog(1, R.string.update_in_doing);
	                break;
	            case UpdateStatus.Ignore:
	                showForceUpdateDialog(2, R.string.update_must);
	                break;
	            case UpdateStatus.NotNow:
	                showForceUpdateDialog(2, R.string.update_must);
	                break;
	            }
	        }
	    });
	    UmengUpdateAgent.setDownloadListener(new UmengDownloadListener() {
	        @Override
	        public void OnDownloadStart() {
	            Toast.makeText(mActivity, R.string.update_in_doing, Toast.LENGTH_LONG).show();
	        }
	        @Override
	        public void OnDownloadUpdate(int progress) {
//	        	Toast.makeText(mActivity, progress + "%", Toast.LENGTH_SHORT).show();
	        }
	        @Override
	        public void OnDownloadEnd(int result, String file) {
	        	switch (result) {
	        	case UpdateStatus.DOWNLOAD_COMPLETE_FAIL:
	        		showForceUpdateDialog(2, R.string.update_fail);
	        		break;
	        	case UpdateStatus.DOWNLOAD_COMPLETE_SUCCESS:
	        		android.os.Process.killProcess(android.os.Process.myPid());
	        		break;
	        	}
	        }
	    });
	}
	//-------------------------------------------------------------------------------------
	// 2.销毁
	public static void onDestroy(Activity activity) {
		UMGameAgent.onKillProcess(activity);
	}
	//-------------------------------------------------------------------------------------
	// 3.恢复
	public static void onResume(Activity activity) {
		UMGameAgent.onResume(activity);
		if (mForceUpdate) {
			AppActivity.sActivity.pause();
        }
	}
	//-------------------------------------------------------------------------------------
	// 4.暂停
	public static void onPause(Activity activity) {
		UMGameAgent.onPause(activity);
	}
	//-------------------------------------------------------------------------------------
	// 5.停止
	public static void onStop(Activity activity) {
	}
	//-------------------------------------------------------------------------------------
	// 6.活动
	public static void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
		if (requestCode == ResourceTool.SDK_DATA_REQ && null != mPayListener) {
			if (0 == data.getIntExtra("result", 1)) {
		        mPayListener.onCallback(1, null);
		        Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
			} else {
		        mPayListener.onCallback(2, null);
		        Toast.makeText(mActivity, data.getStringExtra("errorstr"), Toast.LENGTH_SHORT).show();
			}
		}
	}
	//-------------------------------------------------------------------------------------
	// 7.其他
	public static void onOther(Activity activity, int type, Object obj) {
	}
	/***************************************************************************************
	******************************** public interface module
	***************************************************************************************/
	//-------------------------------------------------------------------------------------
	// 1.获取
	public static String get(int type, String data) {
		if (1 == type) {	// 获取运营商类型
		} else if (2 == type) {	// 获取音效是否开启
		}
		return "";
	}
	//-------------------------------------------------------------------------------------
	// 2.监听
	public static void listen(SDKListener listener) {
		int listenerId = listener.getId();
		if (1 == listenerId) {	// 请求商品信息
		} else if (2 == listenerId) {	// 漏单查询
		}
	}
	//-------------------------------------------------------------------------------------
	// 3.注册
	public static void register(SDKListener listener) {
	}
	//-------------------------------------------------------------------------------------
	// 4.登录
	public static void login(SDKListener listener) {
	}
	//-------------------------------------------------------------------------------------
	// 5.注销
	public static void logout(SDKListener listener) {
		new AlertDialog.Builder(mActivity)
		.setMessage(R.string.onekes_exit_msg)
		.setPositiveButton(R.string.onekes_queding, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface arg0, int arg1) {
				AppActivity.javaProxy(301, "", 0);
			}
		})
		.setNegativeButton(R.string.onekes_quxiao, null)
		.show();
	}
	//-------------------------------------------------------------------------------------
	// 6.支付
	public static void pay(SDKListener listener) {
		Message msg = new Message();
		msg.what = MT_PAY;
		msg.obj = listener;
		mHandler.sendMessage(msg);
	}
	//-------------------------------------------------------------------------------------
	// 7.分享
	public static void share(SDKListener listener) {
		Message msg = new Message();
		msg.what = MT_SHARE;
		msg.obj = listener;
		mHandler.sendMessage(msg);
	}
	//-------------------------------------------------------------------------------------
	// 8.记录
	public static void record(String data) {
		try {
			JSONObject jsonObj = new JSONObject(data);
			switch (jsonObj.getInt("tag")) {
			case 1:		// 自定义事件(无参数)
				MobclickAgent.onEvent(mActivity, jsonObj.getString("event"));
				break;
			case 2:		// 自定义事件(带参数)
				jsonObj.remove("tag");
				String event = "";
				HashMap<String, String> map = new HashMap<String, String>();
				Iterator<String> iter = jsonObj.keys();
				while (iter.hasNext()) {
					String key = (String)iter.next();
					String value = jsonObj.getString(key);
					if (key.equals("event")) {
						event = value;
					} else {
						map.put(key, value);
					}
				}
				if (!event.equals("")) {
					MobclickAgent.onEvent(mActivity, event, map);
				}
				break;
			case 3:		// 支付事件
				String cash = jsonObj.getString("cash");
				String item = jsonObj.getString("item");
				String amount = jsonObj.getString("amount");
				String price = jsonObj.getString("price");
				String source = jsonObj.getString("source");
				UMGameAgent.pay(Double.valueOf(cash), item, Integer.valueOf(amount), Double.valueOf(price), Integer.valueOf(source));
				break;
			case 4:		// 关卡开始
				UMGameAgent.startLevel(jsonObj.getString("level"));
				break;
			case 5:		// 关卡成功
				UMGameAgent.finishLevel(jsonObj.getString("level"));
				break;
			case 6:		// 关卡失败
				UMGameAgent.failLevel(jsonObj.getString("level"));
				break;
			default:
				break;
			}
		} catch(Exception e) {
			Log.e("cocos2d", "share -> exception: " + e.toString());
			e.printStackTrace();
		}
	}
	//-------------------------------------------------------------------------------------
	// 9.更多游戏
	public static void moreGame(String data) {
	}
	//-------------------------------------------------------------------------------------
	// 10.应用页面
	public static void appPage(String data) {
	}
	//-------------------------------------------------------------------------------------
	// 11.显示关于
	public static void showAbout(String data) {
	}
	/***************************************************************************************
	******************************** private module
	***************************************************************************************/
	// 处理支付
	private static void handlePay(SDKListener listener) {
		mPayListener = listener;
		try {
			JSONObject jsonObj = new JSONObject(listener.getObject().toString());
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
			if (1 == payType) {
				payLittle(orderId, totalFee, productId, productName, productDesc, company, servicePhone, dxCode, ltCode, ydCode);
			} else if (2 == payType) {
				payMany(orderId, totalFee, productId, productName, productDesc, company, servicePhone, dxCode, ltCode, ydCode);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	// 处理分享
	private static void handleShare(SDKListener listener) {
		try {
			JSONObject jsonObj = new JSONObject(listener.getObject().toString());
			int shareType = jsonObj.getInt("share_type");
			if (1 == shareType) {
				sharePicture(jsonObj.getString("share_pic"), listener);
			} else if (2 == shareType) {
				shareUrl(jsonObj.getString("share_content"), jsonObj.getString("share_url"), listener);
			}
		} catch(Exception e) {
			Log.e("cocos2d", "share -> exception: " + e.toString());
			e.printStackTrace();
		}
	}
	
	// 分享监听
	private static class SharePlatformActionListener implements PlatformActionListener {
		public SDKListener listener = null;
		
		@Override
		public void onComplete(Platform plat, int action, HashMap<String, Object> res) {
			Log.e("cocos2d", "share onComplete, " + plat.toString() + ", " + action);
			listener.onCallback(1, null);
	        Toast.makeText(mActivity, R.string.onekes_share_success, Toast.LENGTH_LONG).show();
		}
		
		@Override
		public void onError(Platform plat, int action, Throwable t) {
			Log.e("cocos2d", "share onError, " + plat.toString() + ", " + action + ", " + t.toString());
			listener.onCallback(2, null);
	        Toast.makeText(mActivity, R.string.onekes_share_fail, Toast.LENGTH_LONG).show();
		}
		
		@Override
		public void onCancel(Platform plat, int action) {
			Log.e("cocos2d", "share onCancel, " + plat.toString() + ", " + action);
			listener.onCallback(3, null);
	        Toast.makeText(mActivity, R.string.onekes_share_cancel, Toast.LENGTH_LONG).show();
		}
	}
		
	// 分享图片
	private static void sharePicture(String picture, SDKListener listener) {
		Log.e("cocos2d", "share picture");
		cn.sharesdk.wechat.moments.WechatMoments.ShareParams sp = new cn.sharesdk.wechat.moments.WechatMoments.ShareParams();
		sp.shareType = Platform.SHARE_IMAGE;
		sp.imagePath = picture;
		
		SharePlatformActionListener shareListener = new SharePlatformActionListener();
		shareListener.listener = listener;
		Platform wechatPlatform = ShareSDK.getPlatform(cn.sharesdk.wechat.moments.WechatMoments.NAME);
		wechatPlatform.setPlatformActionListener(shareListener);	// 设置分享事件回调
		wechatPlatform.share(sp);
	}
		
	// 分享链接
	private static void shareUrl(String content, String url, SDKListener listener) {
		Log.e("cocos2d", "share url");
		cn.sharesdk.wechat.moments.WechatMoments.ShareParams sp = new cn.sharesdk.wechat.moments.WechatMoments.ShareParams();
		sp.shareType = Platform.SHARE_WEBPAGE;
		sp.title = AppActivity.sActivity.getResources().getString(R.string.app_name);
		sp.text = content;
		sp.url = url;
		sp.imageData = BitmapFactory.decodeResource(AppActivity.sActivity.getResources(), R.drawable.icon);
		
		SharePlatformActionListener shareListener = new SharePlatformActionListener();
		shareListener.listener = listener;
		Platform wechatPlatform = ShareSDK.getPlatform(cn.sharesdk.wechat.moments.WechatMoments.NAME);
		wechatPlatform.setPlatformActionListener(shareListener);	// 设置分享事件回调
		wechatPlatform.share(sp);
	}
	
	private static void showForceUpdateDialog(int type, int tipId) {
		AppActivity.sActivity.pause();
		mForceUpdate = true;
		if (1 == type) {			// 无按钮对话框
			new AlertDialog.Builder(mActivity)
			.setTitle(R.string.app_name)
			.setMessage(tipId)
			.setCancelable(false)
			.show();
		} else if (2 == type) {		// 确定按钮对话框
			new AlertDialog.Builder(mActivity)
			.setTitle(R.string.app_name)
			.setMessage(tipId)
			.setPositiveButton(R.string.onekes_queding, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface arg0, int arg1) {
					android.os.Process.killProcess(android.os.Process.myPid());
				}
			})
			.setCancelable(false)
			.show();
		}
	}
	
	// 小额支付
	private static void payLittle(String orderId, String totalFee, String productId, String productName, String productDesc, String company, String servicePhone, String dxCode, String ltCode, String ydCode) {
		String simState = AppActivity.javaProxy(102, "", 0);
		Log.e("cocos2d", "payLittle -> simState: " + simState);
		if (simState.equals("SIM_NULL")) {
			payALi(orderId, productName, productDesc, totalFee);
		} else if (simState.equals("SIM_DX")) {
			if (dxCode.equals("") || dxCode.equals("0")) {
				payALi(orderId, productName, productDesc, totalFee);
			} else {
				payDX_inapppay(dxCode);
			}
		} else if (simState.equals("SIM_LT")) {
			if (ltCode.equals("") || ltCode.equals("0")) {
				payALi(orderId, productName, productDesc, totalFee);
			} else {
				payLT(orderId, productName, productDesc, totalFee, ltCode, company, servicePhone);
			}
		} else if (simState.equals("SIM_YD")) {
			if (ydCode.equals("") || ydCode.equals("0")) {
				payALi(orderId, productName, productDesc, totalFee);
			} else {
				payALi(orderId, productName, productDesc, totalFee);
			}
		} else {	// SIM_UNKNOWN
			payALi(orderId, productName, productDesc, totalFee);
		}
	}
	
	// 大额支付
	private static void payMany(String orderId, String totalFee, String productId, String productName, String productDesc, String company, String servicePhone, String dxCode, String ltCode, String ydCode) {
        payALi(orderId, productName, productDesc, totalFee);
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
	
	// sign the order info. 对订单信息进行签名,content 待签名订单信息
	public static String sign(String content) {
		return SignUtils.sign(content, CONFIG.RSA_PRIVATE);
	}
	
	// get the sign type we use. 获取签名方式
	public static String getSignType() {
		return "sign_type=\"RSA\"";
	}
	
	private static void payALi(String sOrderId, String subject, String sDesc, String price) {
		// 订单
		String orderInfo = getOrderInfo(sOrderId, subject, sDesc, price);
		// 对订单做RSA 签名
		String sign = sign(orderInfo);
		try {
			// 仅需对sign 做URL编码
			sign = URLEncoder.encode(sign, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		final Handler handler = new Handler() {
			public void handleMessage(Message msg) {
				PayResult payResult = new PayResult((String)msg.obj);
				// 支付宝返回此次支付结果及加签，建议对支付宝签名信息拿签约时支付宝提供的公钥做验签
				String resultStatus = payResult.getResultStatus();
				// 判断resultStatus 为“9000”则代表支付成功，具体状态码代表含义可参考接口文档
				if (TextUtils.equals(resultStatus, "9000")) {
			        mPayListener.onCallback(1, null);
			        Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
				} else {
					// 判断resultStatus 为非“9000”则代表可能支付失败
					// “8000”代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
					if (TextUtils.equals(resultStatus, "8000")) {
				        mPayListener.onCallback(2, null);
				        Toast.makeText(mActivity, R.string.onekes_pay_waiting, Toast.LENGTH_SHORT).show();
					} else {
						// 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误
				        mPayListener.onCallback(2, null);
				        Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
					}
				}
			}
		};
		// 完整的符合支付宝参数规范的订单信息
		final String payInfo = orderInfo + "&sign=\"" + sign + "\"&" + getSignType();
		// 必须异步调用
		new Thread(new Runnable() {
			public void run() {
				Message msg = new Message();
				msg.obj = new PayTask(mActivity).pay(payInfo);	// 调用支付接口，获取支付结果
				handler.sendMessage(msg);
			}
		}).start();
	}
	
	// 电信支付,inapppay
	private static void payDX_inapppay(String dxCode) {
		PayHelper payHelper = PayHelper.getInstance(mActivity);
		payHelper.init(CONFIG.DX_APP_ID, CONFIG.DX_APP_KEY);
		Handler handler = new Handler() {
			public void handleMessage(android.os.Message msg) {
				Log.e("cocos2d", "payDX_inapppay, msg: " + msg.what);
				BaseResponse resp = null;
				switch (msg.what) {
					case Constants.RESULT_PAY_SUCCESS:
						resp = (BaseResponse)msg.obj;
				        mPayListener.onCallback(1, null);
				        if (null == resp) {
				        	Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
				        } else {
				        	Toast.makeText(mActivity, (resp.getRes_code() + "1:" + resp.getRes_message()), Toast.LENGTH_SHORT).show();
				        }
						break;
					case Constants.RESULT_PAY_FAILURE:
						resp = (BaseResponse)msg.obj;
				        mPayListener.onCallback(2, null);
				        if (null == resp) {
				        	Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
				        } else {
				        	Toast.makeText(mActivity, (resp.getRes_code() + "2:" + resp.getRes_message()), Toast.LENGTH_SHORT).show();
				        }
						break;
					case Constants.RESULT_VALIDATE_FAILURE:
						resp = (BaseResponse)msg.obj;
				        mPayListener.onCallback(2, null);
				        if (null == resp) {
				        	Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
				        } else {
				        	Toast.makeText(mActivity, (resp.getRes_code() + "3:" + resp.getRes_message()), Toast.LENGTH_SHORT).show();
				        }
						break;
					default:
						break;
				}
			};
		};
		payHelper.pay(mActivity, dxCode, handler, "onekes");
	}
	
	// 联通支付
	private static void payLT(String sOrderId, String subject, String body, String price, String sLTCode, String sCompany, String sServicePhone) {
		Intent intent = new Intent(mActivity, UnicomWoOpenPaymentMainActivity.class);
		Bundle bundle = new Bundle();
		bundle.putString("appId", CONFIG.LT_APP_ID);
		bundle.putString("productId", sLTCode);
		bundle.putString("money", price);
		bundle.putString("cpTradeId", sOrderId);
		bundle.putString("appName", mActivity.getString(R.string.app_name));
		bundle.putString("company", sCompany);
		bundle.putString("product", subject);
		bundle.putString("developerServicePhone", sServicePhone);
		intent.putExtras(bundle);
		mActivity.startActivityForResult(intent, ResourceTool.SDK_DATA_REQ);
	}
}
