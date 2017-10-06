package com.fetion.shareplatform.listener;

public interface IFeixinAccountListener {
	
	/**
	 * 请求成功时回调
	 */
	public void onCompleted();
	
	/**
	 * 请求失败时回调
	 * @param message 失败信息 1."need login"：需要登录
	 *                        2.其它：错误信息
	 * @param errorCode 错误码    分两种情况：1.关注飞信公众号 (1).已关注成功,请不要重复关注 (2).关注公众号失败 (3).连接服务器失败
	 *                                      2.取消关注飞信公众号 (1).取消关注公众号失败 (2).连接服务器失败
	 */
	public void onFailure(String message, int errorCode);
	
	/**
	 * 网络连接错误时回调
	 */
	public void onNetError();
	
	/**
	 *请求超时时回调
	 */
	public void onTimeOut();
}
