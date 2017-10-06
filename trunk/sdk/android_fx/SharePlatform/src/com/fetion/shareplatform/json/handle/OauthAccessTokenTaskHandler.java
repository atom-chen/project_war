package com.fetion.shareplatform.json.handle;

import android.util.Log;

import com.fetion.shareplatform.model.OauthAccessToken;
import com.google.gson.Gson;

public abstract class OauthAccessTokenTaskHandler extends TaskHandler<OauthAccessToken>{

	private static final String TAG = OauthAccessTokenTaskHandler.class.getSimpleName();
	@Override
	public OauthAccessToken parseResult(String result) {
		try{
			OauthAccessToken token = new Gson().fromJson(result, OauthAccessToken.class);
			return token;
		}
		catch(Exception ex){
			Log.i(TAG, ex.getMessage());
		}
		return null;
	}

}
