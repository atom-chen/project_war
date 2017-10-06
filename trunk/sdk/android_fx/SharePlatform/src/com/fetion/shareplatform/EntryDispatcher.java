package com.fetion.shareplatform;

import com.fetion.shareplatform.listener.IShareplatformAuthListener;
import com.fetion.shareplatform.listener.IShareplatformFriendsListListener;



/**
 * 入口分发器：根据不同type，跳转到不同页面
 *
 */
public class EntryDispatcher {

	/** 分享类型：文本 */
	public static final int SHARE_TYPE_TEXT = 1;
	/** 分享类型：图片 */
	public static final int SHARE_TYPE_IMAGE = 2;
	/** 分享类型：视频 */
	public static final int SHARE_TYPE_VIDEO = 3;
	/** 分享类型：网页 */
	public static final int SHARE_TYPE_WEBPAGE = 4;
	
	/** 分享编号   分享到身边         */
	public static final int APP_SHENBIAN= 1 ;
	
	/** true:获取URL短链,false:存储URL*/
	private static boolean dealUrl = false;
	
	public static String gAppKey;
	public static String gSecretKey;
	


	
	public static abstract class DispatcherOauthListener implements IShareplatformAuthListener{
		
	}
    public static abstract class  DispatcherFriendsListListener implements IShareplatformFriendsListListener{
 
	}


}
