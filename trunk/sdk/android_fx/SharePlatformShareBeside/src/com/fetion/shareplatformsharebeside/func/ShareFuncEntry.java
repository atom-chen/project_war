package com.fetion.shareplatformsharebeside.func;

import android.content.Context;

import com.fetion.shareplatform.listener.IFeixinShareListener;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatform.util.Utils;

public class ShareFuncEntry {
	
	public static IFeixinShareListener shareListener;
	
	/**
	 * 分享内容到指定app
	 * @param context 上下文
	 * @param shareApp  判断分享到的App
	 * @param shareType  判断分享类型  例：文本 图片等  1:文本，2：图片，3：视频 4：URL
	 * 分享到url的时候  需要加http头 如   http://www.baidu.com
	 * @param info 分享实体  
	 * @param appKey 飞信开放平台提供的APPkey
	 * @param listener 监听接口
	 * */
    public static void fetionShare(Context context, int shareApp, int shareType,
			SharePlatformInfo info, String appKey,IFeixinShareListener listener){
    	if (Utils.selectToken(context, "FX")) {
	    	shareListener=listener;
	    	ShareModule module=new ShareModule();
	    	module.goToShare(context, shareApp, shareType, info, appKey);
    	}else{
    		listener.onFailure("need login", 0);
    	}
	}
}
