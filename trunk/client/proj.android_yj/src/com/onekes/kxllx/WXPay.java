package com.onekes.kxllx;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;

import org.cocos2dx.lua.AppActivity;
import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONObject;

import com.onekes.kxllx.R;
import com.onekes.kxllx.CONFIG;
import com.utils.*;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

public class WXPay {
	private static String TAG = "kxllx";
	public static IWXAPI api;
	
	private long timeStamp;
	private String nonceStr, packageValue; 
	private String m_sOrderId 		= "";
	private String m_sProductName 	= "";
	private int m_sTotalFee		= 0;
	
	private static enum LocalRetCode {
		ERR_OK, ERR_HTTP, ERR_JSON, ERR_OTHER
	}
	
	/**
	 * 微信支付
	 */
	public WXPay(IWXAPI wxAPI, String orderId, String productName, String productDesc, int totalFee) {
		Log.e("kxllx", "WXPay -> orderId: " + orderId + ", productName: " + productName + ", productDesc: " + productDesc + ", totalFee: " + totalFee);
		api = wxAPI;
		m_sOrderId 		= orderId;						// 订单
		m_sProductName 	= productName;					// 产品名称
		m_sTotalFee 	= totalFee;
		GetPrepayIdTask getPrepayId = new GetPrepayIdTask();
		getPrepayId.execute();
	}
	
	/**
	 * 获取订单信息 prepayID
	 *
	 */
	private class GetPrepayIdTask extends AsyncTask<Void, Void, GetPrepayIdResult> {

		private ProgressDialog dialog;
		private String accessToken;
		
		public GetPrepayIdTask() {
			//this.accessToken = accessToken;
		}
		
		@Override
		protected void onPreExecute() {
			dialog = ProgressDialog.show(AppActivity.sActivity, AppActivity.sActivity.getString(R.string.onekes_tishi), AppActivity.sActivity.getString(R.string.onekes_pay_loading));
		}

		@Override
		protected void onPostExecute(GetPrepayIdResult result) {
			if (dialog != null) {
				dialog.dismiss();
			}
			if (result.localRetCode == LocalRetCode.ERR_OK) {	// 订单获取成功
				Log.d("kxllx", "onPostExecute -> get order ok");
				sendPayReq(result);
			} else {
				Log.d("kxllx", "onPostExecute -> get order fail");
				Message msg = new Message();
				msg.what = AppActivity.MT_PAY_FAIL;
				msg.obj = "获取订单失败";
				msg.arg1 = Toast.LENGTH_SHORT;
		        AppActivity.sHandler.sendMessage(msg);
			}
		}

		@Override
		protected void onCancelled() {
			super.onCancelled();
		}

		@Override
		protected GetPrepayIdResult doInBackground(Void... params) {
			String url = "https://api.mch.weixin.qq.com/pay/unifiedorder";
			String entity = genProductArgs();
			
			Log.d("kxllx", "doInBackground -> url: " + url);
			Log.d("kxllx", "doInBackground -> entity: " + entity);
			
			GetPrepayIdResult result = new GetPrepayIdResult();
			
			byte[] buf = NET.httpPost(url, entity);
			if (buf == null || buf.length == 0) {
				result.localRetCode = LocalRetCode.ERR_HTTP;
				Log.e("kxllx", "doInBackground -> httpPost failed");
				return result;
			}
			
			String content = new String(buf);
			Log.e("kxllx", "doInBackground -> content: " + content + ", length: " + content.length());
			result.parseFrom(content);
			return result;
		}
	}
	
	/**
	 * 获取订单号结果
	 * @author Administrator
	 *
	 */
	private static class GetPrepayIdResult {
		public LocalRetCode localRetCode = LocalRetCode.ERR_OTHER;
		public String prepayId;
		public int errCode;
		public String errMsg;
		public String sContent = "";
		
		public void parseFrom(String content) {
			
			if (content == null || content.length() <= 0) {
				Log.e("kxllx", "parseFrom -> content is null");
				localRetCode = LocalRetCode.ERR_JSON;
				return;
			}
			
			try {
				
				String preid = XML.read(content, "prepay_id");
				Log.e("kxllx", "parseFrom -> preid: " + preid);
				
				if (preid!=null) { // success case
					prepayId = preid;
					localRetCode = LocalRetCode.ERR_OK;
				} else {
					localRetCode = LocalRetCode.ERR_JSON;
				}
			} catch (Exception e) {
				Log.e("kxllx", "parseFrom -> exception:\n" + e.toString());
				localRetCode = LocalRetCode.ERR_JSON;
			}
		}
	}
	
