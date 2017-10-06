package com.fetion.shareplatform.listener;

import com.fetion.shareplatform.model.OauthAccessToken;

public interface IShareplatformAuthListener {
	
	public void onCompleted(OauthAccessToken token);
	public void onFailure(String message);
	public void onCancle();
}
