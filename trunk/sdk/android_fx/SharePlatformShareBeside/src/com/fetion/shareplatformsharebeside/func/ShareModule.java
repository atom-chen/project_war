package com.fetion.shareplatformsharebeside.func;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.content.Context;
import android.database.Cursor;
import android.util.Log;

import com.fetion.shareplatform.EntryDispatcher;
import com.fetion.shareplatform.db.TokensDB;
import com.fetion.shareplatform.listener.IShareplatformAuthListener;
import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatform.util.Utils;

public class ShareModule {

	public AuthListener listener = new AuthListener();
	/** 应用缩写 用于数据库保存确认 */
	public static String appName = "";

	public int mShareApp;
	public int mShareType;
	public String mApi_Kye;
	public SharePlatformInfo mInfo;
	public Context mcontext;
	public int temp_id;
	public void goToShare(Context context, int shareApp, int shareType,
			SharePlatformInfo info, String api_Kye) {
		mShareApp = shareApp;
		mShareType = shareType;
		mApi_Kye = api_Kye;
		mInfo = info;
		mcontext = context;
		switch (shareApp) {
		case EntryDispatcher.APP_SHENBIAN:
			appName = "FX";
			isToken();
			break;
		}
	}

	private void isToken() {
			OauthAccessToken token=new OauthAccessToken();
			token.access_token=Utils.getAccessToken(mcontext, "FX");
			ShareInterfaceUtils.shareToFetion(mShareType,mcontext,mApi_Kye,token,mInfo,ShareFuncEntry.shareListener);

	}

	private final String yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss";

	/***
	 * 两个日期相差多少秒
	 * 
	 * @param date1
	 * @param date2
	 * @return
	 */
	public int getTimeDelta(Date date1, Date date2) {
		long timeDelta = (date1.getTime() - date2.getTime()) / 1000;// 单位是秒
		int secondsDelta = timeDelta > 0 ? (int) timeDelta : (int) Math
				.abs(timeDelta);
		return secondsDelta;
	}

	/***
	 * 两个日期相差多少秒
	 * 
	 * @param dateStr1
	 *            :yyyy-MM-dd HH:mm:ss
	 * @param dateStr2
	 *            :yyyy-MM-dd HH:mm:ss
	 */
	public int getTimeDelta(String dateStr1, String dateStr2) {
		Date date1 = parseDateByPattern(dateStr1, yyyyMMddHHmmss);
		Date date2 = parseDateByPattern(dateStr2, yyyyMMddHHmmss);
		return getTimeDelta(date1, date2);
	}

	public Date parseDateByPattern(String dateStr, String dateFormat) {
		SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		try {
			return sdf.parse(dateStr);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	/** 根据appName获取token 然后判断是否新增或者修改 **/
	public boolean selectTokenByAppName(Context context, String appName) {
		Log.i("tian", "准备查询获取cursor");
		TokensDB db = TokensDB.getInstance(context);
		Cursor cursor = db.select();
		if (cursor.getCount() == 0) {
			Log.i("tian", "cursor内没有数据");
		} else {
			// 循环遍历cursor
			while (cursor.moveToNext()) {
				if (appName.equals(cursor.getString(5))) {
					temp_id = cursor.getInt(0);
					return true;
				}
			}
		}
		cursor.close();
		db.close();
		return false;
	}

	public class AuthListener implements IShareplatformAuthListener {

		@Override
		public void onCompleted(OauthAccessToken token) {
			if (token != null) {
				// 保存后跳转界面
				SimpleDateFormat sDateFormat = new SimpleDateFormat(
						"yyyy-MM-dd hh:mm:ss");
				String date = sDateFormat.format(new java.util.Date());
				if (selectTokenByAppName(mcontext, appName)) {
					// 已经拥有token做修改操作
					Log.i("tian", "修改操作");
					TokensDB db = TokensDB.getInstance(mcontext);
					db.update(temp_id, "", token.access_token,token.cookie, token.expires_in, date, appName);
					db.close();
				} else {
					TokensDB db = TokensDB.getInstance(mcontext);

					long num = db.insert("", token.access_token,token.cookie,
							token.expires_in, date, appName);
					if (num != -1) {
						Log.i("tian", "数据库insert 测试成功");
					}
					db.close();
				}
				// 进入分享界面
				ShareInterfaceUtils.shareToFetion(mShareType,mcontext,mApi_Kye,token,mInfo,ShareFuncEntry.shareListener);

			} else {
				// token获取失败

			}
		}

		@Override
		public void onFailure(String message) {

		}

		@Override
		public void onCancle() {
			// TODO Auto-generated method stub
			
		}
	}

}