	/**
	 * 获取时间戳 秒为单位
	 * @return
	 */
	private long genTimeStamp() {
		return System.currentTimeMillis() / 1000;
	}
	
	/**
	 * 建议 traceid 字段包含用户信息及订单信息，方便后续对订单状态的查询和跟踪  加入wx方便知道是微信支付订单
	 */
	private String getTraceId() {
		return "wx" + this.m_sOrderId; 
	}
	
	/**
	 * 注意：商户系统内部的订单号,32个字符内、可包含字母,确保在商户系统唯一
	 */
	private String genOutTradNo() {
//		Random random = new Random();
		return this.m_sOrderId;//MD5.getMessageDigest(String.valueOf(random.nextInt(10000)).getBytes());
	}
	
	/**
	 * 获取随机字符串 安全性  为了让发送的md5值不好预测
	 * @return
	 */
	private String genNonceStr() {
		Random random = new Random();
		return MD5.get(String.valueOf(random.nextInt(10000)));
	}
	
	/**
	 * 微信公众平台商户模块和商户约定的密钥
	 * 
	 * 注意：不能hardcode在客户端，建议genPackage这个过程由服务器端完成
	 */
	private String genPackage(List<NameValuePair> params) {
		StringBuilder sb = new StringBuilder();
		
		for (int i = 0; i < params.size(); i++) {
			String sName = params.get(i).getName();
			String sKey = params.get(i).getValue();
			sb.append(sName);
			sb.append('=');
			if (sName.equals("body") || sName.equals("detail"))
			{
//				try {
//					sb.append(URLEncoder.encode(sKey, "utf-8"));
//				} catch (UnsupportedEncodingException e) {
					// TODO Auto-generated catch block
					sb.append(sKey);
//				}
			}
			else
			{
				sb.append(sKey);
			}
			sb.append('&');
		}
		sb.append("key=");
		sb.append(CONFIG.WX_APP_KEY); // 注意：不能hardcode在客户端，建议genPackage这个过程都由服务器端完成
		
		// 进行md5摘要前，params内容为原始内容，未经过url encode处理
		Log.e("kxllx", "genPackage -> sb: " + sb.toString());
		String packageSign = MD5.get(sb.toString()).toUpperCase();
		Log.e("kxllx", "genPackage -> packageSign: " + packageSign);
		return packageSign;//URLEncodedUtils.format(params, "utf-8") + "&sign=" + packageSign;
	}
	
