/**
 * 杭州哲信支付接入结果监听类
 * 支付必须实现以下接口代码
 * auth: yejt
 */
package com.onekes.kxllx.hzzxpay;

public interface HzzxPayListener {
	/**
	 * 支付成功
	 * @param code	支付结果码
	 * @param sMsg	支付结果描述
	 */
	public void onSuccess(int code, String sMsg);
	
	/**
	 * 支付失败
	 * @param code	支付结果码
	 * @param sMsg	支付结果描述
	 */
	public void onFail(int code, String sMsg);
}
