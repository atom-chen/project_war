package com.fetion.shareplatform.listener;

public interface IShareplatformFriendsListListener {
	/**
	 * 分享成功回调
	 * @param isSuccess 1.true:成功  
	 *                  2.false:失败
	 */
	public void onCompleted(boolean isSuccess);
	
	/**
	 * 分享失败回调
	 * @param message 失败信息    1."need login"：需要登录
	 *                         2.其它：错误信息
	 * @param errorCode 错误码    1.短信分发达到条数限制
	 *                         2.用户条数受限
	 *                         3.WPA侧故障
	 *                         4.分享失败
	 *                         5.请求服务器失败
	 */
	public void onFailure(String message, int errorCode);
	
	/**
	 * 分享请求超时回调
	 */
	public void onTimeOut();
}
