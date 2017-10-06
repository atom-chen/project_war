package com.fetion.shareplatform.json.handle;

import com.fetion.shareplatform.model.FetionFeedEntity;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public abstract class FetionFeedHandler extends TaskHandler<FetionFeedEntity>{
	private static String TAG = FetionFeedHandler.class.getSimpleName();
	
	
	
	@Override
	public void onFailed(String result) {
		onFailure(result);
	}

	public abstract void onFailure(String result);

	@Override
	public FetionFeedEntity parseResult(String result) {
		FetionFeedEntity feed = null;
		try {
			feed = new Gson().fromJson(result.trim(), new TypeToken<FetionFeedEntity>(){}.getType());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		
		return feed;
	}
}