	private String genProductArgs() {
		String sXml = "<xml>";				// 要发送的XML信息
		try {
			String traceId = getTraceId();  // traceId 由开发者自定义，可用于订单的查询与跟踪，建议根据支付用户信息生成此id
			nonceStr = genNonceStr();
			String traceNo = genOutTradNo();
			
			sXml = sXml + "<appid>" + CONFIG.WX_APP_ID + "</appid>";
			sXml = sXml + "<mch_id>" + CONFIG.WX_PARTNER_ID + "</mch_id>";
			sXml = sXml + "<device_info>013467007045764</device_info>";
			sXml = sXml + "<nonce_str>" + nonceStr + "</nonce_str>";
			sXml = sXml + "<body>" + this.m_sProductName + "</body>";
			sXml = sXml + "<detail>" + this.m_sProductName + "</detail>";
			sXml = sXml + "<attach>" + traceId + "</attach>";
			sXml = sXml + "<out_trade_no>" + traceNo + "</out_trade_no>";
			sXml = sXml + "<fee_type>CNY</fee_type>";
			sXml = sXml + "<total_fee>" + this.m_sTotalFee + "</total_fee>";
			sXml = sXml + "<spbill_create_ip>10.0.0.191</spbill_create_ip>";
			sXml = sXml + "<time_start>" + genTimeStamp() + "</time_start>";
			sXml = sXml + "<time_expire>" + (genTimeStamp() + 7200) + "</time_expire>";
			sXml = sXml + "<goods_tag>WXG</goods_tag>";
			sXml = sXml + "<notify_url>www.onekes.com</notify_url>";
			sXml = sXml + "<trade_type>APP</trade_type>";
			
			List<NameValuePair> packageParams = new LinkedList<NameValuePair>();
			packageParams.add(new BasicNameValuePair("appid", CONFIG.WX_APP_ID));			// 公众号ID
			packageParams.add(new BasicNameValuePair("attach", traceId));						// 携带数据
			packageParams.add(new BasicNameValuePair("body", this.m_sProductName));				// 商品名称
			packageParams.add(new BasicNameValuePair("detail", this.m_sProductName));			// 商品详情
			packageParams.add(new BasicNameValuePair("device_info", "013467007045764"));						// 设备号
			packageParams.add(new BasicNameValuePair("fee_type", "CNY"));						// 币种 人民币
			packageParams.add(new BasicNameValuePair("goods_tag", "WXG"));						// 商品类型
			packageParams.add(new BasicNameValuePair("mch_id", CONFIG.WX_PARTNER_ID));		// 商户ID
			packageParams.add(new BasicNameValuePair("nonce_str", nonceStr));					// 随机数
			packageParams.add(new BasicNameValuePair("notify_url", "www.onekes.com"));	// 回调地址
			packageParams.add(new BasicNameValuePair("out_trade_no", traceNo));					// 订单号
			packageParams.add(new BasicNameValuePair("spbill_create_ip", "10.0.0.191"));		// 付费机器IP
			packageParams.add(new BasicNameValuePair("time_expire", (genTimeStamp() + 7200) + ""));		// 公众号ID
			packageParams.add(new BasicNameValuePair("time_start", genTimeStamp() + ""));		// 公众号ID
			packageParams.add(new BasicNameValuePair("total_fee", this.m_sTotalFee + ""));			// 付费金额
			packageParams.add(new BasicNameValuePair("trade_type", "APP"));						// 交易类型
			
			packageValue = genPackage(packageParams);
			
			sXml = sXml + "<sign>" + packageValue + "</sign>";
			sXml = sXml + "</xml>";
			sXml = new String(sXml.getBytes(), "ISO8859-1");
			Log.e("kxllx", "genProductArgs -> sXml: " + sXml);
		} catch (Exception e) {
			Log.e("kxllx", "genProductArgs -> exception:\n" + e.getMessage());
			return null;
		}
		
		return sXml;
	}
	
	private String genSign(List<NameValuePair> params) {
		StringBuilder sb = new StringBuilder();
		
		int i = 0;
		for (; i < params.size() - 1; i++) {
			sb.append(params.get(i).getName());
			sb.append('=');
			sb.append(params.get(i).getValue());
			sb.append('&');
		}
		sb.append(params.get(i).getName());
		sb.append('=');
		sb.append(params.get(i).getValue());
		Log.d("kxllx", "genSign -> sb: "+sb.toString());
		String sha1 = MD5.get(sb.toString());
		Log.d("kxllx", "genSign -> sha1: " + sha1);
		return sha1;
	}
	
	private void sendPayReq(GetPrepayIdResult result) {
		Log.d("kxllx", "sendPayReq");
		PayReq req = new PayReq();
		req.appId = CONFIG.WX_APP_ID;
		req.partnerId = CONFIG.WX_PARTNER_ID;
		req.prepayId = result.prepayId;
		req.nonceStr = nonceStr;
		req.timeStamp = String.valueOf(timeStamp);
		req.packageValue = "Sign=WXPay";//"Sign=" + packageValue;
		
		List<NameValuePair> signParams = new LinkedList<NameValuePair>();
		signParams.add(new BasicNameValuePair("appid", req.appId));
		signParams.add(new BasicNameValuePair("noncestr", req.nonceStr));
		signParams.add(new BasicNameValuePair("package", req.packageValue));
		signParams.add(new BasicNameValuePair("partnerid", req.partnerId));
		signParams.add(new BasicNameValuePair("prepayid", req.prepayId));
		signParams.add(new BasicNameValuePair("timestamp", req.timeStamp));
		req.sign = genPackage(signParams);
		
		// 在支付之前，如果应用没有注册到微信，应该先调用IWXMsg.registerApp将应用注册到微信
		if (api.sendReq(req)) {
			Log.d("kxllx", "sendPayReq -> send ok");
		} else {
			Log.d("kxllx", "sendPayReq -> send fail");
		}
	}
	
}
