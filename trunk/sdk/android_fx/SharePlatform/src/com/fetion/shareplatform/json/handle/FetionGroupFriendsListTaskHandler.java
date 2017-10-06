package com.fetion.shareplatform.json.handle;

import java.util.List;
import com.fetion.shareplatform.model.FetionGroupFriendsEntity;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public abstract class FetionGroupFriendsListTaskHandler extends TaskHandler<List<FetionGroupFriendsEntity>>{

	private static String TAG = FetionGroupFriendsListTaskHandler.class.getSimpleName();

//	@Override
//	public List<FetionGroupFriendsEntity> parseResult(InputStream result) {
//		String data = null;
//		List<FetionGroupFriendsEntity> friends = null;
//		try {
//			data = Utils.stream2String(result);
//			friends = new Gson().fromJson(data.trim(), new TypeToken<List<FetionGroupFriendsEntity>>(){}.getType());
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} catch (Exception e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} 
//		return friends;
//	}
	
	@Override
	public List<FetionGroupFriendsEntity> parseResult(String result) {
		List<FetionGroupFriendsEntity> friends = null;
		try {
			friends = new Gson().fromJson(result.trim(), new TypeToken<List<FetionGroupFriendsEntity>>(){}.getType());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		return friends;
	}

}
