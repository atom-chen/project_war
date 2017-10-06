package com.fetion.shareplatform.listener;

import com.fetion.shareplatform.model.UserInfo;

public interface UserInfoListener {
	
	/**
	 * 请求成功时回调
	 * @param result 返回 UserInfo实体
	 */
	public void onCompleted(UserInfo result);
	
	/**
	 * 请求失败时回调
	 * @param message 失败信息    1."need login"：需要登录
	 *                         2.其它：错误信息
	 */
	public void onFailure(String message);
	
	/**
	 *超 网络错误时回调
	 */
	public void onTimeOut();
}
