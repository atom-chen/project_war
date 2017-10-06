package com.onekes.kxllx;

import com.onekes.kxllx.R;
import java.util.HashMap;

import android.app.Activity;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;
import org.apache.http.util.EncodingUtils;
import org.cocos2dx.lua.AppActivity;

import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;

public class ShareUtil {
	// share channel define
	private static final int SC_NONE	= 0;
	private static final int SC_WECHAT	= 1;
	
	public static void onCreate(Activity activity) {
		ShareSDK.initSDK(activity);
	}
	
	public static void onResume(Activity activity) {
	}
	
	public static void onPause(Activity activity) {
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	}
	
	public static void onDestroy(Activity activity) {
	}
	
	public static void share(String shareJson) {
		try {
			shareJson = EncodingUtils.getString(shareJson.getBytes(), "UTF-8");
			JSONObject jsonObj = new JSONObject(shareJson);
			int shareChannel = jsonObj.getInt("share_channel");
			if (SC_NONE == shareChannel) {
			} else if (SC_WECHAT == shareChannel) {
				wechatShare(jsonObj.getInt("share_type"), jsonObj.getString("share_content"), jsonObj.getString("share_url"), jsonObj.getString("share_pic"));
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	// 微信分享
	private static void wechatShare(int type, String content, String url, String picture) {
		if (1 == type) {
			Log.e("kxllx", "share picture");
			wechatSharePicture(content, url, picture);
		} else if (2 == type) {
			Log.e("kxllx", "share url");
			wechatShareUrl(content, url, picture);
		}
	}
	
	// 微信分享监听
	private static class WechatSharePlatformActionListener implements PlatformActionListener {
		@Override
		public void onComplete(Platform plat, int action, HashMap<String, Object> res) {
			// TODO Auto-generated method stub
			Message msg = new Message();
	        msg.what = AppActivity.MT_SHARE_SUCCESS;
	        msg.obj = R.string.wechat_share_success;
	        msg.arg1 = Toast.LENGTH_LONG;
	        AppActivity.sHandler.sendMessage(msg);
		}
		
		@Override
		public void onError(Platform plat, int action, Throwable t) {
			// TODO Auto-generated method stub
			Message msg = new Message();
	        msg.what = AppActivity.MT_SHARE_FAIL;
	        msg.obj = R.string.wechat_share_fail;
	        msg.arg1 = Toast.LENGTH_LONG;
	        AppActivity.sHandler.sendMessage(msg);
		}
		
		@Override
		public void onCancel(Platform plat, int action) {
			// TODO Auto-generated method stub
			Message msg = new Message();
	        msg.what = AppActivity.MT_SHARE_CANCEL;
	        msg.obj = R.string.wechat_share_cancel;
	        msg.arg1 = Toast.LENGTH_LONG;
	        AppActivity.sHandler.sendMessage(msg);
		}
	}
	
	// 微信朋友圈分享图片
	private static void wechatSharePicture(String shareContent, String shareUrl, String sharePic) {
		cn.sharesdk.wechat.moments.WechatMoments.ShareParams sp = new cn.sharesdk.wechat.moments.WechatMoments.ShareParams();
		sp.shareType = Platform.SHARE_IMAGE;
		sp.imagePath = sharePic;
		
		Platform wechatPlatform = ShareSDK.getPlatform(cn.sharesdk.wechat.moments.WechatMoments.NAME);
		wechatPlatform.setPlatformActionListener(new WechatSharePlatformActionListener());	// 设置分享事件回调
		wechatPlatform.share(sp);
	}
	
	// 微信朋友圈分享链接
	private static void wechatShareUrl(String shareContent, String shareUrl, String sharePic) {
		cn.sharesdk.wechat.moments.WechatMoments.ShareParams sp = new cn.sharesdk.wechat.moments.WechatMoments.ShareParams();
		sp.shareType = Platform.SHARE_WEBPAGE;
		sp.title = shareContent;
		sp.text = shareContent;
		sp.url = shareUrl;
		sp.imageData = BitmapFactory.decodeResource(AppActivity.sActivity.getResources(), R.drawable.icon);
		
		Platform wechatPlatform = ShareSDK.getPlatform(cn.sharesdk.wechat.moments.WechatMoments.NAME);
		wechatPlatform.setPlatformActionListener(new WechatSharePlatformActionListener());	// 设置分享事件回调
		wechatPlatform.share(sp);
	}
}


