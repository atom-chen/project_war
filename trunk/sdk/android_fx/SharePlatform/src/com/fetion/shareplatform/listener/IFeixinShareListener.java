package com.fetion.shareplatform.listener;

public interface IFeixinShareListener {
	
	/**
	 * 请求成功回调 
	 * @param b 回调数据有两种：1.true 成功
	 *                        2.false 失败
	 */
	public void onCompleted(boolean b);
	
	/**
	 * 请求失败回调
	 * @param message 失败信息   1."need login"：需要登录
	 *                         2.其它：错误信息
	 * @param errorCode 错误码   1.分享内容字符超长(最长140个字符)
	 *                         2.分享图片的类型不符
	 *                         3.分享内容重复
	 *                         4.分享频率过限
	 *                         5.服务器错误
	 *                         6.分享参数缺失
	 *                         7.分享失败
	 *                         8.请求服务器失败
	 */
	public void onFailure(String message, int errorCode);
	
	/**
	 * 请求超时回调
	 */
	public void onTimeOut();
}
