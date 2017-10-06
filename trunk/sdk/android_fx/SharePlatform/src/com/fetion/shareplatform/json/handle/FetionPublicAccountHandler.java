package com.fetion.shareplatform.json.handle;

public abstract class FetionPublicAccountHandler extends TaskHandler<String>{
	private static String TAG = FetionPublicAccountHandler.class.getSimpleName();
	
	@Override
	public String parseResult(String result) {
		return result;
	}
}
