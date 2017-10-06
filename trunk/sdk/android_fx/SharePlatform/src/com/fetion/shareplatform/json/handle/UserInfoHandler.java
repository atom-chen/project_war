package com.fetion.shareplatform.json.handle;

import android.util.Log;

import com.fetion.shareplatform.model.UserInfo;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public abstract class UserInfoHandler extends TaskHandler<UserInfo>{
	
	private static String TAG = UserInfoHandler.class.getSimpleName();

	@Override
	public UserInfo parseResult(String result) {
		UserInfo info = null;
		try {
			Log.i(TAG, result);
			info = new Gson().fromJson(result.trim(), new TypeToken<UserInfo>(){}.getType());
		} catch (Exception e) {
			return null;
		} 
		return info;
	}
}
