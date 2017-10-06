package com.fetion.shareplatform.json.handle;

import android.util.Log;

import com.fetion.shareplatform.json.response.OrderQueryResponse;
import com.google.gson.Gson;

public abstract class PlatformOrderQueryTaskHandler extends TaskHandler<OrderQueryResponse>{

	private static final String TAG = PlatformOrderQueryTaskHandler.class.getSimpleName();
	
	@Override
	public OrderQueryResponse parseResult(String result) {
		try{
			OrderQueryResponse order = new Gson().fromJson(result, OrderQueryResponse.class);
			return order;
		}
		catch(Exception ex){
			Log.i(TAG, ex.getMessage());
		}
		return null;
	}

}
